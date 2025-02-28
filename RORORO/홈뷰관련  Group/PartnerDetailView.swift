import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct PartnerDetailView: View {
    @Binding var partner: Partner // 홈뷰에서 선택된 파트너 데이터 수정 가능
    @State private var saveSuccessMessage: String? = nil
    @State private var showDeleteAlert = false // Alert 표시 여부를 위한 상태 변수
    @State private var showaddAlert = false
    @StateObject private var homeViewModel = HomeViewModel() // Firebase

 
    @State private var selectedDate: Date?
    
    @State private var showDatePicker = false
    
   
    
    
    var body: some View {
        ScrollView {
            
            VStack(alignment: .leading, spacing: 10) {
                
                
                
                
                Button(action: {
                             showDatePicker.toggle() // 버튼을 누르면 DatePicker 표시
                         }) {
                             HStack {
                                 Image(systemName: "calendar.badge.plus") // ✅ 아이콘 추가
                                     .font(.title2)
                                 
                                 Text("날짜 선택") // ✅ 버튼 텍스트
                                     .fontWeight(.semibold)
                                     .font(.title3)
                             }
                             .foregroundColor(.white)
                             .padding()
                             .frame(maxWidth: .infinity)
                             .background(
                                 LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing) // ✅ 그라디언트 배경
                             )
                             .cornerRadius(12) // ✅ 둥근 모서리
                             .shadow(radius: 5) // ✅ 그림자 효과
                         }
                         .padding()
                         .sheet(isPresented: $showDatePicker) {
                             DatePickerView(partner: $partner,selectedDate: $selectedDate, showDatePicker: $showDatePicker) // ✅ 바인딩된 값 전달
                         }

                            
                           
                
                
                
                
                    Text("보고서 제출 마감: \(partner.SubmetDate)")
                        .font(.headline)
                        .padding()
                    
                        
                    Text("이행완료 마감: \(partner.reportReceivedDate)")
                        .font(.headline)
                        .padding()
                
                TextField("연락처", text: $partner.contact)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("주소", text: $partner.address)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                HStack{
                    TextField("월 관리금액", value: $partner.monthlyManagementFee, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Text("원")
                }
                TextField("관리 지역", text: $partner.managementArea)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
               
                HStack{
                    TextField("건물 점검면적", text: $partner.BuildingArea)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Text("m2")
                }
                Toggle("방문 여부", isOn: $partner.visited)
                    .padding()

                Button(action: {
                    showaddAlert = true
                }) {
                    Text("변경사항 저장")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .alert("저장 확인", isPresented: $showaddAlert) {
                    Button("저장", role: .destructive) {
                        homeViewModel.updatePartner(partner)
                        
                    }
                    Button("취소", role: .cancel) { }
                } message: {
                    Text("정말로 이 파트너를 저장하시겠습니까?")
                }
                
                Button(action: {
                    showDeleteAlert = true // 삭제 버튼 클릭 시 Alert 활성화
                }) {
                    Text("파트너 삭제")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .alert("삭제 확인", isPresented: $showDeleteAlert) {
                    Button("삭제", role: .destructive) {
                        homeViewModel.deletePartner(partner)
                    }
                    Button("취소", role: .cancel) { }
                } message: {
                    Text("정말로 이 파트너를 삭제하시겠습니까?")
                }

                if let saveSuccessMessage = saveSuccessMessage {
                    Text(saveSuccessMessage)
                        .foregroundColor(.green)
                        .font(.headline)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle(partner.name)
    }
}



struct DatePickerView: View {
    @Binding var partner: Partner // ✅ 파트너 객체를 바인딩하여 수정 가능
    @Binding var selectedDate: Date? // ✅ 사용자가 선택한 날짜
    @Binding var showDatePicker: Bool // ✅ 모달 닫기 상태

    var body: some View {
        VStack {
            Text("날짜 선택")
                .font(.headline)
                .padding()

            // ✅ DatePicker에서 날짜 선택
            DatePicker(
                "날짜를 선택하세요",
                selection: Binding(
                    get: { selectedDate ?? Date() }, // ✅ `nil`이면 현재 날짜 사용
                    set: { newDate in selectedDate = newDate }
                ),
                displayedComponents: .date
            )
            .datePickerStyle(GraphicalDatePickerStyle()) // ✅ 그래픽 스타일
            .labelsHidden()
            .padding()

            HStack {
                // 🔹 "취소" 버튼 → 모달 닫기
                Button("취소") {
                    showDatePicker = false
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(radius: 3)

                // 🔹 "저장" 버튼 → `partner.SubmetDate` 업데이트
                Button("저장") {
                    if let date = selectedDate {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        partner.SubmetDate = formatter.string(from: date) // ✅ SubmetDate 업데이트
                        updateDateInFirestore(partner: partner, newDate: date) // ✅ Firestore 업데이트
                        showDatePicker = false // ✅ 저장 후 모달 닫기
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(radius: 3)
            }
            .padding()
        }
    }
}


func updateDateInFirestore(partner: Partner, newDate: Date) {
    let db = Firestore.firestore()
    guard let user = Auth.auth().currentUser else { return }

    db.collection("users")
        .whereField("email", isEqualTo: user.email ?? "")
        .getDocuments { snapshot, error in
            if let error = error {
                print("🔥 Firestore에서 사용자 찾기 실패: \(error.localizedDescription)")
                return
            }

            guard let document = snapshot?.documents.first else {
                print("❌ Firestore에서 사용자 문서 찾기 실패")
                return
            }

            let nickname = document.documentID
            let partnerRef = db.collection("users").document(nickname).collection("partners").document(partner.id ?? "unknown_id")

            // 🔹 Date를 String("yyyy-MM-dd") 형식으로 변환
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let formattedDate = formatter.string(from: newDate) // ✅ String 변환

            let updateData: [String: Any] = [
                "SubmetDate": formattedDate // ✅ 기존 Timestamp → String 저장
            ]

            partnerRef.updateData(updateData) { error in
                if let error = error {
                    print("🔥 Firestore 날짜 업데이트 실패: \(error.localizedDescription)")
                } else {
                    print("✅ Firestore 날짜 업데이트 성공! \(formattedDate)")
                }
            }
        }
}


#Preview {
    PartnerDetailView(partner: .constant(Partner(
        id: "1",
        name: "홍길동",
        contact: "010-1234-5678",
        address: "서울시 강남구",
        visited: true, // 5번째 인자
        monthlyManagementFee: 3535,
        BuildingArea: "0",// 6번째 인자
        managementArea: "0",
        operationCheckMonth: 3,
        comprehensiveCheckMonth: 5,
        safetyManagerName: "김철수",
        createdAt: Date(),
        reportReceivedDate: "0",
        SubmetDate: "0"
    )))
}
