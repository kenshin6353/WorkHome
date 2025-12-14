//
//  CardViews.swift
//  WORKOUT
//
//  Created for WorkHome App
//

import SwiftUI

// MARK: - Card Modifier
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 4)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let value: String
    let label: String
    let iconName: String
    let iconColor: Color
    let iconBgColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(iconBgColor)
                    .frame(width: 40, height: 40)
                Image(systemName: iconName)
                    .foregroundColor(iconColor)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .cardStyle()
    }
}

// MARK: - Streak Card
struct StreakCard: View {
    let currentStreak: Int
    let bestStreak: Int
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 56, height: 56)
                Image(systemName: "flame.fill")
                    .font(.title)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Current Streak")
                    .font(.caption)
                    .opacity(0.9)
                Text("\(currentStreak) Days")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("Best")
                    .font(.caption)
                    .opacity(0.9)
                Text("\(bestStreak) Days")
                    .fontWeight(.bold)
            }
        }
        .foregroundColor(.white)
        .padding()
        .background(LinearGradient.streakGradient)
        .cornerRadius(20)
    }
}

// MARK: - Today's Workout Card
struct TodayWorkoutCard: View {
    let workoutName: String
    let duration: Int
    let exerciseCount: Int
    let level: String
    let onStart: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Workout")
                    .font(.subheadline)
                    .opacity(0.9)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                    Text("\(duration) min")
                        .font(.caption)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.2))
                .cornerRadius(20)
            }
            
            Text(workoutName)
                .font(.title)
                .fontWeight(.bold)
            
            Text("\(exerciseCount) exercises • \(level)")
                .font(.subheadline)
                .opacity(0.9)
            
            Button(action: onStart) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start Workout")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.white)
                .foregroundColor(.gradientEnd)
                .cornerRadius(12)
            }
        }
        .foregroundColor(.white)
        .padding(20)
        .background(LinearGradient.primaryGradient)
        .cornerRadius(20)
    }
}

// MARK: - Achievement Card
struct AchievementCard: View {
    let title: String
    let description: String
    let iconName: String
    let isNew: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.yellow.opacity(0.2))
                    .frame(width: 48, height: 48)
                Image(systemName: iconName)
                    .font(.title3)
                    .foregroundColor(.yellow)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if isNew {
                Text("New!")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.yellow.opacity(0.2))
                    .foregroundColor(.orange)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            TodayWorkoutCard(
                workoutName: "Full Body Burn",
                duration: 30,
                exerciseCount: 8,
                level: "Intermediate",
                onStart: {}
            )
            
            HStack(spacing: 16) {
                StatCard(
                    value: "1,240",
                    label: "Calories burned",
                    iconName: "flame.fill",
                    iconColor: .orange,
                    iconBgColor: .orange.opacity(0.1)
                )
                StatCard(
                    value: "12",
                    label: "Workouts this week",
                    iconName: "dumbbell.fill",
                    iconColor: .blue,
                    iconBgColor: .blue.opacity(0.1)
                )
            }
            
            StreakCard(currentStreak: 7, bestStreak: 14)
            
            AchievementCard(
                title: "Week Warrior",
                description: "7 workouts in a week",
                iconName: "trophy.fill",
                isNew: true
            )
        }
        .padding()
    }
    .background(Color.backgroundGray)
}
