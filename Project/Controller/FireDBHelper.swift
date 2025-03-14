import Foundation
import FirebaseFirestore

class FireDBHelper {
    
    static let shared = FireDBHelper()
    private let db = Firestore.firestore()
    
    private init() {}

    
    
    func addProperty(property: Property, completion: @escaping (Error?) -> Void) {
            do {
                try db.collection("properties").addDocument(from: property) { error in
                    completion(error)
                }
            } catch {
                completion(error)
            }
        }
    
    

        func deleteProperty(propertyId: String, completion: @escaping (Error?) -> Void) {
            db.collection("properties").document(propertyId).delete { error in
                completion(error)
            }
        }

    func getPropertyById(propertyId: String, completion: @escaping (Property?) -> Void) {
        db.collection("properties").document(propertyId).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching property: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let document = snapshot, document.exists,
                  let property = try? document.data(as: Property.self) else {
                completion(nil)
                return
            }
            
            completion(property)
        }
    }
    
    func getProperties(completion: @escaping ([Property]) -> Void) {
        db.collection("properties")
            .whereField("listed", isEqualTo: true) // Only fetch listed properties
            .whereField("buyer", isEqualTo: "") // Exclude properties with a buyer
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching properties: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No properties found.")
                    completion([])
                    return
                }
                
                let properties = documents.compactMap { try? $0.data(as: Property.self) }
                completion(properties)
            }
    }
    
    func getUserProperties(userId: String, completion: @escaping ([Property]) -> Void) {
        db.collection("properties").whereField("ownerID", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching user properties: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No properties found for the user.")
                completion([])
                return
            }
            
            let properties = documents.compactMap { try? $0.data(as: Property.self) }
            completion(properties)
        }
    }
    
    func updateProperty(property: Property, completion: @escaping (Error?) -> Void) {
        guard let propertyId = property.id else {
            completion(NSError(domain: "FireDBHelper", code: -1, userInfo: [NSLocalizedDescriptionKey: "Property ID is missing."]))
            return
        }
        
        do {
            try db.collection("properties").document(propertyId).setData(from: property) { error in
                completion(error)
            }
        } catch {
            completion(error)
        }
    }
    

    func addUserToInterestedList(propertyId: String, userId: String, completion: @escaping (Error?) -> Void) {
        db.collection("properties").document(propertyId).updateData([
            "interestedList": FieldValue.arrayUnion([userId])
        ]) { error in
            completion(error)
        }
    }
    
    
    func addToShortlist(userId: String, propertyId: String, completion: @escaping (Error?) -> Void) {
        db.collection("users").document(userId).updateData([
            "shortlist": FieldValue.arrayUnion([propertyId])
        ]) { error in
            completion(error)
        }
    }
    

    
    func checkIfShortlisted(userId: String, propertyId: String, completion: @escaping (Bool) -> Void) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let shortlist = data["shortlist"] as? [String] {
                completion(shortlist.contains(propertyId))
            } else {
                completion(false)
            }
        }
    }
    
    func fetchUserShortlist(userId: String, completion: @escaping ([Property]) -> Void) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let shortlist = data["shortlist"] as? [String] {
                self.fetchPropertiesByIds(propertyIds: shortlist, completion: completion)
            } else {
                completion([])
            }
        }
    }
    /// Fetch the user's shortlist (property IDs)
        func fetchUserShortlist(userId: String, completion: @escaping ([String]) -> Void) {
            db.collection("users").document(userId).getDocument { snapshot, error in
                if let data = snapshot?.data(),
                   let shortlist = data["shortlist"] as? [String] {
                    completion(shortlist)
                } else {
                    completion([])
                }
            }
        }
        
    func fetchPropertiesByIds(propertyIds: [String], completion: @escaping ([Property]) -> Void) {
        db.collection("properties")
            .whereField("id", in: propertyIds)
            .whereField("listed", isEqualTo: true) // Only fetch listed properties
            .whereField("buyer", isEqualTo: "") // Exclude properties with a buyer
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching properties by IDs: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No properties found for the given IDs.")
                    completion([])
                    return
                }
                
                let properties = documents.compactMap { try? $0.data(as: Property.self) }
                completion(properties)
            }
    }
        
        func removeFromShortlist(userId: String, propertyId: String, completion: @escaping (Error?) -> Void) {
            db.collection("users").document(userId).updateData([
                "shortlist": FieldValue.arrayRemove([propertyId])
            ]) { error in
                completion(error)
            }
        }
    
    
    func ensureUserDocumentExists(userId: String, completion: @escaping (Error?) -> Void) {
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { snapshot, error in
            if let error = error {
                completion(error)
                return
            }
 
            if !(snapshot?.exists ?? false) {
                userRef.setData(["shortlist": []]) { error in
                    completion(error)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    func removeUserFromInterestedList(propertyId: String, userId: String, completion: @escaping (Error?) -> Void) {
        db.collection("properties").document(propertyId).updateData([
            "interestedList": FieldValue.arrayRemove([userId])
        ]) { error in
            completion(error)
        }
    }
    

     func getInterestedUsers(for propertyId: String, completion: @escaping ([String]) -> Void) {
         db.collection("properties").document(propertyId).getDocument { snapshot, error in
             if let error = error {
                 print("Error fetching interested users: \(error.localizedDescription)")
                 completion([])
                 return
             }
             
             guard let data = snapshot?.data(),
                   let interestedList = data["interestedList"] as? [String] else {
                 completion([])
                 return
             }
             
             completion(interestedList)
         }
     }
     
     func acceptInterestedUser(propertyId: String, userId: String, completion: @escaping (Error?) -> Void) {
         let propertyRef = db.collection("properties").document(propertyId)
         
         propertyRef.updateData([
             "buyer": userId, // Add the user to the buyer field
             "interestedList": FieldValue.arrayRemove([userId]) // Remove the user from interestedList
         ]) { error in
             completion(error)
         }
     }
     

     func rejectInterestedUser(propertyId: String, userId: String, completion: @escaping (Error?) -> Void) {
         let propertyRef = db.collection("properties").document(propertyId)
         
         propertyRef.updateData([
             "interestedList": FieldValue.arrayRemove([userId]) // Remove the user from interestedList
         ]) { error in
             completion(error)
         }
     }

        func fetchApprovedProperties(userId: String, completion: @escaping ([Property]) -> Void) {
            db.collection("properties")
                .whereField("buyer", isEqualTo: userId) // Fetch properties where buyer matches user ID
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("Error fetching approved properties: \(error.localizedDescription)")
                        completion([])
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        print("No approved properties found.")
                        completion([])
                        return
                    }
                    
                    let properties = documents.compactMap { try? $0.data(as: Property.self) }
                    completion(properties)
                }
        }
}
