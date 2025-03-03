// MARK: - Import
import SwiftUI

// MARK: - DashboardSummaryView
struct DashboardSummaryView: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @Binding var showSettingView: Bool
    @Binding var isSearching: Bool
    @Binding var showMemo: Bool
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: geometry.size.width * 0.03) {
                    summaryCards(geometry: geometry)
                }
                .padding(.horizontal, geometry.size.width * 0.01)
                .padding(.vertical, 10)
            }
        }
        .frame(height: 100)
    }

    // MARK: - Summary Cards
    @ViewBuilder
    private func summaryCards(geometry: GeometryProxy) -> some View {
        SummaryCard(title: "메모", value: "-", icon:"pencil.and.outline" , color: .blue, width: geometry.size.width * 0.22)
            .onTapGesture {
                playSoundAndSetFilter(.all)
                showMemo.toggle()
            }
        
        SummaryCard(title: "검색", value: "-", icon:"magnifyingglass.circle.fill" , color: .blue, width: geometry.size.width * 0.22)
            .onTapGesture {
                playSoundAndSetFilter(.all)
                isSearching.toggle()
                homeViewModel.searchText = "" 
            }
        SummaryCard(title: "전체", value: "\(homeViewModel.partners.count)", icon: "person.3.fill", color: .blue, width: geometry.size.width * 0.22)
            .onTapGesture {
                playSoundAndSetFilter(.all)
            }

        SummaryCard(title: "방문", value: "\(homeViewModel.visitedCustomers)", icon: "checkmark.circle.fill", color: .green, width: geometry.size.width * 0.22)
            .onTapGesture {
                playSoundAndSetFilter(.visited)
            }

        SummaryCard(title: "미방문", value: "\(homeViewModel.unvisitedPartners.count)", icon: "xmark.circle.fill", color: .red, width: geometry.size.width * 0.25)
            .onTapGesture {
                playSoundAndSetFilter(.unvisited)
            }

        SummaryCard(title: "제출", value: "\(homeViewModel.submitPartners.count)", icon: "doc.text.fill", color: .yellow, width: geometry.size.width * 0.22)
            .onTapGesture {
                playSoundAndSetFilter(.submitted)
            }

        SummaryCard(title: "설정", value: "-", icon: "gear", color: .white, width: geometry.size.width * 0.22)
            .onTapGesture {
                playSound()
                // 설정 액션 추가 가능
                showSettingView.toggle()
            }
    }

    // MARK: - Sound & Filter
    private func playSound() {
        SoundManager.shared.playSound("mixkit-select-click-1109", fileType: "wav")
    }

    private func playSoundAndSetFilter(_ filter: PartnerFilter) {
        playSound()
        homeViewModel.selectedFilter = filter
    }
}

// MARK: - SummaryCard
struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let width: CGFloat

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: width * 0.2))
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
        .frame(width: width, height: 90)
        .background(Color.black)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, y: 2)
    }
}

// MARK: - Preview
#Preview {
    DashboardSummaryView(
        homeViewModel: HomeViewModel(),
        showSettingView: .constant(false),
        isSearching: .constant(false),
        showMemo: .constant(false)
    )
}
