//
//  WeightRecord.swift
//  WORKOUT
//
//  Created for WorkHome App
//

import Foundation
import SwiftData

@Model
final class WeightRecord {
    var id: UUID
    var weight: Double // in kg
    var recordedAt: Date
    
    @Relationship(inverse: \User.weightRecords) var user: User?
    
    init(weight: Double) {
        self.id = UUID()
        self.weight = weight
        self.recordedAt = Date()
    }
}
