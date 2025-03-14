
import SwiftUI

struct LandlordLogin: View {
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var rememberMe: Bool = false
    
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    @State private var moveToSignup: Bool = false
    @State private var moveToContentView: Bool = false
    @State private var moveToBaseView: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section("Login") {
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
                        Toggle("Remember me", isOn: $rememberMe)
                            .tint(.blue)
                        Button(action: {
                            login()
                        }) {
                            Text("Login")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 5)
                                .font(.headline)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.vertical, 10)
                    }
                    Section("Don't have an account?") {
                        Button(action: {
                            moveToSignup = true
                        }) {
                            Text("Sign up now!")
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                NavigationLink(destination: LandlordSignup(), isActive: $moveToSignup) {
                    EmptyView()
                }
                NavigationLink(destination: ContentView(), isActive: $moveToContentView) {
                    EmptyView()
                }
                NavigationLink(destination: BaseView(), isActive: $moveToBaseView) {
                    EmptyView()
                }
            }
            .navigationTitle(Text("Landlord Login"))
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
        .onAppear() {
            if(UserDefaults.standard.string(forKey: "USER_TYPE") ?? "" == "Landlord"){
                username = UserDefaults.standard.string(forKey: "USER_EMAIL") ?? ""
                password = UserDefaults.standard.string(forKey: "USER_PASSWORD") ?? ""
                if(!username.isEmpty && !password.isEmpty){
                    rememberMe = true
                }
            }
        }
    }
    
    func login() {
        if(username.isEmpty || password.isEmpty) {
            showAlert = true
            alertTitle = "Error"
            alertMessage = "Please fill in all fields."
        }
        else if(password.count < 6) {
            showAlert = true
            alertTitle = "Error"
            alertMessage = "Password must be at least 6 characters long."
        }
        else {
            Task {
                let isSuccess:String = await FireAuthHelper.shared.signIn2(email: username, password: password, rememberMe: rememberMe)
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
    LandlordLogin()
}
