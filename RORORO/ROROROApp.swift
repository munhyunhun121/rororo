//
//  ROROROApp.swift
//  RORORO
//
//  Created by 문현권 on 2/12/25.
//

import SwiftUI
import Firebase
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct ROROROApp: App {
    init() {
        KakaoSDK.initSDK(appKey: "51cfcecf9b406b6bd821a445cffa9612")
        FirebaseApp.configure()
        print("🔥 Firebase Initialized!")
        
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView()
                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}


