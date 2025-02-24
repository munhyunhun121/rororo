import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct PartnerDetailView: View {
    @Binding var partner: Partner // 홈뷰에서 선택된 파트너 데이터 수정 가능
    @State private var saveSuccessMessage: String? = nil
    @State private var showDeleteAlert = false // Alert 표시 여부를 위한 상태 변수
    @State private var showaddAlert = false
    @StateObject private var homeViewModel = HomeViewModel() // Firebase


    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
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
        createdAt: Date()
    )))
}
