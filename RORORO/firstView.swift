import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct FirstView: View {
 
    @StateObject private var userViewModel = UserViewModel()
  
    @State private var isLoggedOut: Bool = false
    @State private var selectedTab: Int = 0 // ✅

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) { // ✅ 위아래 균형 맞추기
                    HStack {
                        Text("\(userViewModel.userEmail)님, 환영합니다! 🎉")
                            .foregroundColor(.white)
                            .font(.system(size: 15, weight: .medium))
                            .padding(.vertical, 4) // ✅ 상하 패딩 줄이기 (박스 높이
                            .padding(.horizontal, 8)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(8)
                        
                        Spacer() // ✅ 오른쪽 정렬을 유지하기 위해 Spacer 추가
                    }
                    .frame(maxWidth: .infinity, alignment: .leading) // ✅ 전체 너비를 차지한 상태에서 왼쪽 정렬
                    .padding(.leading, 1) //
                    
                    // ✅ 상단 탭 바 (토스증권 홈 / 관심 / 발견 / 피드)
                    HStack(spacing: 0) {
                        TabButton(title: "홈", index: 0, selectedTab: $selectedTab)
                        TabButton(title: "거래처등록", index: 1, selectedTab: $selectedTab)
                        TabButton(title: "발견", index: 2, selectedTab: $selectedTab)
                        TabButton(title: "피드", index: 3, selectedTab: $selectedTab)
                    }
                    .frame(width: geometry.size.width, height: 50)
                    .background(Color.black)
                    
                    Divider().background(Color.gray.opacity(0.5))

                    // ✅ 선택된 탭에 따라 다른 콘텐츠 표시 (스크롤 가능하도록 변경)
                   // ScrollView(.vertical, showsIndicators: false) {
                        VStack {
                            if selectedTab == 0 {
                                HomeView()
                            } else if selectedTab == 1 {
                                ProfileView()
                            } else if selectedTab == 2 {
                                SettingsView()
                            } else if selectedTab == 3 {
                                InfoView()
                            }
                        }
                        .frame(width: geometry.size.width * 0.95) // ✅ 가로를 꽉 채우되 살짝 남기기
                        .padding(.top, 10)
                    

                    Spacer()

                    // ✅ 로그아웃 버튼
//                    Button(action: {
//                        logout()
//                    }) {
//                        Text("로그아웃")
//                            .foregroundColor(.white)
//                            .font(.system(size: 18, weight: .bold))
//                            .frame(width: geometry.size.width * 0.8, height: 50)
//                            .background(Color.red)
//                            .cornerRadius(12)
//                    }
//                    .padding(.bottom, 20)
//                    .fullScreenCover(isPresented: $isLoggedOut) {
//                        LoginView()
//                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(Color.black)
                .foregroundColor(.white)
                .navigationTitle("JATAM")
                .navigationBarHidden(true)
            }
        }
    }

    // ✅ 로그아웃 함수
    func logout() {
        do {
            try Auth.auth().signOut()
            isLoggedOut = true
        } catch {
            print("로그아웃 실패: \(error.localizedDescription)")
        }
    }
}

// ✅ 상단 탭 버튼 컴포넌트 (가운데 정렬 및 크기 균일하게)
struct TabButton: View {
    let title: String
    let index: Int
    @Binding var selectedTab: Int
    
    var body: some View {
        Button(action: {
            selectedTab = index
        }) {
            Text(title)
                .foregroundColor(selectedTab == index ? .white : .gray)
                .font(.system(size: 13, weight: selectedTab == index ? .bold : .regular))
                .frame(maxWidth: .infinity, maxHeight: 30)
                .background(selectedTab == index ? Color.gray.opacity(0.2) : Color.clear)
        }
    }
}

// ✅ 스크롤 가능한 샘플 뷰 (각 탭에 표시될 화면)
struct HomeView: View {
    @StateObject private var homeViewModel = HomeViewModel()
  
    var body: some View {
        VStack{
            DashboardSummaryView(homeViewModel: HomeViewModel())
        }
           ScrollView {
               VStack(spacing: 10) {
                   if let errorMessage = homeViewModel.errorMessage {
                       Text(errorMessage)
                           .foregroundColor(.red)
                           .padding()
                   } else {
                       ForEach(homeViewModel.partners) { partner in
                           PartnerCardView(partner: partner)
                       }
                   }
               }
               .padding()
           }
       }
   }


struct ProfileView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(0..<8) { index in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: UIScreen.main.bounds.width * 0.9, height: 100)
                        .overlay(Text("📌 거래처 섹션 \(index + 1)").foregroundColor(.white))
                }
            }
            .padding(.vertical)
        }
    }
}

struct SettingsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(0..<6) { index in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: UIScreen.main.bounds.width * 0.9, height: 100)
                        .overlay(Text("🔍 발견 섹션 \(index + 1)").foregroundColor(.white))
                }
            }
            .padding(.vertical)
        }
    }
}

struct InfoView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(0..<5) { index in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: UIScreen.main.bounds.width * 0.9, height: 100)
                        .overlay(Text("📰 피드 섹션 \(index + 1)").foregroundColor(.white))
                }
            }
            .padding(.vertical)
        }
    }
}



#Preview {
    FirstView()
}
