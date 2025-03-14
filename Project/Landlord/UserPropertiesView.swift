import SwiftUI

struct UserPropertiesView: View {
    @State private var userProperties: [Property] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String = ""
    @State private var propertyToDelete: Property? = nil // Track the property to delete
    @State private var showDeleteConfirmation: Bool = false // Show delete confirmation dialog
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading...")
            } else if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.headline)
            } else if userProperties.isEmpty {
                Text("No properties found.")
                    .font(.headline)
                    .foregroundColor(.gray)
            } else {
                List {
                    ForEach(userProperties) { property in
                        NavigationLink(destination: EditPropertyView(property: property)) {
                            PropertyRow(property: property)
                                .contentShape(Rectangle())
                                .onLongPressGesture {
                                    propertyToDelete = property
                                    showDeleteConfirmation = true
                                }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    fetchUserProperties() // Refresh properties when pulled down
                }
            }
        }
        .navigationTitle("My Properties")
        .onAppear {
            fetchUserProperties() // Fetch properties when the view appears
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Property"),
                message: Text("Are you sure you want to delete this property?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let property = propertyToDelete {
                        deleteProperty(property: property)
                    }
                },
                secondaryButton: .cancel() {
                    propertyToDelete = nil
                }
            )
        }
    }
    
    private func fetchUserProperties() {
        guard let userId = FireAuthHelper.shared.user?.uid else {
            errorMessage = "User not logged in."
            isLoading = false
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        FireDBHelper.shared.getUserProperties(userId: userId) { fetchedProperties in
            isLoading = false
            if fetchedProperties.isEmpty {
                errorMessage = "No properties found for this user."
            } else {
                userProperties = fetchedProperties
            }
        }
    }
    
    private func deleteProperty(property: Property) {
        guard let propertyId = property.id else {
            errorMessage = "Property ID is missing."
            return
        }
        
        FireDBHelper.shared.deleteProperty(propertyId: propertyId) { error in
            if let error = error {
                errorMessage = "Error deleting property: \(error.localizedDescription)"
            } else {
                if let index = userProperties.firstIndex(where: { $0.id == propertyId }) {
                    userProperties.remove(at: index)
                    errorMessage = ""
                } else {
                    errorMessage = "Property not found in the local list."
                }
            }
            propertyToDelete = nil
        }
    }
}
