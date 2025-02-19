import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct PartnerDetailView: View {
    @Binding var partner: Partner // 바인딩을 통해 부모 뷰의 데이터를 수정할 수 있게 함
    @State private var saveSuccessMessage: String? = nil // 저장 성공 메시지
    @StateObject private var homeViewModel = HomeViewModel()
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 1) {

                TextField("연락처", text: $partner.contact)
                    .font(.title2)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("주소", text: $partner.address)
                    .font(.title2)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("월 관리금액", value: $partner.monthlyManagementFee, formatter: NumberFormatter())
                    .font(.title2)
                    .padding()
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("관리지역", text: $partner.managementArea)
                    .font(.title2)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                HStack {
                    Spacer()
                    VStack {
                        Text("작동 점검 월")
                        Picker("월", selection: $partner.operationCheckMonth) {
                            ForEach(1...12, id: \.self) { month in
                                Text("\(month)월").tag(month)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .padding()
                    Spacer()
                    VStack {
                        Text("종합 점검 월")
                        Picker("월", selection: $partner.comprehensiveCheckMonth) {
                            Text("없음").tag(nil as Int?)
                            ForEach(1...12, id: \.self) { month in
                                Text("\(month)월").tag(month as Int?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .padding()
                    Spacer()
                }
                HStack {
                    
                   Text("                                  ")
                    Toggle("방문 여부", isOn: $partner.visited)
                        .padding()
                }

                Button(action: {
                  
                

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

                // 저장 성공 메시지
                if let saveSuccessMessage = saveSuccessMessage {
                    Text(saveSuccessMessage)
                        .foregroundColor(.green)
                        .font(.headline)
                        .padding()
                }
            }
        }
        .navigationTitle(partner.name)
    }

    // 데이터를 수정한 후 Firebase에 저장하는 함수

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
