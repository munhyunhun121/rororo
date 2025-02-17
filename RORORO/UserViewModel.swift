import SwiftUI
import FirebaseAuth

class UserViewModel: ObservableObject {
    @Published var userEmail: String = ""

    init() {
        fetchUserInfo()
    }

    func fetchUserInfo() {
        if let user = Auth.auth().currentUser {
            self.userEmail = user.email ?? ""
        } else {
            self.userEmail = "User"
        }
    }
}



