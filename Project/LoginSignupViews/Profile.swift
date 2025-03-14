import SwiftUI

struct Profile: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var rePassword: String = ""
    @State private var showRePassword: Bool = false
    
    @State private var name: String = ""
    @State private var contact: String = ""
    @State private var address: String = ""
    @State private var cardName: String = ""
    @State private var cardNum: String = ""
    @State private var cardExp: String = ""
    @State private var cardCvv: String = ""
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var alertTitle: String = ""
    
    @State private var moveToResidentHomeView: Bool = false // State to control navigation to ResidentHomeView
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section("Username") {
                        Text(FireAuthHelper.shared.user?.email ?? "")
                            .padding(.vertical, 2)
                    }
                    Section("Change Password") {
                        HStack{
                            if showPassword {
                                TextField("Current Password", text: $password)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled(true)
                            }
                            else {
                                SecureField("Current Password", text: $password)
                            }
                            Spacer()
                            Button(action: {
                                showPassword.toggle()
                            }) {
                                Image(systemName: showPassword ? "eye" : "eye.slash")
                                    .frame(height: 20)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.black)
                            .buttonBorderShape(.capsule)
                        }
                        HStack{
                            if showRePassword {
                                TextField("New Password", text: $rePassword)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled(true)
                            }
                            else {
                                SecureField("New Password", text: $rePassword)
                            }
                            Spacer()
                            Button(action: {
                                showRePassword.toggle()
                            }) {
                                Image(systemName: showRePassword ? "eye" : "eye.slash")
                                    .frame(height: 20)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.black)
                            .buttonBorderShape(.capsule)
                        }
                        Button(action: {
                            changePassword()
                        }) {
                            Text("Change Password")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 5)
                            .font(.headline)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.vertical, 10)
                    }
                    Section("Name") {
                        TextField("Enter Name", text: $name)
                            .autocorrectionDisabled(true)
                    }
                    Section("Contact Number") {
                        TextField("Enter Contact Number", text: $contact)
                            .autocapitalization(.none)
                            .autocorrectionDisabled(true)
                    }
                    Section("Credit Card Information") {
                        TextField("Credit Card Holder Name", text: $cardName)
                            .autocapitalization(.none)
                            .autocorrectionDisabled(true)
                        TextField("Credit Card Number", text: $cardNum)
                            .autocapitalization(.none)
                            .autocorrectionDisabled(true)
                        TextField("Credit Card Expiry (MM/YY)", text: $cardExp)
                            .autocapitalization(.none)
                            .autocorrectionDisabled(true)
                        TextField("CVV", text: $cardCvv)
                            .autocapitalization(.none)
                            .autocorrectionDisabled(true)
                    }
                    Button(action: {
                        updateProfile()
                    }) {
                        Text("Save Details")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 5)
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.vertical, 10)
                }
            }
            .navigationTitle(Text("User Profile"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        signOut()
                    }) {
                        Text("Signout")
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            if FireAuthHelper.shared.user != nil {
                getProfile()
            } else {
                dismiss()
            }
        }
        .background(
            NavigationLink(destination: ContentView(), isActive: $moveToResidentHomeView) {
                EmptyView()
            }
        )
    }
    
    func changePassword() {
        Task {
            let err = await FireAuthHelper.shared.changePassword(oldPassword: self.password, newPassword: self.rePassword)
            if err.isEmpty {
                showAlert = true
                alertTitle = "Success"
                alertMessage = "Password changed successfully"
            } else {
                showAlert = true
                alertTitle = "Error"
                alertMessage = err
            }
        }
    }
    
    func getProfile() {
        Task {
            (self.name, self.contact, self.cardName, self.cardNum, self.cardExp, self.cardCvv) = await FireAuthHelper.shared.getProfile() ?? ("", "", "", "", "", "")
        }
    }
    
    func updateProfile() {
        Task {
            let err = await FireAuthHelper.shared.saveProfile(name: self.name, contact: self.contact, cardName: self.cardName, cardNumber: self.cardNum, cardExpiry: self.cardExp, cardCvv: self.cardCvv)
            if err.isEmpty {
                showAlert = true
                alertTitle = "Success"
                alertMessage = "Profile updated successfully"
            } else {
                showAlert = true
                alertTitle = "Error"
                alertMessage = err
            }
        }
    }
    
    func signOut() {
        Task {
            let err = await FireAuthHelper.shared.signOut()
            if err.isEmpty {
                // Clear UserDefaults
                UserDefaults.standard.removeObject(forKey: "USER_EMAIL")
                UserDefaults.standard.removeObject(forKey: "USER_PASSWORD")
                UserDefaults.standard.removeObject(forKey: "USER_TYPE")
                
                // Reset navigation stack to ResidentHomeView
                moveToResidentHomeView = true
            } else {
                showAlert = true
                alertTitle = "Error"
                alertMessage = err
            }
        }
    }
}

#Preview {
    Profile()
}
