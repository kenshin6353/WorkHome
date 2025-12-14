//
//  ProfileView.swift
//  WORKOUT
//
//  Created for WorkHome App
//

import SwiftUI
import Combine

struct ProfileView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showEditProfile: Bool = false
    @State private var showLogoutAlert: Bool = false
    
    // Notification toggles
    @State private var workoutReminders: Bool = true
    @State private var mealReminders: Bool = true
    @State private var achievementAlerts: Bool = true
    @State private var stepGoalAlerts: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Card
                VStack(spacing: 16) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(LinearGradient.primaryGradient)
                            .frame(width: 96, height: 96)
                            .shadow(color: .gradientStart.opacity(0.3), radius: 10)
                        
                        Text(authManager.currentUser?.initials ?? "JD")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    // Name & Email
                    VStack(spacing: 4) {
                        Text(authManager.currentUser?.fullName ?? "John Doe")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(authManager.currentUser?.email ?? "john.doe@example.com")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // Stats
                    HStack(spacing: 32) {
                        ProfileStat(value: "\(authManager.currentUser?.totalWorkouts ?? 24)", label: "Workouts")
                        
                        Divider()
                            .frame(height: 40)
                        
                        ProfileStat(value: "\(authManager.currentUser?.currentStreak ?? 7)", label: "Day Streak")
                        
                        Divider()
                            .frame(height: 40)
                        
                        ProfileStat(value: "\(authManager.currentUser?.achievements.count ?? 8)", label: "Badges")
                    }
                }
                .padding()
                .cardStyle()
                .padding(.horizontal)
                
                // Personal Information
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Personal Information")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button("Edit") {
                            showEditProfile = true
                        }
                        .font(.subheadline)
                        .foregroundColor(.gradientStart)
                    }
                    .padding()
                    
                    Divider()
                    
                    // Rows
                    ProfileInfoRow(icon: "person.fill", label: "Age", value: "\(authManager.currentUser?.age ?? 25) years")
                    ProfileInfoRow(icon: "ruler.fill", label: "Height", value: "\(Int(authManager.currentUser?.height ?? 170)) cm")
                    ProfileInfoRow(icon: "scalemass.fill", label: "Weight", value: "\(Int(authManager.currentUser?.weight ?? 72)) kg")
                    ProfileInfoRow(icon: "target", label: "Goal", value: authManager.currentUser?.fitnessGoal ?? "Lose Weight")
                }
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.08), radius: 15)
                .padding(.horizontal)
                
                // Notifications
                VStack(spacing: 0) {
                    HStack {
                        Text("Notifications")
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding()
                    
                    Divider()
                    
                    NotificationToggleRow(icon: "bell.fill", label: "Workout Reminders", isOn: $workoutReminders)
                    NotificationToggleRow(icon: "fork.knife", label: "Meal Reminders", isOn: $mealReminders)
                    NotificationToggleRow(icon: "trophy.fill", label: "Achievement Alerts", isOn: $achievementAlerts)
                    NotificationToggleRow(icon: "figure.walk", label: "Step Goal Alerts", isOn: $stepGoalAlerts)
                }
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.08), radius: 15)
                .padding(.horizontal)
                
                // Settings
                VStack(spacing: 0) {
                    HStack {
                        Text("Settings")
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding()
                    
                    Divider()
                    
                    SettingsRow(icon: "lock.fill", label: "Change Password")
                    SettingsRow(icon: "globe", label: "Language", value: "English")
                    SettingsRow(icon: "ruler", label: "Units", value: "Metric")
                    SettingsRow(icon: "questionmark.circle.fill", label: "Help & Support")
                    SettingsRow(icon: "doc.text.fill", label: "Privacy Policy")
                }
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.08), radius: 15)
                .padding(.horizontal)
                
                // Logout Button
                DangerButton("Log Out", icon: "rectangle.portrait.and.arrow.right") {
                    showLogoutAlert = true
                }
                .padding(.horizontal)
                
                // Version
                Text("WorkHome v1.0.0")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
            }
            .padding(.top)
        }
        .background(Color.backgroundGray)
        .navigationTitle("Profile")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(isPresented: $showEditProfile) {
            EditProfileSheet(authManager: authManager)
        }
        .alert("Log Out", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Log Out", role: .destructive) {
                authManager.logout()
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
    }
}

// MARK: - Profile Stat
struct ProfileStat: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Profile Info Row
struct ProfileInfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                    .frame(width: 24)
                Text(label)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
        .padding()
    }
}

// MARK: - Notification Toggle Row
struct NotificationToggleRow: View {
    let icon: String
    let label: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                    .frame(width: 24)
                Text(label)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(.gradientStart)
        }
        .padding()
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let label: String
    var value: String? = nil
    
    var body: some View {
        Button(action: {}) {
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .foregroundColor(.gray)
                        .frame(width: 24)
                    Text(label)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                if let value = value {
                    Text(value)
                        .foregroundColor(.gray)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }
}

// MARK: - Edit Profile Sheet
struct EditProfileSheet: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var age: Int = 25
    @State private var height: Int = 170
    @State private var weight: Int = 72
    @State private var selectedGoal: Constants.FitnessGoal = .loseWeight
    
    let ages = Array(16...80)
    let heights = Array(140...220)
    let weights = Array(40...150)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Age
                VStack(alignment: .leading, spacing: 8) {
                    Text("Age")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Picker("Age", selection: $age) {
                        ForEach(ages, id: \.self) { age in
                            Text("\(age) years").tag(age)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
                }
                
                // Height
                VStack(alignment: .leading, spacing: 8) {
                    Text("Height (cm)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Height", value: $height, format: .number)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                
                // Weight
                VStack(alignment: .leading, spacing: 8) {
                    Text("Weight (kg)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Weight", value: $weight, format: .number)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                
                // Goal
                VStack(alignment: .leading, spacing: 8) {
                    Text("Goal")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Picker("Goal", selection: $selectedGoal) {
                        ForEach(Constants.FitnessGoal.allCases) { goal in
                            Text(goal.rawValue).tag(goal)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Spacer()
                
                GradientButton("Save Changes") {
                    authManager.updateProfile(
                        age: age,
                        height: Double(height),
                        weight: Double(weight),
                        fitnessGoal: selectedGoal.rawValue,
                        modelContext: modelContext
                    )
                    dismiss()
                }
            }
            .padding()
            .navigationTitle("Edit Personal Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.gray)
                }
            }
            .onAppear {
                age = authManager.currentUser?.age ?? 25
                height = Int(authManager.currentUser?.height ?? 170)
                weight = Int(authManager.currentUser?.weight ?? 72)
                if let goalString = authManager.currentUser?.fitnessGoal,
                   let goal = Constants.FitnessGoal(rawValue: goalString) {
                    selectedGoal = goal
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(authManager: AuthManager.shared)
    }
}
