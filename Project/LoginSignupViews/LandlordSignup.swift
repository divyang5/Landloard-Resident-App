//
//  LandlordLogin.swift
//  Project
//
//  Created by Ketan Paliwal on 2025-03-06.
//

import SwiftUI

struct LandlordSignup: View {
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var rePassword: String = ""
    @State private var showRePassword: Bool = false
    @State private var rememberMe: Bool = false
    
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    @State private var moveToLogin: Bool = false
    @State private var moveToContentView: Bool = false
    @State private var moveToBaseView: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section("Signup") {
                        TextField("Username", text: $username)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .padding(.vertical, 2)
                        HStack{
                            if showPassword {
                                TextField("Password", text: $password)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled(true)
                            }
                            else {
                                SecureField("Password", text: $password)
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
                                TextField("Re-enter Password", text: $rePassword)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled(true)
                            }
                            else {
                                SecureField("Re-enter Password", text: $rePassword)
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
                        if( !rePassword.isEmpty && (password != rePassword) ) {
                            HStack {
                                Image(systemName: "xmark.circle")
                                    .frame(height: 1)
                                Text("Password does not match")
                                    .font(.caption)
                            }
                            .foregroundColor(.red)
                        }
                        Toggle("Remember Me", isOn: $rememberMe)
                        Button(action: {
                            signup()
                        }) {
                            Text("Signup")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 5)
                                .font(.headline)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.vertical, 10)
                    }
                    Section("Already have an account?") {
                        Button(action: {
                            moveToLogin = true
                            print(moveToLogin)
                        }) {
                            Text("Login now!")
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                NavigationLink(destination: LandlordLogin(), isActive: $moveToLogin) {
                    EmptyView()
                }
                NavigationLink(destination: ContentView(), isActive: $moveToContentView) {
                    EmptyView()
                }
                NavigationLink(destination: BaseView(), isActive: $moveToBaseView) {
                    EmptyView()
                }
            }
            .navigationTitle(Text("Landlord Signup"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        moveToContentView = true
                    }) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func signup() {
        if(username.isEmpty || password.isEmpty) {
            showAlert = true
            alertTitle = "Error"
            alertMessage = "Please fill in all fields."
        }
        else if(password.count < 6){
            showAlert = true
            alertTitle = "Error"
            alertMessage = "Password must be at least 6 characters long."
        }
        else if(password != rePassword) {
            showAlert = true
            alertTitle = "Error"
            alertMessage = "Password does not match."
        }
        else {
            Task {
                let isSuccess:String = await FireAuthHelper.shared.signUp2(email: username, password: password, rememberMe: rememberMe)
                if(isSuccess==""){
                    moveToBaseView = true
                }
                else {
                    showAlert = true
                    alertTitle = "Error"
                    alertMessage = isSuccess
                }
            }
        }
    }
}

#Preview {
    LandlordSignup()
}
