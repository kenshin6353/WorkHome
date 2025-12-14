//
//  WorkoutRecord.swift
//  WORKOUT
//
//  Created for WorkHome App
//

import Foundation
import SwiftData

@Model
final class WorkoutRecord {
    var id: UUID
    var workoutType: String
    var duration: Int // in minutes
    var caloriesBurned: Int
    var exercisesCompleted: Int
    var completedAt: Date
    
    @Relationship(inverse: \User.workoutHistory) var user: User?
    
    init(workoutType: String, duration: Int, caloriesBurned: Int, exercisesCompleted: Int) {
        self.id = UUID()
        self.workoutType = workoutType
        self.duration = duration
        self.caloriesBurned = caloriesBurned
        self.exercisesCompleted = exercisesCompleted
        self.completedAt = Date()
    }
}
