import SwiftUI

struct PartnerRegisterView: View {
    @StateObject private var viewModel = PartnerRegisterViewModel() // 뷰모델 객체

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("\(viewModel.userEmail)님, 환영합니다! 🎉")
                    .foregroundColor(.white)
                    .font(.system(size: 15, weight: .medium))
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.gray.opacity(0.5))
                    .cornerRadius(8)

                if viewModel.isLoading {
                    ProgressView("로그인 정보를 가져오는 중...")
                        .padding()
                } else if let nickname = viewModel.nickname {
                    Text("\(nickname)님의 거래처 등록")
                        .font(.headline)
                        .padding()
                } else {
                    Text("사용자 정보를 불러오지 못했습니다.")
                        .foregroundColor(.red)
                        .padding()
                }

                // 필드들
                TextField("거래처 이름", text: $viewModel.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("연락처", text: $viewModel.contact)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("주소", text: $viewModel.address)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
              
                
                HStack {
                    TextField("월 관리금액", text: $viewModel.monthlyManagementFee)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Text("원")
                        .font(.headline)
                }
                HStack{
                    TextField("빌딩 면적", text: $viewModel.BuildingArea)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Text("m2")
                }
                TextField("관리지역", text: $viewModel.managementArea)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                HStack{
                    VStack {
                        Text("작동 점검 월")
                        Picker("월", selection: $viewModel.selectedOperationMonth) {
                            ForEach(viewModel.months, id: \.self) { month in
                                Text("\(month)월").tag(month)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .padding()
                    
                    VStack {
                        Text("종합 점검 월")
                        Picker("월", selection: Binding<Int?>(
                            get: { viewModel.selectedComprehensiveMonth },
                            set: { viewModel.selectedComprehensiveMonth = $0 }
                        )) {
                            Text("없음").tag(nil as Int?)
                            ForEach(viewModel.months, id: \.self) { month in
                                Text("\(month)월").tag(month as Int?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .padding()
                }
                TextField("안전 관리자 이름", text: $viewModel.safetyManagerName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                Button(action: {
                    SoundManager.shared.playSound("mixkit-select-click-1109", fileType: "wav")
                    viewModel.addPartner() // 거래처 추가 함수 호출
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
                .disabled(viewModel.nickname == nil)
            }
            .padding()
            .onAppear {
                if viewModel.nickname == nil {
                    viewModel.fetchUserNickname() // 닉네임을 가져오는 함수 호출
                }
            }
        }
    }
}




#Preview {
    PartnerRegisterView()
}
