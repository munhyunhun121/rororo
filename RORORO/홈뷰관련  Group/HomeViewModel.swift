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
    
    @Published var submitPartners: [Partner] = [] // ✅ 제출될 거래처 저장 배열
    @Published var selectedFilter: PartnerFilter = .all
    
    @Published var partners: [Partner] = [] // ✅ 거래처 목록 저장
    @Published var unvisitedPartners: [Partner] = [] // ✅ 미방문 거래처 리스트 //로드파트너스에서 가저옴 
    @Published var SubmetDate: [Partner] = []
    @Published var showUnvisitedOnly: Bool = false
    @Published var totalCustomers: Int = 0 // ✅ 거래처 개수 저장
    @Published var errorMessage: String? = nil
    @Published var unvisitedCustomers: Int = 0
    @Published var visitedCustomers: Int = 0
    @Published var totalBuildingArea: Double = 0.0
    private let db = Firestore.firestore()

    init() {
    
        fetchPartners()
        
       
    }
    var displayedPartners: [Partner] {
          switch selectedFilter {
          case .all:
              return partners
          case .unvisited:
              return unvisitedPartners
          case .submitted:
              return submitPartners
          }
      }

    enum PartnerFilter {
        case all        // 전체 거래처
        case unvisited  // 미방문 거래처
        case submitted  // 제출된 거래처
    }
    
    
//    func addFieldsToAllDocuments() {
//        let db = Firestore.firestore()
//        let collectionRef = db.collection("partners") // ✅ 컬렉션 이름 확인!
//
//        collectionRef.getDocuments { snapshot, error in
//            if let error = error {
//                print("Firestore 문서 가져오기 실패: \(error.localizedDescription)")
//                return
//            }
//
//            guard let documents = snapshot?.documents else { return }
//
//            for document in documents {
//                let nickname = document.documentID
//
//                let updateData: [String: Any] = [
//                    "SubmetDate": "날짜 없음",  // ✅ 기본값 설정
//                    "reportReceivedDate": "날짜 없음"  // ✅ 기본값 설정
//                ]
//
//                // ✅ 기존 데이터 유지하면서 새로운 필드 추가
//                collectionRef.document(nickname).setData(updateData, merge: true) { error in
//                    if let error = error {
//                        print("문서 \(nickname) 업데이트 실패: \(error.localizedDescription)")
//                    } else {
//                        print("문서 \(nickname)에 SubmetDate 및 reportReceivedDate 추가 완료! (기본값: '날짜 없음')")
//                    }
//                }
//            }
//        }
//    }



    func addFieldsToAllUserPartners() {
        guard let user = Auth.auth().currentUser else {
            print("❌ 로그인된 사용자가 없습니다.")
            return
        }

        let db = Firestore.firestore()

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
                let partnersRef = db.collection("users").document(nickname).collection("partners")

                partnersRef.getDocuments { snapshot, error in
                    if let error = error {
                        print("🔥 Firestore에서 파트너 문서 가져오기 실패: \(error.localizedDescription)")
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        print("❌ 파트너 문서가 없습니다.")
                        return
                    }

                    for document in documents {
                        let partnerRef = partnersRef.document(document.documentID)

                        let updateData: [String: Any] = [
                            "SubmetDate": "비어있음",
                            "reportReceivedDate": "비어있음"
                        ]

                        partnerRef.setData(updateData, merge: true) { error in
                            if let error = error {
                                print("🔥 문서 \(document.documentID) 업데이트 실패: \(error.localizedDescription)")
                            } else {
                                print("✅ 문서 \(document.documentID) Firestore에 기본값 저장 완료! (SubmetDate: 비어있음)")
                            }
                        }
                    }
                }
            }
    }


  

    
    func fetchTotalBuildingArea() { // HomeViewUI에서 뷰가 실행될떄 켜지는 코드 onappear에 뷰가로드될떄 실행되게 해놓음
            guard let user = Auth.auth().currentUser else {
                print("❌ 로그인된 사용자가 없습니다.")
                self.totalBuildingArea = 0.0
                return
            }

            db.collection("users").whereField("email", isEqualTo: user.email ?? "").getDocuments { snapshot, error in
                if let error = error {
                    print("🔥 Firestore 닉네임 가져오기 실패: \(error.localizedDescription)")
                    self.totalBuildingArea = 0.0
                    return
                }

                guard let document = snapshot?.documents.first else {
                    print("❌ Firestore에서 사용자를 찾을 수 없습니다.")
                    self.totalBuildingArea = 0.0
                    return
                }

                let nickname = document.documentID
                print("✅ Firestore에서 가져온 닉네임: \(nickname)")

                self.db.collection("users").document(nickname).collection("partners").getDocuments { snapshot, error in
                    if let error = error {
                        print("🔥 Firestore 거래처 목록 가져오기 실패: \(error.localizedDescription)")
                        self.totalBuildingArea = 0.0
                        return
                    }

                    let total = snapshot?.documents.reduce(0.0) { sum, document in
                        if let areaString = document.data()["BuildingArea"] as? String,
                           let area = Double(areaString) {
                            return sum + area
                        } else {
                            return sum
                        }
                    } ?? 0.0

                    print("✅ 총 건물 면적 합산 완료: \(total)㎡")
                    
                    // 🔥 UI 업데이트 (메인 스레드에서 실행)
                    DispatchQueue.main.async {
                        self.totalBuildingArea = total
                    }
                }
            }
        }

    
    // ✅ Firestore에서 거래처 목록 가져오기
    func fetchPartners() {
        print("✅ Firestore에서 거래처 목록 가져오기")
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
                    self.unvisitedPartners = self.partners.filter { !$0.visited }
                    // ✅ 거래처 목록을 가져온 후, 전체 거래처 수 업데이트
                    self.totalCustomers = self.partners.count
                    print("✅ Firestore에서 가져온 거래처 목록 ddddd(리스트 업데이트): \(self.totalCustomers)")
                    
                    self.submitPartners = self.partners.filter { $0.SubmetDate != "비어있음" }
            
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
                      "BuildingArea": partner.BuildingArea,
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
    
    

    
    
    func deletePartner(_ partner: Partner) {
        guard let partnerId = partner.id else {
            print("❌ partner.id 없음. Firestore 삭제 불가")
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
                
                // 파트너 문서 삭제
                self.db.collection("users")
                    .document(nickname)
                    .collection("partners")
                    .document(partnerId)
                    .delete { error in
                        if let error = error {
                            print("🔥 Firestore 삭제 실패: \(error.localizedDescription)")
                        } else {
                            print("✅ Firestore 삭제 성공! (파트너 ID: \(partnerId))")
                            // 삭제 후 최신화 위해 파트너 목록 다시 불러오기
                            self.fetchPartners()
                        }
                    }
            }
    }

    func formattedDate(_ date: Date) -> String {
           let formatter = DateFormatter()
           formatter.dateFormat = "yyyy년 MM월 dd일"
           return formatter.string(from: date)
       }
   
    
    
  }




