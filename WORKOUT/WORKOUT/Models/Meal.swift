//
//  Meal.swift
//  WORKOUT
//
//  Created for WorkHome App
//

import Foundation
import SwiftData

@Model
final class Meal {
    var id: UUID
    var mealType: String // breakfast, lunch, dinner, snack
    var date: Date
    
    @Relationship(deleteRule: .cascade) var foodItems: [FoodItem]
    @Relationship(inverse: \User.meals) var user: User?
    
    var totalCalories: Int {
        foodItems.reduce(0) { $0 + $1.calories }
    }
    
    var totalProtein: Double {
        foodItems.reduce(0) { $0 + $1.protein }
    }
    
    var totalCarbs: Double {
        foodItems.reduce(0) { $0 + $1.carbs }
    }
    
    var totalFat: Double {
        foodItems.reduce(0) { $0 + $1.fat }
    }
    
    init(mealType: String, date: Date = Date()) {
        self.id = UUID()
        self.mealType = mealType
        self.date = date
        self.foodItems = []
    }
}
