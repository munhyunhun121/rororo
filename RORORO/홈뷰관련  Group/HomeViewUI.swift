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

    let columns: [GridItem] = [
        GridItem(.flexible()), // 첫 번째 열
        GridItem(.flexible()), // 두 번째 열
        GridItem(.flexible())  // 세 번째 열
    ]

    var body: some View {
        VStack {
            DashboardSummaryView(homeViewModel: homeViewModel)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    if let errorMessage = homeViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        ForEach(homeViewModel.partners) { partner in
                            PartnerCardView(partner: partner)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding()
            }
        }
    }
}


struct Partner: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var contact: String
    var address: String
    var visited: Bool
    var monthlyManagementFee: Double
    var managementArea: String
    var operationCheckMonth: Int // ✅ 1~12 (월만 저장)
    var comprehensiveCheckMonth: Int? // ✅ 1~12 (월만 저장)
    var safetyManagerName: String
    var createdAt: Date
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
