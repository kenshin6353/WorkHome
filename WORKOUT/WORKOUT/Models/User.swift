//
//  User.swift
//  WORKOUT
//
//  Created for WorkHome App
//

import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var password: String
    var age: Int
    var height: Double // in cm
    var weight: Double // in kg
    var startingWeight: Double // initial weight when registered
    var fitnessGoal: String
    var createdAt: Date
    var currentStreak: Int
    var bestStreak: Int
    var totalWorkouts: Int
    var totalCaloriesBurned: Int
    var totalPoints: Int
    var level: Int
    
    // Notification Settings
    var workoutReminders: Bool
    var mealReminders: Bool
    var achievementAlerts: Bool
    var stepGoalAlerts: Bool
    
    // Relationships
    @Relationship(deleteRule: .cascade) var workoutHistory: [WorkoutRecord]
    @Relationship(deleteRule: .cascade) var meals: [Meal]
    @Relationship(deleteRule: .cascade) var weightRecords: [WeightRecord]
    @Relationship(deleteRule: .cascade) var achievements: [UserAchievement]
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var initials: String {
        let firstInitial = firstName.first.map { String($0) } ?? ""
        let lastInitial = lastName.first.map { String($0) } ?? ""
        return "\(firstInitial)\(lastInitial)"
    }
    
    var bmi: Double {
        let heightInMeters = height / 100
        return weight / (heightInMeters * heightInMeters)
    }
    
    var bmiCategory: String {
        switch bmi {
        case ..<18.5: return "Underweight"
        case 18.5..<25: return "Normal"
        case 25..<30: return "Overweight"
        default: return "Obese"
        }
    }
    
    var xpForNextLevel: Int {
        return level * 1000
    }
    
    var currentXP: Int {
        return totalPoints % 1000
    }
    
    init(
        firstName: String,
        lastName: String,
        email: String,
        password: String,
        age: Int,
        height: Double,
        weight: Double,
        fitnessGoal: String
    ) {
        self.id = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.password = password
        self.age = age
        self.height = height
        self.weight = weight
        self.startingWeight = weight // Store initial weight
        self.fitnessGoal = fitnessGoal
        self.createdAt = Date()
        self.currentStreak = 0
        self.bestStreak = 0
        self.totalWorkouts = 0
        self.totalCaloriesBurned = 0
        self.totalPoints = 0
        self.level = 1
        self.workoutReminders = true
        self.mealReminders = true
        self.achievementAlerts = true
        self.stepGoalAlerts = false
        self.workoutHistory = []
        self.meals = []
        self.weightRecords = []
        self.achievements = []
    }
}
