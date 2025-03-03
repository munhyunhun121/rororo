// MARK: - Import
import SwiftUI
import FirebaseFirestore

// MARK: - HomeView
struct HomeView: View {
    @StateObject private var homeViewModel = HomeViewModel()
    @State private var showSettingView = false
    @State private var showUnvisitAllAlert = false
    @State private var isSearching = false
    @State private var showMemo = false
    @State private var memoText: String = UserDefaults.standard.string(forKey: "memoText") ?? ""

    private var columns: [GridItem] {
        if homeViewModel.selectedFilter == .submitted {
            return [GridItem(.flexible())] // 1열
        } else {
            return Array(repeating: .init(.flexible()), count: 3) // 3열
        }
    }

    
    var body: some View {
        NavigationView {
              VStack(alignment: .leading, spacing: 16) {
                  totalBuildingAreaView
                  DashboardSummaryView(homeViewModel: homeViewModel, showSettingView: $showSettingView,isSearching:$isSearching, showMemo: $showMemo)
                      .font(.headline)
                  
                  if showMemo {
                      VStack(alignment: .leading, spacing: 8) {
                          HStack {
                              Text("메모")
                                  .font(.headline)
                              Spacer()
                              Button(action: {
                                  memoText = ""
                                  UserDefaults.standard.removeObject(forKey: "memoText")
                              }) {
                                  Image(systemName: "trash")
                                      .foregroundColor(.red)
                              }
                          }

                          TextEditor(text: $memoText)
                              .frame(height: 100)
                              .padding()
                              .background(Color(UIColor.systemGray6))
                              .cornerRadius(12)
                              .shadow(radius: 3)
                              .onChange(of: memoText) { newValue in
                                  UserDefaults.standard.set(newValue, forKey: "memoText")
                              }
                      }
                      .padding(.horizontal)
                  }

                  
                  if isSearching {
                      TextField("이름으로 검색", text: $homeViewModel.searchText)
                          .textFieldStyle(RoundedBorderTextFieldStyle())
                          .padding(.horizontal)
                  }
                  
                  if showSettingView {
                      settingView
                          .padding()
                          .background(Color.white)
                          .cornerRadius(12)
                          .shadow(radius: 5)
                       
                  }
                  
                  partnerListView
              }
              .padding()
              .onAppear {
                  homeViewModel.fetchPartners()
              }
          }
      }
    
    // MARK: - settimgView
    private var settingView: some View {
        VStack {
            HStack {
                Text("설정")
                    .foregroundColor(.black)
                    .font(.headline)
                    .padding()
                Spacer()
                Button(action: {
                    showSettingView = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.red)
                }
            }
            Divider()
            
            Button(action: {
                showUnvisitAllAlert = true
            }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title2)
                    .foregroundColor(.black)
                Text("전체 거래처 미방문 처리")
                    .font(.subheadline)
                               .padding()
                               .frame(maxWidth: .infinity)
                               .background(Color.red)
                               .foregroundColor(.white)
                               .cornerRadius(12)
            }
            .padding(.top, 20)
            .alert("전체 미방문 처리", isPresented: $showUnvisitAllAlert) {
                Button("확인", role: .destructive) {
                    homeViewModel.setAllPartnersUnvisited()
                    showSettingView = false
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("모든 거래처의 방문 상태를 '미방문'으로 변경하시겠습니까?")
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding()
    }

    
    
    
    // MARK: - Total Building Area
    private var totalBuildingAreaView: some View {
        HStack {
            Text("총 면적: \(homeViewModel.totalBuildingArea, specifier: "%.0f")㎡")
                .font(.caption)
                .foregroundColor(.blue)
            Spacer()
        }
    }
    
    // MARK: - Partner List
    private var partnerListView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                if homeViewModel.displayedPartners.isEmpty {
                    emptyMessageView
                } else {
                    ForEach(homeViewModel.displayedPartners) { partner in
                        NavigationLink(destination: PartnerDetailView(partner: binding(for: partner))) {
                            if homeViewModel.selectedFilter == .submitted {
                                SubmitCardView(partner: partner)
                                    .frame(maxWidth: .infinity)
                            } else {
                                PartnerCardView(partner: partner)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Empty Message
    private var emptyMessageView: some View {
        Text(emptyMessageText)
            .foregroundColor(.red)
            .padding()
    }
    
    private var emptyMessageText: String {
        switch homeViewModel.selectedFilter {
        case .unvisited: return "미방문 거래처가 없습니다."
        case .submitted: return "제출 예정 거래처가 없습니다."
        default: return "거래처 목록이 없습니다."
        }
    }
    
    // MARK: - Partner Binding
    private func binding(for partner: Partner) -> Binding<Partner> {
        guard let index = homeViewModel.partners.firstIndex(where: { $0.id == partner.id }) else {
            fatalError("Partner not found")
        }
        return $homeViewModel.partners[index]
    }
}

// MARK: - PartnerCardView
struct PartnerCardView: View {
    var partner: Partner
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(partner.name)
                .font(.subheadline)
                .foregroundColor(.black)
            HStack {
                Text(partner.visited ? "방문함" : "미방문")
                    .font(.caption)
                    .foregroundColor(.black)
                Image(systemName: partner.visited ? "checkmark.circle.fill" : "checkmark.circle")
                    .foregroundColor(partner.visited ? .green : .gray)
                    .font(.caption)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}

// MARK: - SubmitCardView
struct SubmitCardView: View {
    var partner: Partner
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack{
                Text(partner.name)
                    .foregroundColor(.black)
                Spacer()
                VStack {
                Text("보고서 마감일")
                        .foregroundColor(.black)
                Text((partner.SubmetDate))
                    .foregroundColor(.red)
                    .font(.subheadline)
            }
//                Text("이행완료 마감일: \(partner.reportReceivedDate)")
//                    .font(.subheadline)
//                    .foregroundColor(.black)
            }
         
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}

// MARK: - Preview
#Preview {
    HomeView()
}
