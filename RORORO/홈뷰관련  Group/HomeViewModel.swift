// MARK: - Import
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// MARK: - Firestore Keys
enum FirestoreKeys {
    static let submetDate = "SubmetDate"
    static let reportReceivedDate = "reportReceivedDate"
    static let users = "users"
    static let partners = "partners"
    static let email = "email"
    static let visited = "visited"
    static let buildingArea = "BuildingArea"
    static let createdAt = "createdAt"
    static let name = "name"
    static let contact = "contact"
    static let address = "address"
    static let monthlyManagementFee = "monthlyManagementFee"
    static let managementArea = "managementArea"
    static let operationCheckMonth = "operationCheckMonth"
    static let comprehensiveCheckMonth = "comprehensiveCheckMonth"
    static let safetyManagerName = "safetyManagerName"
}




// MARK: - Partner Filter
enum PartnerFilter {
    case all, unvisited, submitted, visited
}

// MARK: - HomeViewModel
class HomeViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var partners: [Partner] = []
    @Published var unvisitedPartners: [Partner] = []
    @Published var visitedPartners: [Partner] = []
    @Published var submitPartners: [Partner] = []
    @Published var selectedFilter: PartnerFilter = .all
    @Published var totalCustomers: Int = 0
    @Published var unvisitedCustomers: Int = 0
    @Published var visitedCustomers: Int = 0
    @Published var totalBuildingArea: Double = 0.0
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""
    private let db = Firestore.firestore()

    // MARK: - Computed Properties
    var displayedPartners: [Partner] {
        let filtered: [Partner]
        switch selectedFilter {
        case .all: filtered = partners
        case .unvisited: filtered = unvisitedPartners
        case .submitted: filtered = submitPartners
        case .visited: filtered = visitedPartners
        }
        
        if searchText.isEmpty {
            return filtered
        } else {
            return filtered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    // MARK: - Init
    init() {
        fetchPartners()
    }

    // MARK: - Helper Methods
    private func fetchNickname(completion: @escaping (String?) -> Void) {
        guard let email = Auth.auth().currentUser?.email else {
            completion(nil)
            return
        }

        db.collection(FirestoreKeys.users)
            .whereField(FirestoreKeys.email, isEqualTo: email)
            .getDocuments { snapshot, error in
                completion(snapshot?.documents.first?.documentID)
            }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter.string(from: date)
    }

    // MARK: - Fetch Methods
    func fetchPartners() {
        fetchNickname { [weak self] nickname in
            guard let self = self, let nickname = nickname else { return }
            self.loadPartners(nickname: nickname)
            self.fetchTotalCustomers(nickname: nickname)
            self.fetchUnvisitedCustomers(nickname: nickname)
            self.fetchTotalBuildingArea(nickname: nickname)
        }
    }

    private func loadPartners(nickname: String) {
        db.collection(FirestoreKeys.users).document(nickname).collection(FirestoreKeys.partners)
            .order(by: FirestoreKeys.createdAt, descending: true)
            .addSnapshotListener { snapshot, error in
                DispatchQueue.main.async {
                    self.partners = snapshot?.documents.compactMap { try? $0.data(as: Partner.self) } ?? []
                    self.unvisitedPartners = self.partners.filter { !$0.visited }
                    self.visitedPartners = self.partners.filter { $0.visited }
                    self.submitPartners = self.partners.filter { $0.SubmetDate != "비어있음" }
                    self.totalCustomers = self.partners.count
                }
            }
    }

    private func fetchTotalCustomers(nickname: String) {
        db.collection(FirestoreKeys.users).document(nickname).collection(FirestoreKeys.partners)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    self.totalCustomers = snapshot?.documents.count ?? 0
                }
            }
    }

    private func fetchUnvisitedCustomers(nickname: String) {
        db.collection(FirestoreKeys.users).document(nickname).collection(FirestoreKeys.partners)
            .addSnapshotListener { snapshot, error in
                DispatchQueue.main.async {
                    self.visitedCustomers = snapshot?.documents.filter { ($0.data()[FirestoreKeys.visited] as? Bool) == true }.count ?? 0
                    self.unvisitedCustomers = snapshot?.documents.filter { ($0.data()[FirestoreKeys.visited] as? Bool) == false }.count ?? 0
                }
            }
    }

    private func fetchTotalBuildingArea(nickname: String) {
        db.collection(FirestoreKeys.users).document(nickname).collection(FirestoreKeys.partners)
            .getDocuments { snapshot, error in
                let total = snapshot?.documents.reduce(0.0) { sum, doc in
                    if let area = Double(doc.data()[FirestoreKeys.buildingArea] as? String ?? "0") {
                        return sum + area
                    }
                    return sum
                } ?? 0.0
                DispatchQueue.main.async {
                    self.totalBuildingArea = total
                }
            }
    }

    // MARK: - Update Methods
    func updatePartner(_ partner: Partner) {
        fetchNickname { [weak self] nickname in
            guard let self = self, let nickname = nickname, let partnerId = partner.id else { return }

            let data: [String: Any] = [
                FirestoreKeys.name: partner.name,
                FirestoreKeys.contact: partner.contact,
                FirestoreKeys.address: partner.address,
                FirestoreKeys.visited: partner.visited,
                FirestoreKeys.buildingArea: partner.BuildingArea,
                FirestoreKeys.monthlyManagementFee: partner.monthlyManagementFee,
                FirestoreKeys.managementArea: partner.managementArea,
                FirestoreKeys.operationCheckMonth: partner.operationCheckMonth,
                FirestoreKeys.comprehensiveCheckMonth: partner.comprehensiveCheckMonth ?? NSNull(),
                FirestoreKeys.safetyManagerName: partner.safetyManagerName
            ]

            self.db.collection(FirestoreKeys.users).document(nickname).collection(FirestoreKeys.partners).document(partnerId).updateData(data)
        }
    }
    
    // MARK: - Update All Partners
    func setAllPartnersUnvisited() {
        fetchNickname { [weak self] nickname in
            guard let self = self, let nickname = nickname else { return }
            
            let partnersRef = self.db.collection(FirestoreKeys.users)
                .document(nickname)
                .collection(FirestoreKeys.partners)
            
            partnersRef.getDocuments { snapshot, error in
                if let error = error {
                    print("❌ 전체 미방문 설정 실패: \(error.localizedDescription)")
                    return
                }
                
                let batch = self.db.batch()
                
                snapshot?.documents.forEach { document in
                    let partnerRef = partnersRef.document(document.documentID)
                    batch.updateData([FirestoreKeys.visited: false], forDocument: partnerRef)
                }
                
                batch.commit { error in
                    if let error = error {
                        print("❌ 전체 미방문 업데이트 실패: \(error.localizedDescription)")
                    } else {
                        print("✅ 전체 거래처 미방문으로 설정 완료!")
                        // ✅ 변경사항 반영을 위해 다시 불러오기
                        self.fetchPartners()
                    }
                }
            }
        }
    }


    // MARK: - Delete Methods
    func deletePartner(_ partner: Partner) {
        fetchNickname { [weak self] nickname in
            guard let self = self, let nickname = nickname, let partnerId = partner.id else { return }

            self.db.collection(FirestoreKeys.users).document(nickname).collection(FirestoreKeys.partners).document(partnerId).delete()
        }
    }
}
