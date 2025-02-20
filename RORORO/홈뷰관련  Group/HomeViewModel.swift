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
    
    @Published var unvisitedCustomers: Int = 0
    @Published var visitedCustomers: Int = 0
    
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
            self.fetchTotalCustomers(nickname: nickname)
            self.fetchUnvisitedCustomers(nickname: nickname)// 🔥 여기서 추가 호출
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
                    print("✅ Firestore에서 가져온 거래처 목록 ddddd(리스트 업데이트): \(self.totalCustomers)")
            
                }
            }
    }
    

    
 
    private func fetchUnvisitedCustomers(nickname: String) {
        
        //이 함수는 잘 동작 함 /. firebase에서 값을 변경했을때 대쉬보드에 잘 들어감 //
        
        db.collection("users").document(nickname).collection("partners")
               .addSnapshotListener { snapshot, error in
                   if let error = error {
                       print("🔥 Firestore 거래처 개수 가져오기 실패: \(error.localizedDescription)")
                       self.errorMessage = "거래처 정보를 가져오지 못했습니다."
                       return
                   }

                   DispatchQueue.main.async {
                       // 방문한 거래처 개수
                       self.visitedCustomers = snapshot?.documents.filter {
                           ($0.data()["visited"] as? Bool) == true
                       }.count ?? 0

                       // 방문하지 않은 거래처 개수
                       self.unvisitedCustomers = snapshot?.documents.filter {
                           ($0.data()["visited"] as? Bool) == false
                       }.count ?? 0

                       print("✅ 방문한 거래처 개수: \(self.visitedCustomers)")
                       print("✅ 방문하지 않은 거래처 개수: \(self.unvisitedCustomers)")
                   }
               }
       }
 
    
    func updatePartner(_ partner: Partner) {
          guard let partnerId = partner.id else {
              print("❌ partner.id 없음. Firestore 업데이트 불가")
              return
          }
          
          guard let user = Auth.auth().currentUser else {
              print("❌ 로그인된 사용자가 없습니다.")
              return
          }

          // 닉네임 가져오기
          db.collection("users")
              .whereField("email", isEqualTo: user.email ?? "")
              .getDocuments { snapshot, error in
                  if let error = error {
                      print("🔥 Firestore 닉네임 가져오기 실패: \(error.localizedDescription)")
                      return
                  }
                  
                  guard let document = snapshot?.documents.first else {
                      print("❌ Firestore에서 닉네임을 찾을 수 없습니다.")
                      return
                  }
                  
                  let nickname = document.documentID
                  
                  // 업데이트할 데이터 준비
                  let updatedData: [String: Any] = [
                      "name": partner.name,
                      "contact": partner.contact,
                      "address": partner.address,
                      "visited": partner.visited,
                      "monthlyManagementFee": partner.monthlyManagementFee,
                      "managementArea": partner.managementArea,
                      "operationCheckMonth": partner.operationCheckMonth,
                      "comprehensiveCheckMonth": partner.comprehensiveCheckMonth ?? NSNull(),
                      "safetyManagerName": partner.safetyManagerName
                  ]
                  
                  // Firestore 업데이트
                  self.db.collection("users")
                      .document(nickname)
                      .collection("partners")
                      .document(partnerId)
                      .updateData(updatedData) { error in
                          if let error = error {
                              print("🔥 Firestore 업데이트 실패: \(error.localizedDescription)")
                          } else {
                              print("✅ Firestore 업데이트 성공! (파트너 ID: \(partnerId))")
                              self.fetchPartners()
                          }
                      }
              }
      }
  }




