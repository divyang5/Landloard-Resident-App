import SwiftUI

struct ViewProperty: View {
    
    @State private var properties: [Property] = []
    
    var body: some View {
        NavigationView {
            VStack {
                if properties.isEmpty {
                    noPropertiesView
                } else {
                    propertyListView
                }
            }
            .navigationTitle(Text("All Properties"))
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            fetchProperties()
        }
    }
    
    private var noPropertiesView: some View {
        VStack {
            Spacer()
            Text("No properties to display")
                .font(.headline)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
            Spacer()
            Spacer()
        }
    }
    
    private var propertyListView: some View {
        List {
            ForEach(properties.filter { $0.listed }) { property in
                NavigationLink(destination: PropertyDetail(property: property)) {
                    PropertyRow(property: property)
                }
            }
        }
    }
    
    private func fetchProperties() {
        FireDBHelper.shared.getProperties { fetchedProperties in
            properties = fetchedProperties
        }
    }
}

#Preview {
    ViewProperty()
}
