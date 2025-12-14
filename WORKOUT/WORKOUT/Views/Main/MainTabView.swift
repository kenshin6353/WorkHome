//
//  MainTabView.swift
//  WORKOUT
//
//  Created for WorkHome App
//

import SwiftUI
import Combine

struct MainTabView: View {
    @ObservedObject var authManager: AuthManager
    @StateObject private var healthKitManager = HealthKitManager.shared
    
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(authManager: authManager, healthKitManager: healthKitManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            WorkoutListView(authManager: authManager)
                .tabItem {
                    Image(systemName: "dumbbell.fill")
                    Text("Workout")
                }
                .tag(1)
            
            NutritionView(authManager: authManager)
                .tabItem {
                    Image(systemName: "leaf.fill")
                    Text("Nutrition")
                }
                .tag(2)
            
            TrainersListView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Trainers")
                }
                .tag(3)
            
            UserProgressView(authManager: authManager)
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Progress")
                }
                .tag(4)
        }
        .tint(Color.gradientStart)
        .onAppear {
            // Request HealthKit authorization
            Task {
                let _ = await healthKitManager.requestAuthorization()
                await healthKitManager.fetchAllTodayData()
            }
        }
    }
}

#Preview {
    MainTabView(authManager: AuthManager.shared)
}
