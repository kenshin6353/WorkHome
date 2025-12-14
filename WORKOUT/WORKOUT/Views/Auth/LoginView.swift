//
//  LoginView.swift
//  WORKOUT
//
//  Created for WorkHome App
//

import SwiftUI
import SwiftData
import Combine

struct LoginView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var authManager: AuthManager
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var navigateToRegister: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient.primaryGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Spacer()
                            .frame(height: 40)
                        
                        // Logo and Title
                        VStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(LinearGradient.primaryGradient)
                                    .frame(width: 80, height: 80)
                                    .shadow(color: .black.opacity(0.2), radius: 10)
                                
                                Image(systemName: "dumbbell.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white)
                            }
                            
                            Text("WorkHome")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Your home workout companion")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.bottom, 20)
                        
                        // Login Form
                        VStack(spacing: 20) {
                            // Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    TextField("Enter your email", text: $email)
                                        .textContentType(.emailAddress)
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                    
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    if showPassword {
                                        TextField("Enter your password", text: $password)
                                    } else {
                                        SecureField("Enter your password", text: $password)
                                    }
                                    
                                    Button(action: { showPassword.toggle() }) {
                                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            }
                            
                            // Sign In Button
                            GradientButton("Sign In", isLoading: isLoading) {
                                login()
                            }
                            
                            // Forgot Password
                            Button(action: {}) {
                                Text("Forgot Password?")
                                    .font(.subheadline)
                                    .foregroundColor(.gradientStart)
                            }
                        }
                        
                        Spacer()
                            .frame(height: 20)
                        
                        // Sign Up Link
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(.gray)
                            
                            Button(action: { navigateToRegister = true }) {
                                Text("Sign up")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.gradientStart)
                            }
                        }
                        .font(.subheadline)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.white.opacity(0.95))
                            .shadow(color: .black.opacity(0.1), radius: 20)
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 40)
                }
            }
            .navigationDestination(isPresented: $navigateToRegister) {
                RegisterView(authManager: authManager)
            }
            .alert("Login Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password"
            showError = true
            return
        }
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let success = authManager.login(email: email, password: password, modelContext: modelContext)
            isLoading = false
            
            if !success {
                errorMessage = "Invalid email or password. Please try again or create an account."
                showError = true
            }
        }
    }
}

#Preview {
    LoginView(authManager: AuthManager.shared)
        .modelContainer(for: User.self, inMemory: true)
}
