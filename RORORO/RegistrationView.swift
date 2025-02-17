import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RegistrationView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var nickname: String = ""
    @State private var phoneNumber: String = ""
    @State private var errorMessage: String? = nil
    @State private var registrationSuccess: Bool = false
    @State private var showMainTabView: Bool = false // 메인 화면 이동 플래그
    
    @State private var isNicknameAvailable: Bool? = nil
    @State private var isEmailAvailable: Bool? = nil
    
    private let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                
                // ✅ 닉네임 입력 필드 & 중복 확인
                HStack {
                    TextField("닉네임", text: $nickname)
                        .autocapitalization(.none)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: nickname) { _ in
                            isNicknameAvailable = nil
                            checkNicknameAvailability()
                        }

                    if let isNicknameAvailable = isNicknameAvailable {
                        Text(isNicknameAvailable ? "✅ 사용 가능" : "❌ 이미 사용 중")
                            .foregroundColor(isNicknameAvailable ? .green : .red)
                            .font(.caption)
                    }
                }
                .padding(.horizontal)
                
                // ✅ 전화번호 입력
                TextField("전화번호", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                // ✅ 이메일 입력 필드 & 중복 확인
                HStack {
                    TextField("이메일", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: email) { _ in
                            isEmailAvailable = nil
                            checkEmailAvailability()
                        }

                    if let isEmailAvailable = isEmailAvailable {
                        Text(isEmailAvailable ? "✅ 사용 가능" : "❌ 이미 사용 중")
                            .foregroundColor(isEmailAvailable ? .green : .red)
                            .font(.caption)
                    }
                }
                .padding(.horizontal)
                
                // ✅ 비밀번호 입력
                SecureField("비밀번호", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                // ✅ 회원가입 버튼
                Button(action: {
                    registerUser()
                }) {
                    Text("회원가입")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isFormValid() ? Color.blue : Color.gray)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .disabled(!isFormValid()) // ✅ 입력값이 모두 유효하지 않으면 버튼 비활성화
                
                // ✅ 에러 메시지
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // ✅ 회원가입 성공 메시지
                if registrationSuccess {
                    Text("회원가입 성공! 🎉")
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("메인으로 이동") {
                        showMainTabView = true
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("회원가입")
        }
        .fullScreenCover(isPresented: $showMainTabView) {
            MainTabView()
        }
    }

    // ✅ 닉네임 중복 확인 함수
    func checkNicknameAvailability() {
        guard !nickname.isEmpty else {
            isNicknameAvailable = nil
            return
        }
        
        let userRef = db.collection("users").document(nickname) // 닉네임이 문서 ID
        userRef.getDocument { document, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("🔥 닉네임 확인 실패: \(error.localizedDescription)")
                    self.isNicknameAvailable = false
                } else {
                    self.isNicknameAvailable = !(document?.exists ?? false) // ✅ 문서가 없으면 사용 가능
                }
            }
        }
    }
    
    // ✅ 이메일 중복 확인 함수
    func checkEmailAvailability() {
        guard !email.isEmpty else {
            isEmailAvailable = nil
            return
        }
        
        let lowercasedEmail = email.lowercased()

        db.collection("users")
            .whereField("email", isEqualTo: lowercasedEmail)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("🔥 Firestore 이메일 확인 실패: \(error.localizedDescription)")
                        self.isEmailAvailable = false
                    } else {
                        self.isEmailAvailable = snapshot?.documents.isEmpty ?? true
                    }
                }
            }
    }

    // ✅ 입력 필드 유효성 검사
    func isFormValid() -> Bool {
        return !nickname.isEmpty &&
               isNicknameAvailable == true &&
               !phoneNumber.isEmpty &&
               isValidEmail(email) &&
               isEmailAvailable == true &&
               password.count >= 6
    }
    
    // ✅ 회원가입 처리
    func registerUser() {
        guard isFormValid() else {
            errorMessage = "입력 정보를 확인하세요."
            return
        }
        
        // ✅ Firebase Authentication을 통해 회원가입
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = "회원가입 실패: \(error.localizedDescription)"
                self.registrationSuccess = false
            } else {
                self.errorMessage = nil
                self.registrationSuccess = true
                print("✅ 회원가입 성공: \(email)")

                // ✅ Firestore에 사용자 정보 저장 (닉네임을 문서 ID로 사용)
                let userData: [String: Any] = [
                    "email": email.lowercased(),
                    "phoneNumber": phoneNumber,
                    "createdAt": Timestamp()
                ]

                db.collection("users").document(nickname).setData(userData) { error in
                    if let error = error {
                        print("🔥 Firestore에 사용자 정보 저장 실패: \(error.localizedDescription)")
                    } else {
                        print("✅ Firestore에 사용자 정보 저장 완료!")
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.showMainTabView = true
                }
            }
        }
    }

    // ✅ 이메일 형식 유효성 검사
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
}


#Preview {
    RegistrationView()
}
