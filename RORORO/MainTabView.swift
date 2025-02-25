import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // ✅ FirstView와 PartnerRegisterView 중 선택된 화면을 표시
            ZStack {
                if selectedTab == 0 {
                    FirstView()
                        .padding(.bottom, 10) // ✅ 탭 바 높이만큼 여백 추가
                } else if selectedTab == 1 {
                    PartnerRegisterView()
                        .padding(.bottom, 50)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // ✅ 하단 커스텀 탭 바 (토스 스타일)
            
            HStack  {
                  Spacer()
                  CustomTabButton(title: "홈", icon: "house.fill", index: 0, selectedTab: $selectedTab)
                  Spacer()
                  CustomTabButton(title: "거래처 등록", icon: "plus.circle.fill", index: 1, selectedTab: $selectedTab)
                  Spacer()
              }
              .frame(height: 80) // ✅ 높이 조정
              .background(Color.gray.opacity(0.15)) // ✅ 연한 회색 배경
              .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous)) // ✅ 상단 라운드 처리
              .overlay(
                  RoundedRectangle(cornerRadius: 20) // ✅ 상단에 얇은 회색 선 추가
                    .stroke(Color.gray.opacity(0.9), lineWidth: 0.5)
                      .padding(.top, -1),
                  alignment: .top
              )
              .padding(.horizontal, -5) // ✅ 좌우 패딩 추가
              .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2) // ✅ 살짝 떠 있는 느낌 추가
          }
          .edgesIgnoringSafeArea(.bottom) // ✅ Safe Area 영향 제거
      }
  }


// ✅ 커스텀 탭 버튼
struct CustomTabButton: View {
    let title: String
    let icon: String
    let index: Int
    @Binding var selectedTab: Int

    var body: some View {
        Button(action: {
                selectedTab = index
        }) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(selectedTab == index ? .white : .gray)
                Text(title)
                    .font(.caption)
                    .foregroundColor(selectedTab == index ? .white : .gray)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.vertical, 5)
        }
    }
}

#Preview {
    MainTabView()
}
