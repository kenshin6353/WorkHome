//
//  HealthKitManager.swift
//  WORKOUT
//
//  Created for WorkHome App
//

import Foundation
import HealthKit
import Combine

@MainActor
class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    
    #if DEBUG
    @Published var stepCount: Int = 6847  // Debug: Show sample step data
    @Published var caloriesBurned: Double = 342  // Debug: Show sample calories
    @Published var distanceWalked: Double = 4.8  // Debug: Show sample distance in km
    @Published var isAuthorized: Bool = true  // Debug: Assume authorized
    #else
    @Published var stepCount: Int = 0
    @Published var caloriesBurned: Double = 0
    @Published var distanceWalked: Double = 0 // in km
    @Published var isAuthorized: Bool = false
    #endif
    
    private init() {}
    
    // MARK: - Authorization
    func requestAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return false
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            await MainActor.run {
                self.isAuthorized = true
            }
            return true
        } catch {
            print("HealthKit authorization failed: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Fetch Today's Steps
    func fetchTodaySteps() async {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            guard let self = self, error == nil, let sum = result?.sumQuantity() else {
                return
            }
            
            let steps = Int(sum.doubleValue(for: HKUnit.count()))
            Task { @MainActor in
                self.stepCount = steps
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Fetch Today's Active Calories
    func fetchTodayCalories() async {
        guard let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: calorieType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            guard let self = self, error == nil, let sum = result?.sumQuantity() else {
                return
            }
            
            let calories = sum.doubleValue(for: HKUnit.kilocalorie())
            Task { @MainActor in
                self.caloriesBurned = calories
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Fetch Today's Distance
    func fetchTodayDistance() async {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else { return }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            guard let self = self, error == nil, let sum = result?.sumQuantity() else {
                return
            }
            
            let distance = sum.doubleValue(for: HKUnit.meterUnit(with: .kilo))
            Task { @MainActor in
                self.distanceWalked = distance
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Fetch All Today's Data
    func fetchAllTodayData() async {
        await fetchTodaySteps()
        await fetchTodayCalories()
        await fetchTodayDistance()
    }
    
    // MARK: - Calculate Step Progress
    var stepProgress: Double {
        Double(stepCount) / Double(Constants.defaultStepGoal)
    }
    
    var stepProgressPercentage: Int {
        Int(stepProgress * 100)
    }
}
