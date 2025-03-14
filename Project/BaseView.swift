import SwiftUI

struct BaseView: View {
    @State private var showProfile: Bool = false
    @State private var showContent: Bool = false
    @State private var showAddPropertyView: Bool = false
    @State private var selectedTab: Int = 0
    
    @State private var allProperties: [Property] = []
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                
                TabView(selection: $selectedTab) {
                    
                    VStack{
                        SearchBar(text: $searchText, placeholder: "Search properties...")
                        List(filteredProperties) { property in
                            NavigationLink(destination: PropertyDetail(property: property)) {
                                PropertyRow(property: property)
                            }
                        }
                    }
                    .tabItem {
                        Label("All", systemImage: "house.fill")
                    }
                    .tag(0)
                    
                    UserPropertiesView()
                    .tabItem {
                        Label("My Properties", systemImage: "bookmark.fill")
                    }
                    .tag(1)
                    
                    InterestedUsersView()
                    .tabItem {
                        Label("Interested", systemImage: "checkmark.circle.fill")
                    }
                    .tag(2)
                }
                
                NavigationLink(destination: Profile(), isActive: $showProfile) {
                    EmptyView()
                }
            }
            .navigationTitle(navigationTitle)
            .toolbar {
                if FireAuthHelper.shared.user != nil {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showProfile = true
                        }) {
                            Image(systemName: "person.circle.fill")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showAddPropertyView = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .bold))
                        }
                    }
                } else {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showContent = true
                        }) {
                            Image(systemName: "chevron.left")
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddPropertyView) {
                AddPropertyView()
            }
            .onAppear {
                fetchAllProperties()
            }
        }
        .navigationBarBackButtonHidden()
    }
    

    private var filteredProperties: [Property] {
        if searchText.isEmpty {
            return allProperties
        } else {
            return allProperties.filter { property in
                property.name.localizedCaseInsensitiveContains(searchText) ||
                property.address.localizedCaseInsensitiveContains(searchText) ||
                String(format: "%.2f", property.price).localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    private var navigationTitle: String {
        switch selectedTab {
        case 0:
            return "All Properties"
        case 1:
            return "My Properties"
        case 2:
            return "Interested Users"
        default:
            return "Properties"
        }
    }
    

    private func fetchAllProperties() {
        FireDBHelper.shared.getProperties { fetchedProperties in
            allProperties = fetchedProperties
        }
    }
}

#Preview {
    BaseView()
}
