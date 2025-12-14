//
//  WorkoutSessionView.swift
//  WORKOUT
//
//  Created for WorkHome App
//

import SwiftUI
import Combine

struct WorkoutSessionView: View {
    let workoutType: Constants.WorkoutType
    @ObservedObject var authManager: AuthManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentExerciseIndex: Int = 0
    @State private var timeRemaining: Int = 30
    @State private var isRunning: Bool = true
    @State private var totalElapsed: Int = 0
    @State private var showRestModal: Bool = false
    @State private var showCompleteModal: Bool = false
    @State private var showExitAlert: Bool = false
    @State private var restTimeRemaining: Int = 15
    
    let exerciseDuration: Int = 30
    let restDuration: Int = 15
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(workoutType: Constants.WorkoutType, authManager: AuthManager) {
        self.workoutType = workoutType
        self.authManager = authManager
    }
    
    var exercises: [String] {
        workoutType.exercises
    }
    
    var currentExercise: String {
        exercises[currentExerciseIndex]
    }
    
    var progress: Double {
        1.0 - (Double(timeRemaining) / Double(exerciseDuration))
    }
    
    var workoutProgress: Double {
        let exerciseProgress = Double(currentExerciseIndex) / Double(exercises.count)
        let currentProgress = (1.0 - Double(timeRemaining) / Double(exerciseDuration)) / Double(exercises.count)
        return exerciseProgress + currentProgress
    }
    
    var totalDuration: Int {
        exercises.count * exerciseDuration
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "1F2937")
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: { showExitAlert = true }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 44, height: 44)
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text(workoutType.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("Exercise \(currentExerciseIndex + 1) of \(exercises.count)")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 44, height: 44)
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Timer Ring
                ZStack {
                    // Background ring
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                        .frame(width: 240, height: 240)
                    
                    // Progress ring
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient.primaryGradient,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 240, height: 240)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.5), value: progress)
                    
                    VStack(spacing: 4) {
                        Text("\(timeRemaining)")
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("seconds")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                // Exercise Name
                VStack(spacing: 8) {
                    Text(currentExercise)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("\(exerciseDuration) seconds")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Controls
                HStack(spacing: 24) {
                    Button(action: previousExercise) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 56, height: 56)
                            Image(systemName: "backward.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                        }
                    }
                    
                    Button(action: toggleTimer) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient.primaryGradient)
                                .frame(width: 80, height: 80)
                            Image(systemName: isRunning ? "pause.fill" : "play.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }
                    
                    Button(action: nextExercise) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 56, height: 56)
                            Image(systemName: "forward.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                        }
                    }
                }
                
                // Progress Bar
                VStack(spacing: 8) {
                    HStack {
                        Text(formatTime(totalElapsed))
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Text(formatTime(totalDuration))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(LinearGradient.primaryGradient)
                                .frame(width: geometry.size.width * workoutProgress, height: 8)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            
            // Rest Modal
            if showRestModal {
                RestModalView(
                    timeRemaining: $restTimeRemaining,
                    nextExercise: exercises[safe: currentExerciseIndex + 1] ?? "",
                    onSkip: skipRest
                )
            }
            
            // Complete Modal
            if showCompleteModal {
                WorkoutCompleteModal(
                    duration: totalDuration,
                    calories: workoutType.calories,
                    exercises: exercises.count,
                    onDone: {
                        // Record workout
                        authManager.recordWorkoutCompletion(
                            workoutType: workoutType.rawValue,
                            duration: totalDuration / 60,
                            caloriesBurned: workoutType.calories,
                            exercisesCompleted: exercises.count,
                            modelContext: modelContext
                        )
                        dismiss()
                    }
                )
            }
        }
        .onReceive(timer) { _ in
            guard isRunning && !showRestModal && !showCompleteModal else { return }
            
            if timeRemaining > 0 {
                timeRemaining -= 1
                totalElapsed += 1
            } else {
                // Exercise complete
                if currentExerciseIndex < exercises.count - 1 {
                    showRestModal = true
                    restTimeRemaining = restDuration
                } else {
                    showCompleteModal = true
                }
            }
        }
        .alert("Exit Workout?", isPresented: $showExitAlert) {
            Button("Continue", role: .cancel) {}
            Button("Exit", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Your progress will not be saved.")
        }
    }
    
    private func toggleTimer() {
        isRunning.toggle()
    }
    
    private func nextExercise() {
        if currentExerciseIndex < exercises.count - 1 {
            currentExerciseIndex += 1
            timeRemaining = exerciseDuration
        }
    }
    
    private func previousExercise() {
        if currentExerciseIndex > 0 {
            currentExerciseIndex -= 1
            timeRemaining = exerciseDuration
        }
    }
    
    private func skipRest() {
        showRestModal = false
        nextExercise()
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

// MARK: - Rest Modal
struct RestModalView: View {
    @Binding var timeRemaining: Int
    let nextExercise: String
    let onSkip: () -> Void
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Rest Time")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Text("\(timeRemaining)")
                    .font(.system(size: 96, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                VStack(spacing: 4) {
                    Text("Next:")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(nextExercise)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                Button(action: onSkip) {
                    Text("Skip Rest")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                }
            }
        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                onSkip()
            }
        }
    }
}

// MARK: - Workout Complete Modal
struct WorkoutCompleteModal: View {
    let duration: Int
    let calories: Int
    let exercises: Int
    let onDone: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Success Icon
                ZStack {
                    Circle()
                        .fill(LinearGradient.successGradient)
                        .frame(width: 96, height: 96)
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text("Workout Complete!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Great job! You crushed it!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Stats
                HStack(spacing: 16) {
                    StatBox(value: formatDuration(duration), label: "Duration")
                    StatBox(value: "\(calories)", label: "Calories")
                    StatBox(value: "\(exercises)", label: "Exercises")
                }
                .padding(.vertical)
                
                GradientButton("Done") {
                    onDone()
                }
                .padding(.horizontal, 40)
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 40)
            }
            .padding()
        }
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

struct StatBox: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Array Extension
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    WorkoutSessionView(
        workoutType: .fullBody,
        authManager: AuthManager.shared
    )
}
