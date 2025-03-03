// MARK: - Import
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// MARK: - PartnerRegisterViewModel
class PartnerRegisterViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var userEmail: String = ""
    @Published var nickname: String?
    @Published var name: String = ""
    @Published var contact: String = ""
    @Published var address: String = ""
    @Published var visited: Bool = false
    @Published var monthlyManagementFee: String = ""
    @Published var managementArea: String = ""
    @Published var buildingArea: String = ""
    @Published var safetyManagerName: String = ""
    @Published var selectedOperationMonth: Int = Calendar.current.component(.month, from: Date())
    @Published var selectedComprehensiveMonth: Int?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = true

    let db = Firestore.firestore()
    let months: [Int] = Array(1...12)

    // MARK: - Fetch User Nickname
    func fetchUserNickname() {
        guard let user = Auth.auth().currentUser else {
            self.errorMessage = "로그인 정보가 없습니다."
            self.isLoading = false
            return
        }

        self.userEmail = user.email ?? ""

        db.collection(FirestoreKeys.users)
            .whereField(FirestoreKeys.email, isEqualTo: user.email ?? "")
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        self.errorMessage = "사용자 정보를 가져오지 못했습니다."
                        print("Error: \(error.localizedDescription)")
                    } else if let document = snapshot?.documents.first {
                        self.nickname = document.documentID
                        print("Nickname: \(document.documentID)")
                    } else {
                        self.errorMessage = "사용자 정보가 Firestore에 없습니다."
                    }
                }
            }
    }

    // MARK: - Add Partner
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
            FirestoreKeys.name: name,
            FirestoreKeys.contact: contact,
            FirestoreKeys.address: address,
            FirestoreKeys.visited: visited,
            FirestoreKeys.buildingArea: buildingArea,
            FirestoreKeys.monthlyManagementFee: monthlyFee,
            FirestoreKeys.managementArea: managementArea,
            FirestoreKeys.operationCheckMonth: selectedOperationMonth,
            FirestoreKeys.safetyManagerName: safetyManagerName,
            FirestoreKeys.createdAt: Timestamp(),
            FirestoreKeys.reportReceivedDate: "비어있음",
            FirestoreKeys.submetDate: "비어있음"
        ]

        if let comprehensiveMonth = selectedComprehensiveMonth {
            newPartner[FirestoreKeys.comprehensiveCheckMonth] = comprehensiveMonth
        }

        db.collection(FirestoreKeys.users).document(nickname).collection(FirestoreKeys.partners)
            .addDocument(data: newPartner) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = "거래처 등록에 실패했습니다. \(error.localizedDescription)"
                        print("Error: \(error.localizedDescription)")
                    } else {
                        self.resetFields()
                        self.errorMessage = "거래처가 성공적으로 등록되었습니다."
                        print("Partner 등록 완료!")
                    }
                }
            }
    }

    // MARK: - Reset Fields
    private func resetFields() {
        name = ""
        contact = ""
        address = ""
        visited = false
        monthlyManagementFee = ""
        managementArea = ""
        buildingArea = ""
        safetyManagerName = ""
        selectedComprehensiveMonth = nil
    }
}
