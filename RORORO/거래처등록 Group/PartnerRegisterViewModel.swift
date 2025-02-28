import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class PartnerRegisterViewModel: ObservableObject {
    @Published var userEmail: String = ""
    @Published var nickname: String? // Firestore에서 가져온 사용자 닉네임
    @Published var name: String = ""
    @Published var contact: String = ""
    @Published var address: String = ""
    @Published var visited: Bool = false
    @Published var monthlyManagementFee: String = ""
    @Published var managementArea: String = ""
    @Published var BuildingArea: String = "0"
    @Published var safetyManagerName: String = ""
    @Published var selectedOperationMonth: Int = Calendar.current.component(.month, from: Date())
    @Published var selectedComprehensiveMonth: Int? = nil
    @Published var errorMessage: String?
    @Published var isLoading: Bool = true
  

    let db = Firestore.firestore()
    let months: [Int] = Array(1...12)

    // Firestore에서 현재 로그인한 사용자의 UID로 닉네임 가져오기
    func fetchUserNickname() {
        guard let user = Auth.auth().currentUser else {
            self.errorMessage = "로그인 정보가 없습니다."
            self.isLoading = false
            return
        }

        self.userEmail = user.email ?? ""
        let usersCollection = db.collection("users")
        usersCollection.whereField("email", isEqualTo: user.email ?? "").getDocuments { snapshot, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "사용자 정보를 가져오지 못했습니다."
                    print("Error: \(error.localizedDescription)")
                } else if let document = snapshot?.documents.first {
                    let nickname = document.documentID
                    self.nickname = nickname
                    print("Nickname: \(nickname)")
                } else {
                    self.errorMessage = "사용자 정보가 Firestore에 없습니다."
                }
            }
        }
    }

    // Firestore에 거래처 추가
    func addPartner() {
        guard let nickname = nickname else {
            errorMessage = "로그인된 사용자 정보가 없습니다."
            return
        }
        guard let monthlyFee = Double(monthlyManagementFee) else {
            errorMessage = "월 관리금액을 숫자로 입력해주세요."
            return
        }
        
        

        var newPartner: [String: Any] = [
            "name": name,
            "contact": contact,
            "address": address,
            "visited": visited,
            "BuildingArea": BuildingArea,
            "monthlyManagementFee": monthlyFee,
            "managementArea": managementArea,
            "operationCheckMonth": selectedOperationMonth,
            "safetyManagerName": safetyManagerName,
            "createdAt": Timestamp(),
            "reportReceivedDate": "비어있음",
            "SubmetDate": "비어있음"
        ]

        if let comprehensiveMonth = selectedComprehensiveMonth {
            newPartner["comprehensiveCheckMonth"] = comprehensiveMonth
        }

        let partnersRef = db.collection("users").document(nickname).collection("partners")
        partnersRef.addDocument(data: newPartner) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "거래처 등록에 실패했습니다. \(error.localizedDescription)"
                    print("Error: \(error.localizedDescription)")
                } else {
                    self.name = ""
                    self.contact = ""
                    self.address = ""
                    self.visited = false
                    self.monthlyManagementFee = ""
                    self.managementArea = ""
                    self.BuildingArea = ""
                    self.safetyManagerName = ""
                    self.selectedComprehensiveMonth = nil
                    
                    self.errorMessage = "거래처가 성공적으로 등록되었습니다."
                    print("Partner 등록 완료!")
                }
            }
        }
    }
}
