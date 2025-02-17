import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginView: View {
    
    @State private var email: String = UserDefaults.standard.string(forKey: "lastEmail") ?? "" // ✅ 마지막 로그인 이메일 불러오기
    @State private var password: String = ""
    @State private var errorMessage: String? = nil
    @State private var showMainTabView: Bool = false  // 로그인 성공 후 MainTabView로 이동
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: {
                    loginUser()
                }) {
                    Text("Login")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // 에러 메시지 표시
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // 회원가입 화면으로 이동 버튼
                NavigationLink("회원가입", destination: RegistrationView())
                    .padding(.bottom, 20)
            }
            .padding()
            .navigationTitle("JATAM")
            .toolbar {
                ToolbarItem(placement: .principal) { // ✅ 타이틀 중앙 정렬
                    Text("로그인")
                        .font(.headline)
                        .foregroundColor(.black)
                }
            }
            .fullScreenCover(isPresented: $showMainTabView) {
                MainTabView() // ✅ 로그인 성공 후 MainTabView로 이동
            }
        }
    }
    
    // ✅ Firebase 로그인 함수 (마지막 이메일 저장 기능 추가)
    func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = "로그인 실패: \(error.localizedDescription)"
                return
            }
            
            guard let user = authResult?.user else { return }
            
            // ✅ Firestore에서 로그인한 사용자의 추가 정보 가져오기
            let userRef = Firestore.firestore().collection("users").document(user.uid)
            
            userRef.getDocument { document, error in
                if let error = error {
                    print("🔥 Firestore 유저 정보 가져오기 실패: \(error.localizedDescription)")
                } else if let document = document, document.exists {
                    let data = document.data()
                    let nickname = data?["nickname"] as? String ?? "닉네임 없음"
                    let phoneNumber = data?["phoneNumber"] as? String ?? "전화번호 없음"
                    
                    // ✅ UserDefaults에 사용자 정보 저장 (필요할 경우 사용)
                    UserDefaults.standard.set(user.uid, forKey: "userUID")
                    UserDefaults.standard.set(nickname, forKey: "nickname")
                    UserDefaults.standard.set(phoneNumber, forKey: "phoneNumber")
                    
                    print("✅ 로그인한 사용자 정보: 닉네임: \(nickname), 전화번호: \(phoneNumber)")
                }
            }
            
            // ✅ 로그인 성공 시 이메일 저장
            UserDefaults.standard.set(email, forKey: "lastEmail")
            
            // ✅ 로그인 성공 후 MainTabView로 이동
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showMainTabView = true
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
