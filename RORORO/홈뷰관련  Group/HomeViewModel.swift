//
//  HomeModel.swift
//  RORORO
//
//  Created by 문현권 on 2/16/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class HomeViewModel: ObservableObject {
    
    @Published var partners: [Partner] = [] // ✅ 거래처 목록 저장
    @Published var totalCustomers: Int = 0 // ✅ 거래처 개수 저장
    @Published var errorMessage: String? = nil

    private let db = Firestore.firestore()

    init() {
        fetchPartners()
    }

    // ✅ Firestore에서 거래처 목록 가져오기
    func fetchPartners() {
        guard let user = Auth.auth().currentUser else {
            self.errorMessage = "❌ 로그인된 사용자가 없습니다."
            return
        }

        let usersCollection = db.collection("users")

        // 🔍 Firestore에서 사용자의 이메일을 기반으로 닉네임 검색
        usersCollection.whereField("email", isEqualTo: user.email ?? "").getDocuments { snapshot, error in
            if let error = error {
                print("🔥 Firestore 닉네임 가져오기 실패: \(error.localizedDescription)")
                self.errorMessage = "사용자 정보를 가져오지 못했습니다."
                return
            }
            
            guard let document = snapshot?.documents.first else {
                print("❌ Firestore에서 사용자를 찾을 수 없습니다.")
                self.errorMessage = "사용자 정보가 Firestore에 없습니다."
                return
            }

            let nickname = document.documentID // ✅ 닉네임을 문서 ID로 사용
            print("✅ Firestore에서 가져온 닉네임: \(nickname)")
            
            // ✅ 닉네임을 기반으로 거래처 목록 + 총 개수 가져오기
            self.loadPartners(nickname: nickname)
            self.fetchTotalCustomers(nickname: nickname) // 🔥 여기서 추가 호출
        }
    }

    // ✅ Firestore에서 거래처 개수 가져오기
    private func fetchTotalCustomers(nickname: String) {
        db.collection("users").document(nickname).collection("partners").getDocuments { snapshot, error in
            if let error = error {
                print("🔥 Firestore 거래처 개수 가져오기 실패: \(error.localizedDescription)")
                self.errorMessage = "거래처 개수를 가져오지 못했습니다."
                return
            }

            DispatchQueue.main.async {
                self.totalCustomers = snapshot?.documents.count ?? 0 // ✅ 거래처 개수 업데이트
                print("✅ Firestore에서 가져온 거래처 개수: \(self.totalCustomers)")
            }
        }
    }

    // ✅ 닉네임을 기반으로 거래처 목록 가져오기
    private func loadPartners(nickname: String) {
        db.collection("users").document(nickname).collection("partners")
            .order(by: "createdAt", descending: true) // 최신 거래처 순으로 정렬
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("🔥 Firestore 거래처 목록 가져오기 실패: \(error.localizedDescription)")
                    self.errorMessage = "거래처 정보를 가져오지 못했습니다."
                    return
                }

                DispatchQueue.main.async {
                    self.partners = snapshot?.documents.compactMap { document in
                        try? document.data(as: Partner.self) // Firestore 데이터 → 모델 변환
                    } ?? []
                    
                    // ✅ 거래처 목록을 가져온 후, 전체 거래처 수 업데이트
                    self.totalCustomers = self.partners.count
                    print("✅ Firestore에서 가져온 거래처 개수 (리스트 업데이트): \(self.totalCustomers)")
                }
            }
    }
}
