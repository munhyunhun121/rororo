//
//  HomeView.swift
//  RORORO
//
//  Created by 문현권 on 2/17/25.
//

import SwiftUI

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

#Preview {
    HomeView()
}
