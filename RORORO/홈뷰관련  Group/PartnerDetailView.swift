import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct PartnerDetailView: View {
    @Binding var partner: Partner // 홈뷰에서 선택된 파트너 데이터 수정 가능
    @State private var saveSuccessMessage: String? = nil
    @StateObject private var homeViewModel = HomeViewModel() // Firebase 업데이트 함수 포함

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                TextField("연락처", text: $partner.contact)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("주소", text: $partner.address)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("월 관리금액", value: $partner.monthlyManagementFee, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("관리 지역", text: $partner.managementArea)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Toggle("방문 여부", isOn: $partner.visited)
                    .padding()

                Button(action: {
                    homeViewModel.updatePartner(partner) // Firebase 업데이트 실행
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


#Preview {
    PartnerDetailView(partner: .constant(Partner(
        id: "1",
        name: "홍길동",
        contact: "010-1234-5678",
        address: "서울시 강남구",
        visited: true,
        monthlyManagementFee: 100.0,
        managementArea: "강남",
        operationCheckMonth: 3,
        comprehensiveCheckMonth: 5,
        safetyManagerName: "김철수",
        createdAt: Date()
    )))
}
