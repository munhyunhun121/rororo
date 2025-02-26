import SwiftUI

struct DashboardSummaryView: View {
    @ObservedObject var homeViewModel: HomeViewModel
  
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: geometry.size.width * 0.04) { // ✅ 화면 크기에 맞춰 간격 조절
                SummaryCard(
                    title: "전체",
                    value: "\(homeViewModel.partners.count)",
                    icon: "person.3.fill",
                    color: .blue,
                    width: geometry.size.width * 0.28 // ✅ 카드 너비를 화면 크기에 맞게 조절
                )
                .onTapGesture {
                               homeViewModel.showUnvisitedOnly = false
                           }
                SummaryCard(
                    title: "방문",
                    value: "\(homeViewModel.visitedCustomers)",
                    icon: "checkmark.circle.fill",
                    color: .green,
                    width: geometry.size.width * 0.28
                )
                SummaryCard(
                    title: "미방문",
                    value: "\(homeViewModel.unvisitedPartners.count)",
                    icon: "xmark.circle.fill",
                    color: .red,
                    width: geometry.size.width * 0.28
                )
                .onTapGesture { // ✅ 미방문 카드에만 클릭 이벤트 추가
                    SoundManager.shared.playSound("mixkit-select-click-1109", fileType: "wav") // ✅ 클릭 사운드 재생
                    homeViewModel.showUnvisitedOnly = true
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, geometry.size.width * 0.05) // ✅ 좌우 패딩을 화면 크기에 맞게 조정
            .padding(.vertical, 10)
        }
        .frame(height: 120) // ✅ 카드 전체 높이를 일정하게 설정
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let width: CGFloat // ✅ 기기 크기에 맞춰 조정할 수 있도록 width 추가

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: width * 0.3)) // ✅ 아이콘 크기도 반응형으로 조정
                .foregroundColor(color)

            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)

            Text(value)
                .font(.title2)
                .bold()
                .foregroundColor(.primary)
        }
        .padding()
        .frame(width: width, height: 100) // ✅ 카드 크기를 일정하게 유지
        .background(Color.black)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, y: 2)
    }
}

#Preview {
    DashboardSummaryView(homeViewModel: HomeViewModel())
}
