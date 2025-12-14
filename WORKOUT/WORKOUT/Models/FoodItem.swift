//
//  FoodItem.swift
//  WORKOUT
//
//  Created for WorkHome App
//

import Foundation
import SwiftData

@Model
final class FoodItem {
    var id: UUID
    var name: String
    var servingSize: String
    var servingCount: Double
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double
    var addedAt: Date
    
    @Relationship(inverse: \Meal.foodItems) var meal: Meal?
    
    init(
        name: String,
        servingSize: String,
        servingCount: Double = 1.0,
        calories: Int,
        protein: Double,
        carbs: Double,
        fat: Double
    ) {
        self.id = UUID()
        self.name = name
        self.servingSize = servingSize
        self.servingCount = servingCount
        self.calories = Int(Double(calories) * servingCount)
        self.protein = protein * servingCount
        self.carbs = carbs * servingCount
        self.fat = fat * servingCount
        self.addedAt = Date()
    }
}
