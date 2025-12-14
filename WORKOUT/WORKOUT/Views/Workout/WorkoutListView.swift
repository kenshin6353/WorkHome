//
//  WorkoutListView.swift
//  WORKOUT
//
//  Created for WorkHome App
//

import SwiftUI
import Combine

struct WorkoutListView: View {
    @ObservedObject var authManager: AuthManager
    
    @State private var showWorkoutDetail: Bool = false
    @State private var showWorkoutSession: Bool = false
    @State private var selectedWorkout: Constants.WorkoutType = .fullBody
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(Constants.WorkoutType.allCases) { workoutType in
                        WorkoutCard(workoutType: workoutType) {
                            selectedWorkout = workoutType
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                showWorkoutDetail = true
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color.backgroundGray)
            .navigationTitle("Home Workouts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("No equipment needed")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .sheet(isPresented: $showWorkoutDetail) {
                WorkoutDetailSheet(
                    workoutType: selectedWorkout,
                    onStart: {
                        showWorkoutDetail = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showWorkoutSession = true
                        }
                    }
                )
                .presentationDetents([.medium, .large])
                .id(selectedWorkout.id)
            }
            .fullScreenCover(isPresented: $showWorkoutSession) {
                WorkoutSessionView(
                    workoutType: selectedWorkout,
                    authManager: authManager
                )
            }
        }
    }
}

// MARK: - Workout Card
struct WorkoutCard: View {
    let workoutType: Constants.WorkoutType
    let action: () -> Void
    
    var iconColor: Color {
        switch workoutType.colorName {
        case "blue": return .workoutBlue
        case "green": return .workoutGreen
        case "orange": return .workoutOrange
        case "purple": return .workoutPurple
        case "red": return .workoutRed
        case "teal": return .workoutTeal
        default: return .blue
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [iconColor, iconColor.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: workoutType.iconName)
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(workoutType.rawValue)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(workoutType.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.caption2)
                            Text("\(workoutType.duration) min")
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.caption2)
                            Text("\(workoutType.calories) cal")
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Workout Detail Sheet
struct WorkoutDetailSheet: View {
    let workoutType: Constants.WorkoutType
    let onStart: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var iconColor: Color {
        switch workoutType.colorName {
        case "blue": return .workoutBlue
        case "green": return .workoutGreen
        case "orange": return .workoutOrange
        case "purple": return .workoutPurple
        case "red": return .workoutRed
        case "teal": return .workoutTeal
        default: return .blue
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text(workoutType.rawValue)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(workoutType.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                LinearGradient(
                    colors: [iconColor, iconColor.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Exercises
                    Text("Exercises")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 12) {
                        ForEach(Array(workoutType.exercises.enumerated()), id: \.offset) { index, exercise in
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color.gray.opacity(0.1))
                                        .frame(width: 28, height: 28)
                                    Text("\(index + 1)")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.gray)
                                }
                                
                                Text(exercise)
                                    .font(.subheadline)
                                
                                Spacer()
                            }
                            .padding(.vertical, 8)
                            
                            if index < workoutType.exercises.count - 1 {
                                Divider()
                            }
                        }
                    }
                    
                    // Stats
                    HStack(spacing: 20) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.gray)
                            Text("\(workoutType.duration) min")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.gray)
                            Text("\(workoutType.calories) cal")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "square.stack.fill")
                                .foregroundColor(.gray)
                            Text("\(workoutType.exercises.count) exercises")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            
            // Buttons
            VStack(spacing: 12) {
                GradientButton("Start Workout", icon: "play.fill") {
                    onStart()
                }
                
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.gray)
            }
            .padding()
        }
    }
}

#Preview {
    WorkoutListView(authManager: AuthManager.shared)
}
