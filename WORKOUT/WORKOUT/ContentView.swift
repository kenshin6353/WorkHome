//
//  ContentView.swift
//  WORKOUT
//
//  Created by kenshin lai on 12/12/2025.
//

import SwiftUI
import SwiftData
import Combine

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var authManager: AuthManager

    var body: some View {
        Group {
            if authManager.isLoggedIn {
                MainTabView(authManager: authManager)
                    .onAppear {
                        authManager.loadCurrentUser(modelContext: modelContext)
                    }
            } else {
                LoginView(authManager: authManager)
            }
        }
        .animation(.easeInOut, value: authManager.isLoggedIn)
    }
}

#Preview {
    ContentView(authManager: AuthManager.shared)
        .modelContainer(for: [User.self, WorkoutRecord.self, Meal.self, FoodItem.self, WeightRecord.self, UserAchievement.self], inMemory: true)
}
