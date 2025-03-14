import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: LandlordLogin()) {
                    Text("Landlord Login")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                NavigationLink(destination: TenantLogin()) {
                    Text("Tenant Login")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                NavigationLink(destination: ResidentHomeView()) {
                    Text("Anonymous Login")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    Task {
                        let result = await FireAuthHelper.shared.signInAnonymously()
                        if !result.isEmpty {
                            print("Error during anonymous login: \(result)")
                        } else {
                            print("Anonymous login successful")
                        }
                    }
                })
            }
            .navigationTitle(Text("Project"))
            .navigationBarTitleDisplayMode(.inline)
            
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    ContentView()
}
