import SwiftUI

struct PropertyRow: View {
    var property: Property
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(property.name)
                    .font(.headline)
                Spacer()
                if !property.buyer.isEmpty {
                    Text("Sold/Rented")
                        .font(.caption)
                        .padding(5)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
            }
            Text(property.address)
                .font(.subheadline)
                .foregroundColor(.gray)
            HStack {
                Text("$\(property.price, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.green)
                Spacer()
                Text("\(property.numberOfBedrooms) Bedrooms")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(!property.buyer.isEmpty ? Color.green.opacity(0.1) : Color.clear)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(!property.buyer.isEmpty ? Color.green : Color.clear, lineWidth: 2) 
        )
    }
}
