Project Title: Rental Property Management App (iOS - SwiftUI)

Project Overview:
This project is a mobile application developed for iOS using SwiftUI, designed to facilitate rental property management and browsing. The app supports three types of users: Landlords, Tenants, and Guests. Each user type has specific functionalities tailored to their needs, ensuring a seamless experience for property listing, searching, and management.

Key Features:
Landlord User:
Landlords can manage their rental properties efficiently through the app. Key functionalities include:

List/De-list Properties: Landlords can add new properties for rent or remove existing ones from the listing.

Update Property Details: Edit property information such as location, price, amenities, and more.

Receive Requests: Landlords can receive and manage rental requests from tenants.

Approve/Deny Requests: Accept or reject tenant requests for their properties.

Search Properties: Landlords can browse other rental properties in the market.

View Property Details: Access detailed information about any listed property.

Tenant User:
Tenants can search for and interact with rental properties. Key functionalities include:

Search Properties: Tenants can search for rental properties based on filters like location, price, and amenities.

View Property Details: Access detailed information about any property.

Shortlist Properties: Save properties of interest for future reference.

Send/Withdraw Requests: Tenants can send rental requests to landlords or withdraw them if needed.

Share Property Details: Share property information with others via external apps.

Guest User:
Guests can browse rental properties without creating an account. Key functionalities include:

Search Properties: Browse available rental properties.

View Property Details: Access detailed information about any property.

Technical Implementation:
User Authentication: FirebaseAuth is used for user authentication. Landlords and tenants can create accounts, and all users can save their login credentials using UserDefaults.

Remember Me Feature: Users can enable the "Remember Me" option to automatically fill in their login credentials upon reopening the app.

User Profiles: Users can view and edit their profiles, including email, name, contact details, and optional payment information. Profile data is stored in Cloud Firestore.

Data Persistence: All user-generated data, including property listings, requests, and profiles, is persisted using Cloud Firestore. Multiple collections or subcollections are used to organize data efficiently.

Navigation: The app uses SwiftUI's navigation mechanisms, leveraging EnvironmentObject and ObservableObject to maintain data consistency across views.

Logout: Users can log out at any time, returning them to the login screen.

Future Enhancements:
Integration of payment gateways for rental transactions.

Push notifications for request updates and property alerts.

Advanced search filters and map-based property browsing.
