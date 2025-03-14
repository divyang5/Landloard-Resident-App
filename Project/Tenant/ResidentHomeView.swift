import SwiftUI

struct ResidentHomeView: View {
    @State private var properties: [Property] = []
    @State private var shortlistedProperties: [Property] = []
    @State private var approvedProperties: [Property] = []
    @State private var searchText: String = ""
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showProfile: Bool = false
    @State private var showContent: Bool = false
    @State private var selectedTab: Int = 0
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar (only for the first tab)
                TabView(selection: $selectedTab) {
                    
                    VStack{
                        SearchBar(text: $searchText, placeholder: "Search properties...")
                        
                        List(filteredProperties) { property in
                            NavigationLink(destination: PropertyDetail(property: property)) {
                                PropertyRow(property: property)
                            }
                        }
                        .listStyle(PlainListStyle())
                        .refreshable {
                            fetchProperties()
                        }
                    }
                    .tabItem {
                        Label("All", systemImage: "house.fill")
                    }
                    .tag(0)
                    
                    ShortlistView()
                    .tabItem {
                        Label("ShortList", systemImage: "bookmark.fill")
                    }
                    .tag(1)
                    
                    List(approvedProperties) { property in
                        NavigationLink(destination: PropertyDetail(property: property)) {
                            PropertyRow(property: property)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        fetchApprovedProperties()
                    }
                    .tabItem {
                        Label("Approved", systemImage: "checkmark.circle.fill")
                    }
                    .tag(2)
                }
                
                NavigationLink(destination: Profile(), isActive: $showProfile) {
                    EmptyView()
                }
                NavigationLink(destination: ContentView(), isActive: $showContent) {
                    EmptyView()
                }
                
            }
            .navigationTitle(navigationTitle)
            .navigationBarBackButtonHidden(true) // Hide the back button
            .toolbar {
                // Leading toolbar item for Profile
                if FireAuthHelper.shared.user != nil {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showProfile = true
                        }) {
                            Image(systemName: "person.circle.fill")
                        }
                    }
                }
                else {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showContent = true
                        }) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                }
            }
            .onAppear {
                fetchProperties()
                fetchApprovedProperties()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .navigationBarBackButtonHidden()
        .interactiveDismissDisabled(true)
    }
    
    // Current properties based on selected tab
    private var currentProperties: [Property] {
        switch selectedTab {
        case 0:
            return filteredProperties
        case 1:
            return shortlistedProperties
        case 2:
            return approvedProperties
        default:
            return []
        }
    }
    
    // Navigation title based on selected tab
    private var navigationTitle: String {
        switch selectedTab {
        case 0:
            return "All Properties"
        case 1:
            return "Shortlisted Properties"
        case 2:
            return "Approved Properties"
        default:
            return "Properties"
        }
    }
    
    // Filter properties based on search text (name, address, or price)
    private var filteredProperties: [Property] {
        if searchText.isEmpty {
            return properties
        } else {
            return properties.filter { property in
                property.name.localizedCaseInsensitiveContains(searchText) ||
                property.address.localizedCaseInsensitiveContains(searchText) ||
                String(format: "%.2f", property.price).localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func fetchProperties() {
        FireDBHelper.shared.getProperties { fetchedProperties in
            properties = fetchedProperties
        }
    }
    
    private func fetchApprovedProperties() {
        guard let userId = FireAuthHelper.shared.user?.uid else {
            alertTitle = "Error"
            alertMessage = "User not logged in."
            showAlert = true
            return
        }
        
        FireDBHelper.shared.fetchApprovedProperties(userId: userId) { fetchedProperties in
            approvedProperties = fetchedProperties
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Spacer()
                        if !text.isEmpty {
                            Button(action: {
                                text = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing, 8)
                        }
                    }
                )
        }
        .padding(.horizontal)
    }
}


#Preview {
    ResidentHomeView()
}
