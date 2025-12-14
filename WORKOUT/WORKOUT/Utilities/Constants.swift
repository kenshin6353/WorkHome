//
//  Constants.swift
//  WORKOUT
//
//  Created for WorkHome App
//

import Foundation

struct Constants {
    // MARK: - API Keys
    static let usdaAPIKey = "5IEq0rwfrf1SaCSpiT2CWfZaWb5ufJhRKurDsigG"
    static let usdaBaseURL = "https://api.nal.usda.gov/fdc/v1"
    
    // MARK: - App Settings
    static let defaultStepGoal = 10000
    static let defaultCalorieGoal = 2500
    
    // MARK: - User Defaults Keys
    struct UserDefaultsKeys {
        static let isLoggedIn = "isLoggedIn"
        static let currentUserID = "currentUserID"
        static let stepGoal = "stepGoal"
        static let calorieGoal = "calorieGoal"
        static let workoutReminders = "workoutReminders"
        static let mealReminders = "mealReminders"
        static let achievementAlerts = "achievementAlerts"
        static let stepGoalAlerts = "stepGoalAlerts"
    }
    
    // MARK: - Workout Types
    enum WorkoutType: String, CaseIterable, Identifiable {
        case upperBody = "Upper Body"
        case lowerBody = "Lower Body"
        case core = "Core"
        case fullBody = "Full Body"
        case cardio = "Cardio HIIT"
        case stretching = "Stretching"
        
        var id: String { rawValue }
        
        var subtitle: String {
            switch self {
            case .upperBody: return "Chest, Arms, Shoulders"
            case .lowerBody: return "Legs, Glutes, Calves"
            case .core: return "Abs, Obliques, Back"
            case .fullBody: return "Complete workout"
            case .cardio: return "High intensity intervals"
            case .stretching: return "Flexibility & Recovery"
            }
        }
        
        var duration: Int {
            switch self {
            case .upperBody: return 25
            case .lowerBody: return 30
            case .core: return 20
            case .fullBody: return 35
            case .cardio: return 20
            case .stretching: return 15
            }
        }
        
        var calories: Int {
            switch self {
            case .upperBody: return 180
            case .lowerBody: return 220
            case .core: return 150
            case .fullBody: return 280
            case .cardio: return 250
            case .stretching: return 50
            }
        }
        
        var iconName: String {
            switch self {
            case .upperBody: return "figure.arms.open"
            case .lowerBody: return "figure.walk"
            case .core: return "circle.fill"
            case .fullBody: return "figure.stand"
            case .cardio: return "heart.fill"
            case .stretching: return "leaf.fill"
            }
        }
        
        var colorName: String {
            switch self {
            case .upperBody: return "blue"
            case .lowerBody: return "green"
            case .core: return "orange"
            case .fullBody: return "purple"
            case .cardio: return "red"
            case .stretching: return "teal"
            }
        }
        
        var exercises: [String] {
            switch self {
            case .upperBody:
                return ["Push-ups", "Diamond Push-ups", "Pike Push-ups", "Tricep Dips", "Plank Shoulder Taps", "Arm Circles"]
            case .lowerBody:
                return ["Squats", "Lunges", "Glute Bridges", "Calf Raises", "Wall Sit", "Jump Squats", "Side Lunges"]
            case .core:
                return ["Crunches", "Plank", "Russian Twists", "Leg Raises", "Mountain Climbers", "Dead Bug"]
            case .fullBody:
                return ["Burpees", "Squats", "Push-ups", "Lunges", "Plank", "Mountain Climbers", "Jump Squats", "Tricep Dips"]
            case .cardio:
                return ["Jumping Jacks", "High Knees", "Burpees", "Mountain Climbers", "Jump Squats", "Skaters"]
            case .stretching:
                return ["Neck Stretch", "Shoulder Stretch", "Quad Stretch", "Hamstring Stretch", "Hip Flexor Stretch", "Cat-Cow"]
            }
        }
    }
    
    // MARK: - Fitness Goals
    enum FitnessGoal: String, CaseIterable, Identifiable {
        case loseWeight = "Lose Weight"
        case buildMuscle = "Build Muscle"
        case stayFit = "Stay Fit"
        
        var id: String { rawValue }
        
        var description: String {
            switch self {
            case .loseWeight: return "Burn fat and get lean"
            case .buildMuscle: return "Gain strength and size"
            case .stayFit: return "Maintain current fitness"
            }
        }
    }
    
    // MARK: - Meal Types
    enum MealType: String, CaseIterable, Identifiable {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
        case snack = "Snack"
        
        var id: String { rawValue }
        
        var iconName: String {
            switch self {
            case .breakfast: return "sun.max.fill"
            case .lunch: return "cloud.sun.fill"
            case .dinner: return "moon.fill"
            case .snack: return "leaf.fill"
            }
        }
        
        var iconColor: String {
            switch self {
            case .breakfast: return "yellow"
            case .lunch: return "orange"
            case .dinner: return "purple"
            case .snack: return "pink"
            }
        }
    }
}
