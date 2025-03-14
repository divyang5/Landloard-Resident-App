import Foundation
import FirebaseAuth
import FirebaseFirestore

class FireAuthHelper: ObservableObject {
    static let shared = FireAuthHelper()
    private var db = Firestore.firestore()
    
    var user: User?
    var userRole: String?
    
    // Add this method for anonymous login
    func signInAnonymously() async -> String {
        do {
            let res = try await Auth.auth().signInAnonymously()
            self.user = res.user
            self.userRole = "Anonymous" // Set a role for anonymous users if needed
            // Clear any stored user data
            UserDefaults.standard.removeObject(forKey: "USER_EMAIL")
            UserDefaults.standard.removeObject(forKey: "USER_PASSWORD")
            UserDefaults.standard.removeObject(forKey: "USER_TYPE")
        } catch {
            print("Error signing in anonymously: \(error.localizedDescription)")
            return error.localizedDescription
        }
        return ""
    }
    
    func signUp1(email: String, password: String, rememberMe: Bool) async -> String{
        do {
            let res = try await Auth.auth().createUser(withEmail: email, password: password)
            self.user = res.user
            try await db.collection("Roles").document(self.user!.uid).setData([
                "email": email,
                "userRole": "Tenant"
            ])
            self.userRole = "Tenant"
            if rememberMe {
                UserDefaults.standard.set(self.user?.email, forKey: "USER_EMAIL")
                UserDefaults.standard.set(password, forKey: "USER_PASSWORD")
                UserDefaults.standard.set(self.userRole, forKey: "USER_TYPE")
            }
        }
        catch {
            print("Error while signing up: \(error.localizedDescription)")
            return error.localizedDescription
        }
        return ""
    }
    
    func signUp2(email: String, password: String, rememberMe: Bool) async -> String{
        do {
            let res = try await Auth.auth().createUser(withEmail: email, password: password)
            self.user = res.user
            try await db.collection("Roles").document(self.user!.uid).setData([
                "email": email,
                "userRole": "Landlord"
            ])
            self.userRole = "Landlord"
            if rememberMe {
                UserDefaults.standard.set(self.user?.email, forKey: "USER_EMAIL")
                UserDefaults.standard.set(password, forKey: "USER_PASSWORD")
                UserDefaults.standard.set(self.userRole, forKey: "USER_TYPE")
            }
        }
        catch {
            print("Error while signing up: \(error.localizedDescription)")
            return error.localizedDescription
        }
        return ""
    }
    
    func signIn1(email: String, password: String, rememberMe: Bool) async -> String{
        do {
            let res = try await Auth.auth().signIn(withEmail: email, password: password)
            self.user = res.user
            let res2 = try await db.collection("Roles").document(self.user!.uid).getDocument()
            if res2.exists, let userRole = res2.get("userRole") as? String {
                self.userRole = userRole
            } else {
                throw NSError(domain: "FirestoreError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User document not found or userRole missing."])
            }
            if(self.userRole != "Tenant"){
                throw NSError(domain: "FirestoreError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User document not found or userRole missing."])
            }
            if rememberMe {
                UserDefaults.standard.set(self.user?.email, forKey: "USER_EMAIL")
                UserDefaults.standard.set(password, forKey: "USER_PASSWORD")
                UserDefaults.standard.set(self.userRole, forKey: "USER_TYPE")
            }
        }
        catch {
            print("Error while signing in: \(error.localizedDescription)")
            return error.localizedDescription
        }
        return ""
    }
    
    func signIn2(email: String, password: String, rememberMe: Bool) async -> String{
        do {
            let res = try await Auth.auth().signIn(withEmail: email, password: password)
            self.user = res.user
            let res2 = try await db.collection("Roles").document(self.user!.uid).getDocument()
            if res2.exists, let userRole = res2.get("userRole") as? String {
                self.userRole = userRole
            } else {
                throw NSError(domain: "FirestoreError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User document not found or userRole missing."])
            }
            if(self.userRole != "Landlord"){
                throw NSError(domain: "FirestoreError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User document not found or userRole missing."])
            }
            if rememberMe {
                UserDefaults.standard.set(self.user?.email, forKey: "USER_EMAIL")
                UserDefaults.standard.set(password, forKey: "USER_PASSWORD")
                UserDefaults.standard.set(self.userRole, forKey: "USER_TYPE")
            }
        }
        catch {
            print("Error while signing in: \(error.localizedDescription)")
            return error.localizedDescription
        }
        return ""
    }
    
    func changePassword(oldPassword: String, newPassword: String) async -> String{
        do {
            guard let user = self.user else {
                throw NSError(domain: "FirestoreError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not signed in."])
            }
            
            let credential = EmailAuthProvider.credential(withEmail: user.email!, password: oldPassword)

            try await user.reauthenticate(with: credential)
            try await user.updatePassword(to: newPassword)
        }
        catch {
            print("Error changing password: \(error.localizedDescription)")
            return error.localizedDescription
        }
        return ""
    }
    
    func getProfile() async -> (name: String, contact: String, cardName: String, cardNumber: String, cardExpiry: String, cardCvv: String)? {
        do {
            let document = try await db.collection("users").document(self.user!.uid).getDocument()
            if document.exists {
                return (name: document.get("name"), contact: document.get("contact"), cardName: document.get("cardName"), cardNumber: document.get("cardNumber"), cardExpiry: document.get("cardExpiry"), cardCvv: document.get("cardCvv")) as? (name: String, contact: String, cardName: String, cardNumber: String, cardExpiry: String, cardCvv: String)
            }
        }
        catch {
            print(error.localizedDescription)
        }
        return (name: "", contact: "", cardName: "", cardNumber: "", cardExpiry: "", cardCvv: "")
    }
    
    func saveProfile(name: String, contact: String, cardName: String, cardNumber: String, cardExpiry: String, cardCvv: String) async -> String{
        do {
            try await db.collection("users").document(self.user!.uid).setData([
                "name": name,
                "contact": contact,
                "cardName": cardName,
                "cardNumber": cardNumber,
                "cardExpiry": cardExpiry,
                "cardCvv": cardCvv
            ])
        }
        catch {
            print("Error saving user data: \(error.localizedDescription)")
            return error.localizedDescription
        }
        return ""
    }
    
    func signOut() -> String{
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.userRole = nil
            UserDefaults.standard.removeObject(forKey: "USER_EMAIL")
            UserDefaults.standard.removeObject(forKey: "USER_PASSWORD")
            UserDefaults.standard.removeObject(forKey: "USER_TYPE")
        } catch let err as NSError{
            print("Unable to sign out \(err.localizedDescription)")
            return err.localizedDescription
        }
        return ""
    }
    
    
    func getUserEmail(userId: String, completion: @escaping (String) -> Void) {
        Firestore.firestore().collection("Roles").document(userId).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user email: \(error.localizedDescription)")
                completion("Unknown Email")
                return
            }
            
            guard let data = snapshot?.data(),
                  let email = data["email"] as? String else {
                completion("Unknown Email")
                return
            }
            
            completion(email)
        }
    }
}
