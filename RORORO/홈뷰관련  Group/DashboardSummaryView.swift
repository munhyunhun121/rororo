//
//  DashboardSummaryView.swift
//  RORORO
//
//  Created by 문현권 on 2/17/25.
//

import SwiftUI



struct DashboardSummaryView: View {
    @ObservedObject var homeViewModel: HomeViewModel
  
    @State private var totalCustomers: Int = 0 // ✅ 전체 거래처 개수
    @State private var visitedCustomers = 2
    @State private var unvisitedCustomers: Int = 0 // 비지티드 Fasle 개수
    var body: some View {
        
        HStack(spacing: 12) { // 간격을 조금 줄임
            SummaryCard(title: "전체", value: "\(homeViewModel.totalCustomers)")
            SummaryCard(title: "방문", value: "\(homeViewModel.visitedCustomers)")
            SummaryCard(title: "미방문", value: "\(homeViewModel.unvisitedCustomers)")
        }
        .padding(.horizontal, 16) // 좌우 패딩 추가해서 크기 조절
        .padding(.vertical, 8) // 상하 패딩 추가
        .frame(maxWidth: 350) // 최대 가로 크기를 줄임
        .background(Color(.systemGray5)) // 배경 추가 (선택)
        .cornerRadius(12) // 둥근 모서리 추가
    }
    
}



struct SummaryCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(value)
                .font(.title2)
                .bold()
        }
        
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray5))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}




#Preview {
    DashboardSummaryView(homeViewModel: HomeViewModel())
}
