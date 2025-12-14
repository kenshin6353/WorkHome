//
//  RegisterView.swift
//  WORKOUT
//
//  Created for WorkHome App
//

import SwiftUI
import SwiftData
import Combine

struct RegisterView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var authManager: AuthManager
    
    // Form fields
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var age: Int = 25
    @State private var height: Int = 170
    @State private var weight: Int = 70
    @State private var selectedGoal: Constants.FitnessGoal = .loseWeight
    
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showSuccess: Bool = false
    
    let ages = Array(16...80)
    let heights = Array(140...220)
    let weights = Array(40...150)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Basic Information Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Basic Information")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Tell us a bit about yourself")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    // Name Fields
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("First Name")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            TextField("John", text: $firstName)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Last Name")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            TextField("Doe", text: $lastName)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                    
                    // Email
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        TextField("john.doe@example.com", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    // Password
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            if showPassword {
                                TextField("Create a strong password", text: $password)
                            } else {
                                SecureField("Create a strong password", text: $password)
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
                    
                    // Personal Info Pickers
                    HStack(spacing: 12) {
                        // Age
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Age")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            Picker("Age", selection: $age) {
                                ForEach(ages, id: \.self) { age in
                                    Text("\(age)").tag(age)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            
                            Text("years")
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                        }
                        
                        // Height
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Height")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            Picker("Height", selection: $height) {
                                ForEach(heights, id: \.self) { h in
                                    Text("\(h)").tag(h)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            
                            Text("cm")
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                        }
                        
                        // Weight
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Weight")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            Picker("Weight", selection: $weight) {
                                ForEach(weights, id: \.self) { w in
                                    Text("\(w)").tag(w)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            
                            Text("kg")
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 10)
                
                // Fitness Goal Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Fitness Goal")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    ForEach(Constants.FitnessGoal.allCases) { goal in
                        GoalSelectionRow(
                            goal: goal,
                            isSelected: selectedGoal == goal
                        ) {
                            selectedGoal = goal
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 10)
                
                // Create Account Button
                GradientButton("Create Account", icon: "arrow.right", isLoading: isLoading) {
                    register()
                }
                
                // Terms
                Text("By continuing, you agree to our Terms of Service and Privacy Policy")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                // Sign In Link
                HStack {
                    Text("Already have an account?")
                        .foregroundColor(.gray)
                    
                    Button(action: { dismiss() }) {
                        Text("Sign in")
                            .fontWeight(.semibold)
                            .foregroundColor(.gradientStart)
                    }
                }
                .font(.subheadline)
                .padding(.bottom, 20)
            }
            .padding()
        }
        .background(Color.backgroundGray)
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Registration Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .alert("Success!", isPresented: $showSuccess) {
            Button("Sign In") {
                dismiss()
            }
        } message: {
            Text("Account created successfully! Please sign in with your credentials.")
        }
    }
    
    private func register() {
        // Validation
        guard !firstName.isEmpty else {
            errorMessage = "Please enter your first name"
            showError = true
            return
        }
        
        guard !lastName.isEmpty else {
            errorMessage = "Please enter your last name"
            showError = true
            return
        }
        
        guard !email.isEmpty, email.contains("@") else {
            errorMessage = "Please enter a valid email address"
            showError = true
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            showError = true
            return
        }
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let success = authManager.register(
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password,
                age: age,
                height: Double(height),
                weight: Double(weight),
                fitnessGoal: selectedGoal.rawValue,
                modelContext: modelContext
            )
            
            isLoading = false
            
            if success {
                showSuccess = true
            } else {
                errorMessage = "An account with this email already exists."
                showError = true
            }
        }
    }
}

// MARK: - Goal Selection Row
struct GoalSelectionRow: View {
    let goal: Constants.FitnessGoal
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.gradientStart : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.gradientStart)
                            .frame(width: 14, height: 14)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(goal.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding()
            .background(isSelected ? Color.gradientStart.opacity(0.1) : Color.gray.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.gradientStart : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

#Preview {
    NavigationStack {
        RegisterView(authManager: AuthManager.shared)
    }
    .modelContainer(for: User.self, inMemory: true)
}
