//
//  HomeView.swift
//  WORKOUT
//
//  Created for WorkHome App
//

import SwiftUI
import Combine

struct HomeView: View {
    @ObservedObject var authManager: AuthManager
    @ObservedObject var healthKitManager: HealthKitManager
    
    @State private var showProfile: Bool = false
    @State private var showWorkoutSession: Bool = false
    @State private var selectedWorkoutType: Constants.WorkoutType = .fullBody
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return "Good morning,"
        } else if hour < 17 {
            return "Good afternoon,"
        } else {
            return "Good evening,"
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(greeting)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(authManager.currentUser?.firstName ?? "User")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                        
                        Button(action: { showProfile = true }) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient.primaryGradient)
                                    .frame(width: 44, height: 44)
                                
                                Text(authManager.currentUser?.initials ?? "U")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Today's Workout Card
                    TodayWorkoutCard(
                        workoutName: "Full Body Burn",
                        duration: 30,
                        exerciseCount: 8,
                        level: "Intermediate"
                    ) {
                        selectedWorkoutType = .fullBody
                        showWorkoutSession = true
                    }
                    .padding(.horizontal)
                    
                    // Step Counter Card
                    StepCounterCard(
                        steps: healthKitManager.stepCount,
                        goal: Constants.defaultStepGoal,
                        calories: Int(healthKitManager.caloriesBurned),
                        distance: healthKitManager.distanceWalked
                    )
                    .padding(.horizontal)
                    
                    // Quick Stats
                    HStack(spacing: 16) {
                        StatCard(
                            value: "\(authManager.currentUser?.totalCaloriesBurned ?? 0)",
                            label: "Calories burned",
                            iconName: "flame.fill",
                            iconColor: .orange,
                            iconBgColor: .orange.opacity(0.1)
                        )
                        
                        StatCard(
                            value: "\(authManager.currentUser?.totalWorkouts ?? 0)",
                            label: "Workouts this week",
                            iconName: "dumbbell.fill",
                            iconColor: .blue,
                            iconBgColor: .blue.opacity(0.1)
                        )
                    }
                    .padding(.horizontal)
                    
                    // Streak Card
                    StreakCard(
                        currentStreak: authManager.currentUser?.currentStreak ?? 0,
                        bestStreak: authManager.currentUser?.bestStreak ?? 0
                    )
                    .padding(.horizontal)
                    
                    // Recent Achievement
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recent Achievement")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            NavigationLink(destination: AchievementsView(authManager: authManager)) {
                                Text("View All")
                                    .font(.subheadline)
                                    .foregroundColor(.gradientStart)
                            }
                        }
                        
                        if let lastAchievement = authManager.currentUser?.achievements.last,
                           let achievement = AchievementManager.achievement(for: lastAchievement.achievementId) {
                            AchievementCard(
                                title: achievement.title,
                                description: achievement.description,
                                iconName: achievement.iconName,
                                isNew: true
                            )
                        } else {
                            AchievementCard(
                                title: "Week Warrior",
                                description: "Complete 7 workouts in a week",
                                iconName: "trophy.fill",
                                isNew: false
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 100)
                }
                .padding(.top)
            }
            .background(Color.backgroundGray)
            .refreshable {
                await healthKitManager.fetchAllTodayData()
            }
            .navigationDestination(isPresented: $showProfile) {
                ProfileView(authManager: authManager)
            }
            .fullScreenCover(isPresented: $showWorkoutSession) {
                WorkoutSessionView(
                    workoutType: selectedWorkoutType,
                    authManager: authManager
                )
            }
        }
    }
}

// MARK: - Step Counter Card
struct StepCounterCard: View {
    let steps: Int
    let goal: Int
    let calories: Int
    let distance: Double
    
    var progress: Double {
        min(Double(steps) / Double(goal), 1.0)
    }
    
    var percentage: Int {
        Int(progress * 100)
    }
    
    var body: some View {
        HStack(spacing: 20) {
            // Step Ring
            ZStack {
                CircularProgressView(progress: progress)
                    .frame(width: 96, height: 96)
                
                VStack(spacing: 2) {
                    Image(systemName: "figure.walk")
                        .font(.title3)
                        .foregroundColor(.gradientStart)
                    Text("\(percentage)%")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Today's Steps")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    Text("Goal: \(goal.formatted())")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(steps.formatted())
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("steps today")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(calories) cal")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "figure.walk")
                            .foregroundColor(.blue)
                        Text(String(format: "%.1f km", distance))
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

#Preview {
    HomeView(authManager: AuthManager.shared, healthKitManager: HealthKitManager.shared)
}
