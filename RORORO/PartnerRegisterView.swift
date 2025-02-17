import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct PartnerRegisterView: View {
    @StateObject private var userViewModel = UserViewModel()
    @State private var name: String = ""
    @State private var contact: String = ""
    @State private var address: String = ""
    @State private var visited: Bool = false
    @State private var monthlyManagementFee: String = ""
    @State private var managementArea: String = ""
    @State private var safetyManagerName: String = ""

    @State private var selectedOperationMonth = Calendar.current.component(.month, from: Date()) // ✅ 현재 월
    @State private var selectedComprehensiveMonth: Int? = nil // ✅ "없음" 기본값

    @State private var nickname: String? = nil
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = true

    let db = Firestore.firestore()
    let months: [Int] = (1...12).map { $0 } // ✅ 1~12월

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("\(userViewModel.userEmail)님, 환영합니다! 🎉")
                    .foregroundColor(.white)
                    .font(.system(size: 15, weight: .medium))
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.gray.opacity(0.5))
                    .cornerRadius(8)

                if isLoading {
                    ProgressView("로그인 정보를 가져오는 중...")
                        .padding()
                } else if let nickname = nickname {
                    Text("\(nickname)님의 거래처 등록")
                        .font(.headline)
                        .padding()
                } else {
                    Text("사용자 정보를 불러오지 못했습니다.")
                        .foregroundColor(.red)
                        .padding()
                }

                TextField("거래처 이름", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("연락처", text: $contact)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("주소", text: $address)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Toggle("방문 여부", isOn: $visited)
                    .padding()

                TextField("월 관리금액", text: $monthlyManagementFee)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("관리지역", text: $managementArea)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                VStack {
                    Text("작동 점검 월")
                    Picker("월", selection: $selectedOperationMonth) {
                        ForEach(months, id: \.self) { month in
                            Text("\(month)월").tag(month)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                .padding()

                VStack {
                    Text("종합 점검 월 ")
                    Picker("월", selection: Binding<Int?>(
                        get: { selectedComprehensiveMonth },
                        set: { selectedComprehensiveMonth = $0 }
                    )) {
                        Text("없음").tag(nil as Int?)
                        ForEach(months, id: \.self) { month in
                            Text("\(month)월").tag(month as Int?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                .padding()

                TextField("안전 관리자 이름", text: $safetyManagerName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                Button(action: {
                    addPartner()
                }) {
                    Text("거래처 등록")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(nickname == nil)
            }
            .padding()
            .onAppear {
                if nickname == nil {
                    fetchUserNickname()
                }
            }
        }
    }

    // ✅ Firestore에서 현재 로그인한 사용자의 UID로 닉네임 가져오기
    func fetchUserNickname() {
        guard let user = Auth.auth().currentUser else {
            print("❌ 로그인된 사용자가 없습니다.")
            self.errorMessage = "로그인 정보가 없습니다."
            self.isLoading = false
            return
        }

        let usersCollection = Firestore.firestore().collection("users")

        usersCollection.whereField("email", isEqualTo: user.email ?? "").getDocuments { snapshot, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    print("🔥 Firestore 닉네임 가져오기 실패: \(error.localizedDescription)")
                    self.errorMessage = "사용자 정보를 가져오지 못했습니다."
                } else if let document = snapshot?.documents.first {
                    let nickname = document.documentID
                    print("✅ Firestore에서 가져온 닉네임: \(nickname)")
                    self.nickname = nickname
                } else {
                    print("❌ Firestore에서 사용자를 찾을 수 없습니다.")
                    self.errorMessage = "사용자 정보가 Firestore에 없습니다."
                }
            }
        }
    }

    // ✅ Firestore에 거래처 추가
    func addPartner() {
        guard let nickname = nickname else {
            errorMessage = "로그인된 사용자 정보가 없습니다."
            return
        }

        guard let monthlyFee = Double(monthlyManagementFee) else {
            errorMessage = "월 관리금액을 숫자로 입력해주세요."
            return
        }

        var newPartner: [String: Any] = [
            "name": name,
            "contact": contact,
            "address": address,
            "visited": visited,
            "monthlyManagementFee": monthlyFee,
            "managementArea": managementArea,
            "operationCheckMonth": selectedOperationMonth, // ✅ 숫자로 저장 (1~12)
            "safetyManagerName": safetyManagerName,
            "createdAt": Timestamp()
        ]

        if let comprehensiveMonth = selectedComprehensiveMonth {
            newPartner["comprehensiveCheckMonth"] = comprehensiveMonth // ✅ 선택된 경우만 저장
        }

        let partnersRef = Firestore.firestore().collection("users").document(nickname).collection("partners")

        partnersRef.addDocument(data: newPartner) { error in
            if let error = error {
                print("🔥 Firestore 저장 실패: \(error.localizedDescription)")
                self.errorMessage = "거래처 등록에 실패했습니다."
            } else {
                print("✅ 거래처 등록 완료! (닉네임: \(nickname))")
                name = ""
                contact = ""
                address = ""
                visited = false
                monthlyManagementFee = ""
                managementArea = ""
                safetyManagerName = ""
                self.selectedComprehensiveMonth = nil // ✅ "없음"으로 초기화
                self.errorMessage = "거래처가 성공적으로 등록되었습니다."
            }
        }
    }
}

#Preview {
    PartnerRegisterView()
}
