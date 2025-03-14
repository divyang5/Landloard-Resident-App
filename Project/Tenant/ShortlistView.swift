import SwiftUI

struct ShortlistView: View {
    
    @State private var shortlistedProperties: [Property] = []
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(shortlistedProperties) { property in
                    NavigationLink(destination: PropertyDetail(property: property)) {
                        PropertyRow(property: property)
                            .listRowBackground(Color(.systemBackground))
                    }
                }
                .onDelete(perform: deleteProperty)
            }
            .listStyle(PlainListStyle())
            .onAppear {
                fetchShortlistedProperties()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    
    private func fetchShortlistedProperties() {
        guard let userId = FireAuthHelper.shared.user?.uid else { return }
        

        FireDBHelper.shared.fetchUserShortlist(userId: userId) { propertyIds in
            var fetchedProperties: [Property] = []
            let dispatchGroup = DispatchGroup()
            
            for propertyId in propertyIds {
                dispatchGroup.enter()
                FireDBHelper.shared.getPropertyById(propertyId: propertyId) { property in
                    if let property = property {
                        fetchedProperties.append(property)
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                shortlistedProperties = fetchedProperties
            }
        }
    }
    
    private func deleteProperty(at offsets: IndexSet) {
        guard let userId = FireAuthHelper.shared.user?.uid else { return }
        
        for index in offsets {
            let propertyId = shortlistedProperties[index].id ?? ""
            

            FireDBHelper.shared.removeFromShortlist(userId: userId, propertyId: propertyId) { error in
                if let error = error {
                    alertTitle = "Error"
                    alertMessage = error.localizedDescription
                    showAlert = true
                } else {
                    shortlistedProperties.remove(at: index)
                }
            }
        }
    }
}
