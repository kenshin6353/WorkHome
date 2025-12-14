//
//  UserAchievement.swift
//  WORKOUT
//
//  Created for WorkHome App
//

import Foundation
import SwiftData

@Model
final class UserAchievement {
    var id: UUID
    var achievementId: String
    var unlockedAt: Date
    var progress: Int // Current progress towards achievement
    
    @Relationship(inverse: \User.achievements) var user: User?
    
    init(achievementId: String, progress: Int = 0) {
        self.id = UUID()
        self.achievementId = achievementId
        self.progress = progress
        self.unlockedAt = Date()
    }
}

// MARK: - Achievement Definitions
struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let category: AchievementCategory
    let requirement: Int
    let points: Int
    
    enum AchievementCategory: String, CaseIterable {
        case streak = "Streak"
        case workout = "Workout"
        case weight = "Weight"
        case steps = "Steps"
    }
}

struct AchievementManager {
    static let allAchievements: [Achievement] = [
        // Streak Achievements
        Achievement(id: "streak_3", title: "3-Day Streak", description: "Workout 3 days in a row", iconName: "flame.fill", category: .streak, requirement: 3, points: 100),
        Achievement(id: "streak_7", title: "7-Day Streak", description: "Workout 7 days in a row", iconName: "flame.fill", category: .streak, requirement: 7, points: 250),
        Achievement(id: "streak_30", title: "30-Day Streak", description: "Workout 30 days in a row", iconName: "flame.fill", category: .streak, requirement: 30, points: 1000),
        
        // Workout Achievements
        Achievement(id: "workout_1", title: "First Workout", description: "Complete your first workout", iconName: "dumbbell.fill", category: .workout, requirement: 1, points: 50),
        Achievement(id: "workout_10", title: "10 Workouts", description: "Complete 10 workouts", iconName: "dumbbell.fill", category: .workout, requirement: 10, points: 200),
        Achievement(id: "workout_50", title: "50 Workouts", description: "Complete 50 workouts", iconName: "dumbbell.fill", category: .workout, requirement: 50, points: 500),
        Achievement(id: "workout_100", title: "100 Workouts", description: "Complete 100 workouts", iconName: "dumbbell.fill", category: .workout, requirement: 100, points: 1000),
        Achievement(id: "workout_500", title: "500 Workouts", description: "Complete 500 workouts", iconName: "crown.fill", category: .workout, requirement: 500, points: 2500),
        Achievement(id: "night_owl", title: "Night Owl", description: "Complete a workout after 9 PM", iconName: "moon.fill", category: .workout, requirement: 1, points: 100),
        
        // Weight Achievements
        Achievement(id: "weight_1", title: "First Kg Lost", description: "Lose your first kilogram", iconName: "scalemass.fill", category: .weight, requirement: 1, points: 200),
        Achievement(id: "weight_3", title: "3 Kg Lost", description: "Lose 3 kilograms", iconName: "scalemass.fill", category: .weight, requirement: 3, points: 400),
        Achievement(id: "weight_5", title: "5 Kg Lost", description: "Lose 5 kilograms", iconName: "scalemass.fill", category: .weight, requirement: 5, points: 600),
        
        // Step Achievements
        Achievement(id: "steps_10k", title: "10K Steps", description: "Walk 10,000 steps in a day", iconName: "figure.walk", category: .steps, requirement: 10000, points: 150),
        Achievement(id: "steps_15k", title: "15K Steps", description: "Walk 15,000 steps in a day", iconName: "figure.walk", category: .steps, requirement: 15000, points: 250),
        Achievement(id: "steps_20k", title: "20K Steps", description: "Walk 20,000 steps in a day", iconName: "figure.walk", category: .steps, requirement: 20000, points: 400),
    ]
    
    static func achievement(for id: String) -> Achievement? {
        allAchievements.first { $0.id == id }
    }
    
    static func achievements(for category: Achievement.AchievementCategory) -> [Achievement] {
        allAchievements.filter { $0.category == category }
    }
}
