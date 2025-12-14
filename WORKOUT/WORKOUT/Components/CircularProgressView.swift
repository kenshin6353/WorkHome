//
//  CircularProgressView.swift
//  WORKOUT
//
//  Created for WorkHome App
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double // 0.0 to 1.0
    let lineWidth: CGFloat
    let gradientColors: [Color]
    
    init(progress: Double, lineWidth: CGFloat = 8, gradientColors: [Color] = [Color.gradientStart, Color.gradientEnd]) {
        self.progress = min(max(progress, 0), 1)
        self.lineWidth = lineWidth
        self.gradientColors = gradientColors
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: gradientColors),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
        }
    }
}

// MARK: - Step Counter Ring
struct StepCounterRing: View {
    let steps: Int
    let goal: Int
    
    var progress: Double {
        min(Double(steps) / Double(goal), 1.0)
    }
    
    var percentage: Int {
        Int(progress * 100)
    }
    
    var body: some View {
        ZStack {
            CircularProgressView(progress: progress)
            
            VStack(spacing: 2) {
                Image(systemName: "figure.walk")
                    .font(.title2)
                    .foregroundColor(.gradientStart)
                Text("\(percentage)%")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Calorie Ring
struct CalorieRing: View {
    let consumed: Int
    let goal: Int
    
    var progress: Double {
        min(Double(consumed) / Double(goal), 1.0)
    }
    
    var body: some View {
        ZStack {
            CircularProgressView(progress: progress, lineWidth: 10)
            
            VStack(spacing: 2) {
                Text("\(consumed)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text("eaten")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Timer Ring
struct TimerRing: View {
    let timeRemaining: Int
    let totalTime: Int
    
    var progress: Double {
        1.0 - (Double(timeRemaining) / Double(totalTime))
    }
    
    var body: some View {
        ZStack {
            // Background
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 8)
            
            // Progress
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient.primaryGradient,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.5), value: progress)
            
            // Timer display
            VStack(spacing: 4) {
                Text("\(timeRemaining)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("seconds")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        StepCounterRing(steps: 6542, goal: 10000)
            .frame(width: 100, height: 100)
        
        CalorieRing(consumed: 1200, goal: 2500)
            .frame(width: 120, height: 120)
    }
    .padding()
}
