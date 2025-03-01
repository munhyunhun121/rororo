//
//  HomeView.swift
//  RORORO
//
//  Created by 문현권 on 2/17/25.
//


import FirebaseFirestore
import SwiftUI

struct HomeView: View {
     @StateObject private var homeViewModel = HomeViewModel()
   

     @State private var totalCustomers: Int = 0 // ✅ 전체 거래처 개수
     @State private var visitedCustomers = 0
     @State private var notVisitedCustomers = 0
    
    let columns: [GridItem] = [
        GridItem(.flexible()), // 첫 번째 열
        GridItem(.flexible()), // 두 번째 열
        GridItem(.flexible())  // 세 번째 열
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                HStack{
                    Text("총 면적:\(homeViewModel.totalBuildingArea, specifier: "%.0f")㎡")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                }
                DashboardSummaryView(homeViewModel: homeViewModel)
                    .font(.headline)
                    .padding()
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        if homeViewModel.displayedPartners.isEmpty {
                                  Text(
                                      homeViewModel.selectedFilter == .unvisited ? "미방문 거래처가 없습니다." :
                                      homeViewModel.selectedFilter == .submitted ? "제출된 거래처가 없습니다." :
                                      "거래처 목록이 없습니다."
                                  )
                                  .foregroundColor(.red)
                                  .padding()
                        } else {
                            ForEach(homeViewModel.displayedPartners) { partner in
                                NavigationLink(
                                    destination: PartnerDetailView(partner: $homeViewModel.partners[
                                        homeViewModel.partners.firstIndex(where: { $0.id == partner.id })!
                                    ]
                                                                  )
                                ) {
                                    PartnerCardView(partner: partner)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                    }
                }
            }
                    .padding()
                }
                .onAppear {
                    homeViewModel.fetchTotalBuildingArea()
                    homeViewModel.fetchPartners()
                   
                    // 🔄 뷰가 나타날 때 자동으로 데이터 로드
                }
            }
        }





struct PartnerCardView: View {
    var partner: Partner
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
           
            Text(partner.name)
                .font(.subheadline)
                .foregroundColor(.black)
                .font(.caption)
            HStack {
                 // 방문 여부를 체크표시로 표시
                Text(partner.visited ? "방문함" : "미방문")
                    .font(.caption)
                                   .foregroundColor(.black)
                                   .font(.caption)
                Image(systemName: partner.visited ? "checkmark.circle.fill" : "checkmark.circle")
                    .foregroundColor(partner.visited ? .green : .gray) // 방문 여부에 따라 색을 변경
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
#Preview {
    HomeView()
}

