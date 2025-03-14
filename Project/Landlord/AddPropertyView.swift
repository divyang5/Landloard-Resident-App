import SwiftUI
import CoreLocation
import FirebaseFirestore

struct AddPropertyView: View {
    @State private var name: String = ""
    @State private var address: String = ""
    @State private var latitude: Double = 0.0
    @State private var longitude: Double = 0.0
    @State private var description: String = ""
    @State private var price: Double = 0.0
    @State private var numberOfBedrooms: Int = 1
    @State private var listed: Bool = true
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @StateObject private var locationManager = LocationManager()
    

    @Environment(\.dismiss) private var dismiss
    

    private var ownerID: String {
        FireAuthHelper.shared.user?.uid ?? "unknown_user"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 10) {
                    SectionView(title: "Property Details", icon: "house.fill") {
                        TextFieldWithIcon(text: $name, placeholder: "Name", icon: "textformat")
                        TextFieldWithIcon(text: $description, placeholder: "Description", icon: "text.justify")
                        StepperWithIcon(value: $numberOfBedrooms, label: "Number of Bedrooms: \(numberOfBedrooms)", icon: "bed.double.fill")
                        TextFieldWithIcon(text: Binding<String>(
                            get: { String(format: "%.2f", price) },
                            set: { price = Double($0) ?? 0.0 }
                        ), placeholder: "Price", icon: "dollarsign.circle.fill")
                            .keyboardType(.decimalPad)
                        ToggleWithIcon(isOn: $listed, label: "Listed", icon: "checkmark.circle.fill")
                        TextFieldWithIcon(text: $address, placeholder: "Address", icon: "mappin.and.ellipse")
                            .onChange(of: address) { newAddress in
                                fetchCoordinatesFromAddress(newAddress)
                            }
                    }
                    
                    // Location Section
                    SectionView(title: "Location", icon: "location.fill") {
                        Button(action: fetchCurrentLocation) {
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.white)
                                Text("Use Current Location")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue) // Solid blue color
                            .cornerRadius(10)
                        }
                    }
                    
                    // Save Button
                    Button(action: saveProperty) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.white)
                            Text("Save Property")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue) // Solid blue color
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("Add Property")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func fetchCurrentLocation() {
        if let location = locationManager.location {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            fetchAddressFromCoordinates(latitude: latitude, longitude: longitude)
        } else {
            alertMessage = "Unable to fetch current location."
            showAlert = true
        }
    }

    private func fetchAddressFromCoordinates(latitude: Double, longitude: Double) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                alertMessage = "Error fetching address: \(error.localizedDescription)"
                showAlert = true
                return
            }
            
            guard let placemark = placemarks?.first else {
                alertMessage = "No address found for the location."
                showAlert = true
                return
            }
            
            // Construct the address string
            let addressComponents = [
                placemark.thoroughfare,
                placemark.locality,
                placemark.administrativeArea,
                placemark.postalCode,
                placemark.country
            ].compactMap { $0 }
            
            address = addressComponents.joined(separator: ", ")
        }
    }
    
    private func fetchCoordinatesFromAddress(_ address: String) {
        // Skip if the address is empty
        if address.isEmpty {
            return
        }
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                alertMessage = "Error fetching coordinates: \(error.localizedDescription)"
                showAlert = true
                return
            }
            
            guard let placemark = placemarks?.first,
                  let location = placemark.location else {
                alertMessage = "No coordinates found for the address."
                showAlert = true
                return
            }
            
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
        }
    }
    
    private func validateProperty() -> Bool {
        // Check if the address is empty
        if address.isEmpty {
            alertMessage = "Please enter a valid address."
            showAlert = true
            return false
        }
        
        // Check if latitude and longitude are valid
        if latitude == 0.0 || longitude == 0.0 {
            alertMessage = "Unable to fetch valid coordinates for the address."
            showAlert = true
            return false
        }
        
        return true
    }
    

    private func saveProperty() {
        // Validate the property data
        if !validateProperty() {
            return // Stop if validation fails
        }
        
        let property = Property(
            name: name,
            address: address,
            latitude: latitude,
            longitude: longitude,
            description: description,
            price: price,
            listed: listed,
            ownerID: ownerID,
            numberOfBedrooms: numberOfBedrooms
        )
        
        FireDBHelper.shared.addProperty(property: property) { error in
            if let error = error {
                alertMessage = "Error saving property: \(error.localizedDescription)"
            } else {
                alertMessage = "Property saved successfully!"
                clearForm()
                dismiss() // Dismiss the sheet after saving
            }
            showAlert = true
        }
    }
    
    private func clearForm() {
        name = ""
        address = ""
        latitude = 0.0
        longitude = 0.0
        description = ""
        price = 0.0
        numberOfBedrooms = 1
        listed = true
    }
}


struct SectionView<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding(.bottom, 5)
            
            content
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
}


struct TextFieldWithIcon: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
            TextField(placeholder, text: $text)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}


struct StepperWithIcon: View {
    @Binding var value: Int
    let label: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
            Text(label)
            Spacer()
            Stepper("", value: $value, in: 1...10)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct ToggleWithIcon: View {
    @Binding var isOn: Bool
    let label: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
            Text(label)
            Spacer()
            Toggle("", isOn: $isOn)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
