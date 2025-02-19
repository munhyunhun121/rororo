//import SwiftUI
//import FirebaseAuth
//import FirebaseFirestore
//
//struct PartnerListView: View {
//    
//    @StateObject private var userViewModel = UserViewModel()
//    @State private var partners: [Partner] = []
//    private let db = Firestore.firestore()
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                // ✅ 이메일 앞부분(아이디 부분)만 추출하여 환영 메시지 표시
//                              if let username = userViewModel.userEmail.split(separator: "@").first {
//                                  Text("\(username)님, 환영합니다!")
//                                      .font(.title2)
//                                      .bold()
//                                      .padding()
//                              } else {
//                                  Text("환영합니다!")
//                                      .font(.title2)
//                                      .bold()
//                                      .padding()
//                              }
//                ScrollView {
//                    VStack(spacing: 10) {
//                        ForEach(partners) { partner in
//                            PartnerCardView(partner: partner)
//                        }
//                    }
//                    .padding()
//                }
//                Spacer()
//            }
//            .navigationBarItems(trailing: Button(action: {
//                addPartner() // 새로운 파트너 추가 함수 호출
//            }, label: {
//                Image(systemName: "plus")
//            }))
//            .onAppear {
//                fetchPartners()
//            }
//        }
//    }
//
//    // 현재 로그인한 사용자의 UID를 사용하여 "users/{uid}/partners" 서브컬렉션에서 데이터를 가져옴
//    func fetchPartners() {
//        guard let uid = Auth.auth().currentUser?.uid else {
//            print("현재 로그인한 사용자가 없습니다.")
//            return
//        }
//        
//        db.collection("users")
//            .document(uid)
//            .collection("partners")
//            .order(by: "createdAt", descending: true)
//            .addSnapshotListener { snapshot, error in
//                if let error = error {
//                    print("🔥 Firestore 데이터 가져오기 실패: \(error.localizedDescription)")
//                    return
//                }
//                
//                guard let documents = snapshot?.documents else { return }
//                self.partners = documents.compactMap { doc in
//                    try? doc.data(as: Partner.self)
//                }
//            }
//    }
//    
//    // 새로운 파트너 데이터를 추가하는 함수
//    func addPartner() {
//        guard let uid = Auth.auth().currentUser?.uid else {
//            print("사용자가 로그인되어 있지 않습니다.")
//            return
//        }
//        
//        // 예시 데이터: 실제 앱에서는 사용자가 입력한 데이터를 사용
//        let newPartner = Partner(
//            name: "새 거래처",
//            contact: "010-1234-5678",
//            address: "서울특별시 강남구",
//            createdAt: Date()
//        )
//        
//        do {
//            _ = try db.collection("users")
//                .document(uid)
//                .collection("partners")
//                .addDocument(from: newPartner)
//            print("거래처 데이터 추가 성공")
//        } catch {
//            print("거래처 데이터 추가 실패: \(error.localizedDescription)")
//        }
//    }
//}
//
//
//
//struct Partner: Identifiable, Codable {
//    @DocumentID var id: String?
//    var name: String
//    var contact: String
//    var address: String
//    var createdAt: Date
//}
//
//#Preview {
//    PartnerListView()
//}
//
