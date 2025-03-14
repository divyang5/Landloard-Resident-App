import SwiftUI

struct InterestedUsersView: View {
    @State private var propertiesWithInterestedUsers: [(Property, [InterestedUser])] = [] // (Property, [InterestedUser])
    @State private var isLoading: Bool = true
    @State private var errorMessage: String = ""
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading...")
            } else if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.headline)
            } else if propertiesWithInterestedUsers.isEmpty {
                Text("No interested users found.")
                    .font(.headline)
                    .foregroundColor(.gray)
            } else {
                List {
                    ForEach(propertiesWithInterestedUsers, id: \.0.id) { property, interestedUsers in
                        Section(header: Text("Property: \(property.name)")) {
                            ForEach(interestedUsers) { interestedUser in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Email: \(interestedUser.email)")
                                            .font(.subheadline)
                                        Text("User ID: \(interestedUser.userId)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    HStack {
                                        Button(action: {
                                            acceptInterestedUser(propertyId: property.id ?? "", userId: interestedUser.userId)
                                        }) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                                .font(.title2)
                                        }
                                        Button(action: {
                                            rejectInterestedUser(propertyId: property.id ?? "", userId: interestedUser.userId)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                                .font(.title2)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
            }
        }
        .navigationTitle("Interested Users")
        .onAppear {
            fetchInterestedUsers()
        }
    }
    
    private func fetchInterestedUsers() {
        guard let userId = FireAuthHelper.shared.user?.uid else {
            errorMessage = "User not logged in."
            isLoading = false
            return
        }
        
        // Fetch properties owned by the user
        FireDBHelper.shared.getUserProperties(userId: userId) { fetchedProperties in
            isLoading = false
            if fetchedProperties.isEmpty {
                errorMessage = "No properties found for this user."
            } else {
                // Fetch interested users for each property
                var propertiesWithUsers: [(Property, [InterestedUser])] = []
                let group = DispatchGroup()
                
                for property in fetchedProperties {
                    group.enter()
                    FireDBHelper.shared.getInterestedUsers(for: property.id ?? "") { interestedUserIds in
                        var interestedUsers: [InterestedUser] = []
                        let userGroup = DispatchGroup()
                        
                        for userId in interestedUserIds {
                            userGroup.enter()
                            FireAuthHelper.shared.getUserEmail(userId: userId) { email in
                                interestedUsers.append(InterestedUser(userId: userId, email: email))
                                userGroup.leave()
                            }
                        }
                        
                        userGroup.notify(queue: .main) {
                            propertiesWithUsers.append((property, interestedUsers))
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    propertiesWithInterestedUsers = propertiesWithUsers
                }
            }
        }
    }
    
    private func acceptInterestedUser(propertyId: String, userId: String) {
        FireDBHelper.shared.acceptInterestedUser(propertyId: propertyId, userId: userId) { error in
            if let error = error {
                errorMessage = "Error accepting user: \(error.localizedDescription)"
            } else {
                // Refresh the list
                fetchInterestedUsers()
            }
        }
    }
    
    private func rejectInterestedUser(propertyId: String, userId: String) {
        FireDBHelper.shared.rejectInterestedUser(propertyId: propertyId, userId: userId) { error in
            if let error = error {
                errorMessage = "Error rejecting user: \(error.localizedDescription)"
            } else {
                // Refresh the list
                fetchInterestedUsers()
            }
        }
    }
}

struct InterestedUser: Identifiable {
    let id = UUID()
    let userId: String
    let email: String
}
