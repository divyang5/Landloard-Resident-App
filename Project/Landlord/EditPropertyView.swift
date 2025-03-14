import SwiftUI

struct EditPropertyView: View {
    @State private var name: String
    @State private var address: String
    @State private var description: String
    @State private var price: Double
    @State private var numberOfBedrooms: Int
    @State private var listed: Bool
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @Environment(\.dismiss) private var dismiss
    
    var property: Property
    
    init(property: Property) {
        self.property = property
        _name = State(initialValue: property.name)
        _address = State(initialValue: property.address)
        _description = State(initialValue: property.description)
        _price = State(initialValue: property.price)
        _numberOfBedrooms = State(initialValue: property.numberOfBedrooms)
        _listed = State(initialValue: property.listed)
    }
    
    var body: some View {
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
                }
                
                // Save Button
                Button(action: updateProperty) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                        Text("Update Property")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle("Edit Property")
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func updateProperty() {
        guard let propertyId = property.id else {
            alertMessage = "Property ID is missing."
            showAlert = true
            return
        }
        
        // Create the updated property object
        let updatedProperty = Property(
            id: propertyId, // Use the unwrapped ID
            name: name,
            address: address,
            latitude: property.latitude,
            longitude: property.longitude,
            description: description,
            price: price,
            listed: listed,
            ownerID: property.ownerID,
            dateAdded: property.dateAdded,
            numberOfBedrooms: numberOfBedrooms
        )
        
        // Update the property in Firestore
        FireDBHelper.shared.updateProperty(property: updatedProperty) { error in
            if let error = error {
                alertMessage = "Error updating property: \(error.localizedDescription)"
            } else {
                alertMessage = "Property updated successfully!"
                dismiss() // Dismiss the edit view after updating
            }
            showAlert = true
        }
    }
}
