// MARK: - Import
import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(keyboardType)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)
    }
}

struct PartnerRegisterView: View {
    @StateObject private var viewModel = PartnerRegisterViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                headerSection
                formFields
                errorSection
                registerButton
            }
            .padding()
            .onAppear {
                if viewModel.nickname == nil {
                    viewModel.fetchUserNickname()
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("\(viewModel.userEmail)님, 환영합니다! 🎉")
                .foregroundColor(.white)
                .font(.system(size: 15, weight: .medium))
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color.gray.opacity(0.5))
                .cornerRadius(8)
            
            if viewModel.isLoading {
                ProgressView("로그인 정보를 가져오는 중...")
            } else if let nickname = viewModel.nickname {
                Text("\(nickname)님의 거래처 등록")
                    .font(.headline)
            } else {
                Text("사용자 정보를 불러오지 못했습니다.")
                    .foregroundColor(.red)
            }
        }
    }
    
    private var formFields: some View {
        Group {
            CustomTextField(placeholder: "거래처 이름", text: $viewModel.name)
            CustomTextField(placeholder: "연락처", text: $viewModel.contact)
            CustomTextField(placeholder: "주소", text: $viewModel.address)
            CustomTextField(placeholder: "월 관리금액", text: $viewModel.monthlyManagementFee, keyboardType: .decimalPad)
            CustomTextField(placeholder: "빌딩 면적", text: $viewModel.buildingArea, keyboardType: .decimalPad)
            CustomTextField(placeholder: "관리지역", text: $viewModel.managementArea)
            CustomTextField(placeholder: "안전 관리자 이름", text: $viewModel.safetyManagerName)
            monthPickers
        }
    }
    
    private var monthPickers: some View {
        HStack(spacing: 20) {
            Picker("작동 점검 월", selection: $viewModel.selectedOperationMonth) {
                ForEach(viewModel.months, id: \..self) { month in
                    Text("작동 \(month)월").tag(month)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            Picker("종합 점검 월", selection: Binding<Int?>(
                get: { viewModel.selectedComprehensiveMonth },
                set: { viewModel.selectedComprehensiveMonth = $0 }
            )) {
                Text("없음").tag(nil as Int?)
                ForEach(viewModel.months, id: \..self) { month in
                    Text("종합 \(month)월").tag(month as Int?)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
    
    private var errorSection: some View {
        Group {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
    
    private var registerButton: some View {
        Button(action: {
            SoundManager.shared.playSound("mixkit-select-click-1109", fileType: "wav")
            viewModel.addPartner()
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
}

#Preview {
    PartnerRegisterView()
}
