import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var isFirstSignUp: Bool = false
    @State private var isLoading: Bool = false
    @State private var isPasswordVisible: Bool = false
    
    @AppStorage("hasSignedUp") private var hasSignedUp: Bool = false
    
    let primaryColor = Color(red: 41/255, green: 128/255, blue: 185/255)
    let secondaryColor = Color(red: 52/255, green: 152/255, blue: 219/255)
    let backgroundColor = Color(red: 245/255, green: 247/255, blue: 250/255)
    let cardColor = Color.white
    let cornerRadius: CGFloat = 16
    let shadowRadius: CGFloat = 5
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.white, Color.cyan]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        Spacer(minLength: 30)
                        
                        VStack(spacing: 20) {
                            Text("Log In / Sign Up")
                                .font(.system(size: 24, weight: .bold, design: .default))
                                .foregroundColor(.primary)
                                .padding(.bottom, 10)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(.secondary)
                                    
                                    TextField("your[at]email.com", text: $email)
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(cornerRadius)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.secondary)
                                    
                                    if isPasswordVisible {
                                        TextField("Enter password", text: $password)
                                    } else {
                                        SecureField("Enter password", text: $password)
                                    }
                                    
                                    Button(action: {
                                        isPasswordVisible.toggle()
                                    }) {
                                        Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(cornerRadius)
                            }
                            
                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .font(.footnote)
                                    .foregroundColor(.red)
                                    .padding(.top, -5)
                            }
                            
                            Button(action: loginUser) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: cornerRadius)
                                        .fill(primaryColor)
                                    
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                                    } else {
                                        Text("Log In")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                }
                                .frame(height: 50)
                            }
                            .disabled(isLoading)
                            .shadow(color: primaryColor.opacity(0.3), radius: 5, x: 0, y: 3)
                            
                            Button(action: signUpUser) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: cornerRadius)
                                        .fill(Color.green)
                                    
                                    Text("Sign Up")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                .frame(height: 50)
                            }
                            .disabled(isLoading)
                            .shadow(color: Color.green.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                        .padding(.horizontal, 25)
                        .padding(.vertical, 30)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(cardColor)
                                .shadow(color: Color.black.opacity(0.15), radius: shadowRadius, x: 0, y: 4)
                        )
                        .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                    .padding(.vertical, 40)
                }
                
                NavigationLink(isActive: $isLoggedIn) {
                    Group {
                        if isFirstSignUp {
                            MainView()
                                .navigationBarBackButtonHidden(true)
                        } else {
                            MainView2()
                                .navigationBarBackButtonHidden(true)
                        }
                    }
                } label: {
                    EmptyView()
                }
                .hidden()
            }
        }
    }
    
    
    func loginUser() {
        isLoading = true
        errorMessage = ""
        isFirstSignUp = false
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            isLoading = false
            if let error = error {
                errorMessage = "Login failed: \(error.localizedDescription)"
            } else {
                isLoggedIn = true
            }
        }
    }
    
    func signUpUser() {
        isLoading = true
        errorMessage = ""
        
        if !hasSignedUp {
            isFirstSignUp = true
            hasSignedUp = true
        } else {
            isFirstSignUp = false
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            isLoading = false
            if let error = error {
                errorMessage = "Sign-up failed: \(error.localizedDescription)"
            } else {
                isLoggedIn = true
            }
        }
    }
}


#Preview {
    LoginView()
}
