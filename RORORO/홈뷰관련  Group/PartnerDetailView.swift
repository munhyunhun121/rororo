
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// MARK: - PartnerDetailView
struct PartnerDetailView: View {
    @Binding var partner: Partner
    @State private var saveSuccessMessage: String? = nil
    @State private var showDeleteAlert = false
    @State private var showAddAlert = false
    @StateObject private var homeViewModel = HomeViewModel()
    @State private var selectedDate: Date?
    @State private var showDatePicker = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                submitDateSection
                infoSection
                actionButtons

                if let message = saveSuccessMessage {
                    Text(message)
                        .foregroundColor(.green)
                        .font(.headline)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle(partner.name)
    }
    


    // MARK: - Sections
    private var submitDateSection: some View {
        
        VStack(spacing: 10) {
            Button(action: { showDatePicker.toggle() }) {
                Label("날짜 선택", systemImage: "calendar.badge.plus")
                    .font(.title3.bold())
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(radius: 5)
            }
            .sheet(isPresented: $showDatePicker) {
                DatePickerView(partner: $partner, selectedDate: $selectedDate, showDatePicker: $showDatePicker)
            }
            Button(action: {
                resetSubmitDate()
               }) {
                   Label("제출 마감 초기화", systemImage: "arrow.counterclockwise")
                       .font(.title3.bold())
                       .padding()
                       .frame(maxWidth: .infinity)
                       .background(Color.red)
                       .foregroundColor(.white)
                       .cornerRadius(12)
                       .shadow(radius: 5)
               }


            Text("보고서 제출 마감: \(partner.SubmetDate)")
            Text("이행완료 마감: \(partner.reportReceivedDate)")
        }
        .font(.headline)
        .padding()
        
    }

    private var infoSection: some View {
        Group {
            TextField("연락처", text: $partner.contact)
            TextField("주소", text: $partner.address)
            HStack {
                TextField("월 관리금액", value: $partner.monthlyManagementFee, formatter: NumberFormatter())
                Text("원")
            }
            TextField("관리 지역", text: $partner.managementArea)
            HStack {
                TextField("건물 점검면적", text: $partner.BuildingArea)
                Text("m2")
            }
            Toggle("방문 여부", isOn: $partner.visited)
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .padding()
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button("변경사항 저장") {
                showAddAlert = true
            }
            .buttonStyle(MainButtonStyle(color: .blue))
            .alert("저장 확인", isPresented: $showAddAlert) {
                Button("저장", role: .destructive) {
                    homeViewModel.updatePartner(partner)
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("정말로 이 파트너를 저장하시겠습니까?")
            }

            Button("파트너 삭제") {
                showDeleteAlert = true
            }
            .buttonStyle(MainButtonStyle(color: .red))
            .alert("삭제 확인", isPresented: $showDeleteAlert) {
                Button("삭제", role: .destructive) {
                    homeViewModel.deletePartner(partner)
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("정말로 이 파트너를 삭제하시겠습니까?")
            }
        }
        .padding()
    }
    
    private func resetSubmitDate() {
        partner.SubmetDate = "비어있음"
        homeViewModel.resetSubmitDate(for: partner)
    }
}

// MARK: - DatePickerView
struct DatePickerView: View {
    @Binding var partner: Partner
    @Binding var selectedDate: Date?
    @Binding var showDatePicker: Bool

    var body: some View {
        VStack {
            Text("날짜 선택").font(.headline)

            DatePicker("날짜를 선택하세요", selection: Binding(get: { selectedDate ?? Date() }, set: { selectedDate = $0 }), displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .labelsHidden()
                .padding()

            HStack {
                Button("취소") { showDatePicker = false }
                    .buttonStyle(MainButtonStyle(color: .gray))

                Button("저장") {
                    if let date = selectedDate {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        partner.SubmetDate = formatter.string(from: date)
                        updateDateInFirestore(partner: partner, newDate: date)
                        showDatePicker = false
                    }
                }
                .buttonStyle(MainButtonStyle(color: .blue))
            }
        }
        .padding()
    }
}



// MARK: - Firestore Update
func updateDateInFirestore(partner: Partner, newDate: Date) {
    guard let user = Auth.auth().currentUser else { return }
    let db = Firestore.firestore()

    db.collection("users")
        .whereField("email", isEqualTo: user.email ?? "")
        .getDocuments { snapshot, error in
            guard let document = snapshot?.documents.first else { return }
            let nickname = document.documentID
            let partnerRef = db.collection("users").document(nickname).collection("partners").document(partner.id ?? "unknown_id")

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let formattedDate = formatter.string(from: newDate)

            partnerRef.updateData(["SubmetDate": formattedDate])
        }
}

// MARK: - ButtonStyle
struct MainButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2)
            .padding()
            .frame(maxWidth: .infinity)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(radius: configuration.isPressed ? 1 : 5)
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
        BuildingArea: "",// 6번째 인자
        managementArea: "",
        operationCheckMonth: 3,
        comprehensiveCheckMonth: 5,
        safetyManagerName: "김철수",
        createdAt: Date(),
        reportReceivedDate: "0",
        SubmetDate: "0"
    )))
}
