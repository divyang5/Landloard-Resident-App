import Foundation
import FirebaseFirestore

struct Property: Identifiable, Codable, Hashable {
    @DocumentID var id: String? = UUID().uuidString
    var name: String = ""
    var address: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var description: String = ""
    var price: Double = 0.0
    var numberOfBedrooms: Int = 1
    var listed: Bool = true
    var ownerID: String = ""
    var dateAdded: Date = Date()
    var interestedList: [String]? = nil
    var buyer: String = ""

    init() {}

    init(
        id: String,
        name: String,
        address: String,
        latitude: Double,
        longitude: Double,
        description: String,
        price: Double,
        listed: Bool,
        ownerID: String,
        dateAdded: Date,
        numberOfBedrooms: Int,
        interestedList: [String]? = nil,
        buyer: String = ""
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.description = description
        self.price = price
        self.listed = listed
        self.ownerID = ownerID
        self.dateAdded = dateAdded
        self.numberOfBedrooms = numberOfBedrooms
        self.interestedList = interestedList
        self.buyer = buyer
    }

    init(
        name: String,
        address: String,
        latitude: Double,
        longitude: Double,
        description: String,
        price: Double,
        listed: Bool,
        ownerID: String,
        numberOfBedrooms: Int,
        interestedList: [String]? = nil,
        buyer: String = "" 
    ) {
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.description = description
        self.price = price
        self.listed = listed
        self.ownerID = ownerID
        self.numberOfBedrooms = numberOfBedrooms
        self.interestedList = interestedList
        self.buyer = buyer
    }
}
