import Foundation
import FirebaseFirestore

struct Partner: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var contact: String
    var address: String
    var visited: Bool
    var monthlyManagementFee: Double
    var BuildingArea: String
    var managementArea: String
    var operationCheckMonth: Int // ✅ 1~12 (월만 저장)
    var comprehensiveCheckMonth: Int? // ✅ 1~12 (월만 저장)
    var safetyManagerName: String
    var createdAt: Date
}




