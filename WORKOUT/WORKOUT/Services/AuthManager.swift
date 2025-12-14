//
//  AuthManager.swift
//  WORKOUT
//
//  Created for WorkHome App
//

import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    
    private init() {
        // Check if user was previously logged in
        isLoggedIn = UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.isLoggedIn)
    }
    
    // MARK: - Login
    func login(email: String, password: String, modelContext: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { user in
                user.email == email && user.password == password
            }
        )
        
        do {
            let users = try modelContext.fetch(descriptor)
            if let user = users.first {
                currentUser = user
                isLoggedIn = true
                UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKeys.isLoggedIn)
                UserDefaults.standard.set(user.id.uuidString, forKey: Constants.UserDefaultsKeys.currentUserID)
                return true
            }
        } catch {
            print("Login error: \(error)")
        }
        
        return false
    }
    
    // MARK: - Register
    func register(
        firstName: String,
        lastName: String,
        email: String,
        password: String,
        age: Int,
        height: Double,
        weight: Double,
        fitnessGoal: String,
        modelContext: ModelContext
    ) -> Bool {
        // Check if email already exists
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { user in
                user.email == email
            }
        )
        
        do {
            let existingUsers = try modelContext.fetch(descriptor)
            if !existingUsers.isEmpty {
                return false // Email already exists
            }
            
            // Create new user
            let newUser = User(
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password,
                age: age,
                height: height,
                weight: weight,
                fitnessGoal: fitnessGoal
            )
            
            // Add initial weight record
            let initialWeight = WeightRecord(weight: weight)
            newUser.weightRecords.append(initialWeight)
            
            modelContext.insert(newUser)
            try modelContext.save()
            
            return true
        } catch {
            print("Registration error: \(error)")
            return false
        }
    }
    
    // MARK: - Logout
    func logout() {
        currentUser = nil
        isLoggedIn = false
        UserDefaults.standard.set(false, forKey: Constants.UserDefaultsKeys.isLoggedIn)
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKeys.currentUserID)
    }
    
    // MARK: - Load Current User
    func loadCurrentUser(modelContext: ModelContext) {
        guard let userIDString = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.currentUserID),
              let userID = UUID(uuidString: userIDString) else {
            return
        }
        
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { user in
                user.id == userID
            }
        )
        
        do {
            let users = try modelContext.fetch(descriptor)
            currentUser = users.first
        } catch {
            print("Load user error: \(error)")
        }
    }
    
    // MARK: - Update User Profile
    func updateProfile(
        age: Int,
        height: Double,
        weight: Double,
        fitnessGoal: String,
        modelContext: ModelContext
    ) {
        guard let user = currentUser else { return }
        
        user.age = age
        user.height = height
        user.fitnessGoal = fitnessGoal
        
        // Add weight record if weight changed
        if user.weight != weight {
            let weightRecord = WeightRecord(weight: weight)
            user.weightRecords.append(weightRecord)
            user.weight = weight
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Update profile error: \(error)")
        }
    }
    
    // MARK: - Record Workout Completion
    func recordWorkoutCompletion(
        workoutType: String,
        duration: Int,
        caloriesBurned: Int,
        exercisesCompleted: Int,
        modelContext: ModelContext
    ) {
        guard let user = currentUser else { return }
        
        let record = WorkoutRecord(
            workoutType: workoutType,
            duration: duration,
            caloriesBurned: caloriesBurned,
            exercisesCompleted: exercisesCompleted
        )
        
        user.workoutHistory.append(record)
        user.totalWorkouts += 1
        user.totalCaloriesBurned += caloriesBurned
        user.totalPoints += 50 // Base points for workout completion
        
        // Update streak
        updateStreak(for: user)
        
        // Check achievements
        checkAchievements(for: user, modelContext: modelContext)
        
        do {
            try modelContext.save()
        } catch {
            print("Record workout error: \(error)")
        }
    }
    
    // MARK: - Update Streak
    private func updateStreak(for user: User) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Get yesterday's date
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return }
        
        // Check if user worked out yesterday
        let workedOutYesterday = user.workoutHistory.contains { record in
            let recordDate = calendar.startOfDay(for: record.completedAt)
            return recordDate == yesterday
        }
        
        // Check if already worked out today
        let workedOutToday = user.workoutHistory.filter { record in
            let recordDate = calendar.startOfDay(for: record.completedAt)
            return recordDate == today
        }.count > 1 // More than 1 because we just added one
        
        if workedOutYesterday || workedOutToday {
            // Continue or maintain streak
            if !workedOutToday {
                user.currentStreak += 1
            }
        } else {
            // Reset streak
            user.currentStreak = 1
        }
        
        // Update best streak
        if user.currentStreak > user.bestStreak {
            user.bestStreak = user.currentStreak
        }
    }
    
    // MARK: - Check Achievements
    private func checkAchievements(for user: User, modelContext: ModelContext) {
        let unlockedIds = Set(user.achievements.map { $0.achievementId })
        
        // Check workout achievements
        let workoutAchievements = [
            ("workout_1", 1),
            ("workout_10", 10),
            ("workout_50", 50),
            ("workout_100", 100),
            ("workout_500", 500)
        ]
        
        for (achievementId, requirement) in workoutAchievements {
            if !unlockedIds.contains(achievementId) && user.totalWorkouts >= requirement {
                let achievement = UserAchievement(achievementId: achievementId, progress: user.totalWorkouts)
                user.achievements.append(achievement)
                
                if let achDef = AchievementManager.achievement(for: achievementId) {
                    user.totalPoints += achDef.points
                }
            }
        }
        
        // Check streak achievements
        let streakAchievements = [
            ("streak_3", 3),
            ("streak_7", 7),
            ("streak_30", 30)
        ]
        
        for (achievementId, requirement) in streakAchievements {
            if !unlockedIds.contains(achievementId) && user.currentStreak >= requirement {
                let achievement = UserAchievement(achievementId: achievementId, progress: user.currentStreak)
                user.achievements.append(achievement)
                
                if let achDef = AchievementManager.achievement(for: achievementId) {
                    user.totalPoints += achDef.points
                }
            }
        }
        
        // Check night owl achievement
        let hour = Calendar.current.component(.hour, from: Date())
        if !unlockedIds.contains("night_owl") && hour >= 21 {
            let achievement = UserAchievement(achievementId: "night_owl", progress: 1)
            user.achievements.append(achievement)
            
            if let achDef = AchievementManager.achievement(for: "night_owl") {
                user.totalPoints += achDef.points
            }
        }
        
        // Update level based on points
        user.level = (user.totalPoints / 1000) + 1
    }
}
