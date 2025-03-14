import SwiftUI
import FirebaseAuth

struct PropertyDetail: View {
    
    var property: Property
    
    @State private var isShortlisted: Bool = false
    @State private var isInterested: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    

    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(property.name)
                    .font(.largeTitle)
                Text(property.address)
                    .font(.title2)
                Text("$\(property.price, specifier: "%.2f")")
                    .font(.title3)
                Text("Bedrooms: \(property.numberOfBedrooms)")
                    .font(.title3)
                Text(property.description)
                    .font(.body)
                

                actionButtons
            }
            .padding()
        }
        .navigationTitle("Property Details")
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("OK")))
        }
        .onAppear {
            checkShortlistStatus()
            checkInterestStatus()
        }
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 16) {
            // Show Interested and Shortlist buttons only for tenants
            if FireAuthHelper.shared.userRole == "Tenant" {
                interestedButton
                shortlistButton
            }
            
            // Show Share button for all users
            shareButton
        }
        .padding(.horizontal)
    }
    
    private var interestedButton: some View {
        Button(action: toggleInterest) {
            HStack {
                Image(systemName: isInterested ? "heart.fill" : "heart")
                    .foregroundColor(.white)
                Text(isInterested ? "Already Interested" : "Interested")
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isInterested ? Color.gray : Color.green)
            .cornerRadius(8)
            .animation(.easeInOut, value: isInterested)
        }
    }
    
    private var shortlistButton: some View {
        Button(action: toggleShortlist) {
            HStack {
                Image(systemName: isShortlisted ? "bookmark.fill" : "bookmark")
                    .foregroundColor(.white)
                Text(isShortlisted ? "Remove from Shortlist" : "Shortlist Property")
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isShortlisted ? Color.red : Color.blue)
            .cornerRadius(8)
            .animation(.easeInOut, value: isShortlisted)
        }
    }
    
    private var shareButton: some View {
        Button(action: shareProperty) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.white)
                Text("Share Property")
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.orange)
            .cornerRadius(8)
        }
    }
    
    // MARK: - Action Handlers
    private func toggleInterest() {
        guard let userId = currentUserId else {
            showAuthError()
            return
        }
        
        let propertyId = property.id ?? ""
        
        if isInterested {
            FireDBHelper.shared.removeUserFromInterestedList(
                propertyId: propertyId,
                userId: userId
            ) { error in
                handleInterestResponse(error: error, added: false)
            }
        } else {
            FireDBHelper.shared.addUserToInterestedList(
                propertyId: propertyId,
                userId: userId
            ) { error in
                handleInterestResponse(error: error, added: true)
            }
        }
    }
    
    private func toggleShortlist() {
        guard let userId = currentUserId else {
            showAuthError()
            return
        }
        
        let propertyId = property.id ?? ""
        
        FireDBHelper.shared.ensureUserDocumentExists(userId: userId) { error in
            if let error = error {
                alertTitle = "Error"
                alertMessage = error.localizedDescription
                showAlert = true
                return
            }
            
            if isShortlisted {
                FireDBHelper.shared.removeFromShortlist(
                    userId: userId,
                    propertyId: propertyId
                ) { error in
                    handleShortlistResponse(error: error, added: false)
                }
            } else {
                FireDBHelper.shared.addToShortlist(
                    userId: userId,
                    propertyId: propertyId
                ) { error in
                    handleShortlistResponse(error: error, added: true)
                }
            }
        }
    }
    

    private func checkShortlistStatus() {
        guard let userId = currentUserId else { return }
        
        FireDBHelper.shared.checkIfShortlisted(
            userId: userId,
            propertyId: property.id ?? ""
        ) { shortlisted in
            isShortlisted = shortlisted
        }
    }
    
    private func checkInterestStatus() {
        guard let userId = currentUserId else { return }
        
        if let interestedList = property.interestedList, interestedList.contains(userId) {
            isInterested = true
        } else {
            isInterested = false
        }
    }
    
    private func handleInterestResponse(error: Error?, added: Bool) {
        if let error = error {
            alertTitle = "Error"
            alertMessage = error.localizedDescription
        } else {
            isInterested = added
            alertTitle = "Success"
            alertMessage = added ?
                "You've shown interest in this property!" :
                "Your interest has been removed."
        }
        showAlert = true
    }
    
    private func handleShortlistResponse(error: Error?, added: Bool) {
        if let error = error {
            alertTitle = "Error"
            alertMessage = error.localizedDescription
        } else {
            isShortlisted = added
            alertTitle = "Success"
            alertMessage = added ?
                "Property added to shortlist!" :
                "Property removed from shortlist!"
        }
        showAlert = true
    }
    
    private func showAuthError() {
        alertTitle = "Authentication Error"
        alertMessage = "You need to be logged in to perform this action."
        showAlert = true
    }
    
    private func shareProperty() {
        let propertyDetails = """
        🏠 Property Details:
        Name: \(property.name)
        Address: \(property.address)
        Price: $\(String(format: "%.2f", property.price))
        Bedrooms: \(property.numberOfBedrooms)
        Description: \(property.description)
        """
        
        presentShareSheet(content: propertyDetails)
    }
    
    private func presentShareSheet(content: String) {
        let activityVC = UIActivityViewController(
            activityItems: [content],
            applicationActivities: nil
        )
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            return
        }
        
        rootVC.present(activityVC, animated: true)
    }
}

// MARK: - View Modifiers
extension Text {
    func actionButtonStyle(backgroundColor: Color) -> some View {
        self
            .frame(maxWidth: .infinity)
            .padding()
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}
