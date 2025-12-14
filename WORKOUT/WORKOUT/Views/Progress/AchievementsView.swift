//
//  AchievementsView.swift
//  WORKOUT
//
//  Created for WorkHome App
//

import SwiftUI
import Combine

struct AchievementsView: View {
    @ObservedObject var authManager: AuthManager
    
    var unlockedIds: Set<String> {
        Set(authManager.currentUser?.achievements.map { $0.achievementId } ?? [])
    }
    
    var unlockedCount: Int {
        unlockedIds.count
    }
    
    var totalAchievements: Int {
        AchievementManager.allAchievements.count
    }
    
    var totalPoints: Int {
        authManager.currentUser?.totalPoints ?? 2450
    }
    
    var currentLevel: Int {
        authManager.currentUser?.level ?? 5
    }
    
    var xpProgress: Double {
        Double(totalPoints % 1000) / 1000.0
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Stats Banner
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Points")
                                .font(.subheadline)
                                .opacity(0.9)
                            Text("\(totalPoints)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 64, height: 64)
                            Image(systemName: "trophy.fill")
                                .font(.title)
                        }
                    }
                    
                    VStack(spacing: 4) {
                        HStack {
                            Text("Level \(currentLevel)")
                                .font(.caption)
                            Spacer()
                            Text("\(totalPoints % 1000)/1000 XP to Level \(currentLevel + 1)")
                                .font(.caption)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.3))
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white)
                                    .frame(width: geometry.size.width * xpProgress, height: 8)
                            }
                        }
                        .frame(height: 8)
                    }
                }
                .foregroundColor(.white)
                .padding()
                .background(LinearGradient.streakGradient)
                .cornerRadius(20)
                .padding(.horizontal)
                
                // Streak Achievements
                AchievementSection(
                    title: "Streak Achievements",
                    icon: "flame.fill",
                    iconColor: .orange,
                    achievements: AchievementManager.achievements(for: .streak),
                    unlockedIds: unlockedIds,
                    userProgress: authManager.currentUser?.currentStreak ?? 0
                )
                
                // Workout Achievements
                AchievementSection(
                    title: "Workout Achievements",
                    icon: "dumbbell.fill",
                    iconColor: .blue,
                    achievements: AchievementManager.achievements(for: .workout),
                    unlockedIds: unlockedIds,
                    userProgress: authManager.currentUser?.totalWorkouts ?? 0
                )
                
                // Weight Achievements
                AchievementSection(
                    title: "Weight Goals",
                    icon: "scalemass.fill",
                    iconColor: .green,
                    achievements: AchievementManager.achievements(for: .weight),
                    unlockedIds: unlockedIds,
                    userProgress: 3 // Sample: 3kg lost
                )
                
                // Step Achievements
                AchievementSection(
                    title: "Step Goals",
                    icon: "figure.walk",
                    iconColor: .purple,
                    achievements: AchievementManager.achievements(for: .steps),
                    unlockedIds: unlockedIds,
                    userProgress: 10000 // Sample steps
                )
                
                Spacer(minLength: 40)
            }
            .padding(.top)
        }
        .background(Color.backgroundGray)
        .navigationTitle("Achievements")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text("Achievements")
                        .font(.headline)
                    Text("\(unlockedCount) of \(totalAchievements) unlocked")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

// MARK: - Achievement Section
struct AchievementSection: View {
    let title: String
    let icon: String
    let iconColor: Color
    let achievements: [Achievement]
    let unlockedIds: Set<String>
    let userProgress: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(achievements) { achievement in
                    AchievementBadge(
                        achievement: achievement,
                        isUnlocked: unlockedIds.contains(achievement.id),
                        progress: userProgress
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Achievement Badge
struct AchievementBadge: View {
    let achievement: Achievement
    let isUnlocked: Bool
    let progress: Int
    
    var progressText: String {
        if isUnlocked {
            return "Done"
        } else if progress > 0 {
            return "\(progress)/\(achievement.requirement)"
        } else {
            return "Locked"
        }
    }
    
    var iconColor: Color {
        switch achievement.category {
        case .streak: return .orange
        case .workout: return .blue
        case .weight: return .green
        case .steps: return .purple
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? iconColor.opacity(0.15) : Color.gray.opacity(0.1))
                    .frame(width: 56, height: 56)
                
                Image(systemName: isUnlocked ? achievement.iconName : achievement.iconName)
                    .font(.title2)
                    .foregroundColor(isUnlocked ? iconColor : .gray.opacity(0.5))
                
                // Progress badge
                if !isUnlocked && progress > 0 && progress < achievement.requirement {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(Color.yellow)
                                    .frame(width: 24, height: 24)
                                Text("\(progress)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .offset(x: 4, y: 4)
                        }
                    }
                    .frame(width: 56, height: 56)
                }
            }
            
            Text(achievement.title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(isUnlocked ? .primary : .gray.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            if isUnlocked {
                HStack(spacing: 2) {
                    Image(systemName: "checkmark")
                        .font(.caption2)
                    Text("Done")
                        .font(.caption2)
                }
                .foregroundColor(.green)
            } else if progress > 0 && progress < achievement.requirement {
                Text("\(progress)/\(achievement.requirement)")
                    .font(.caption2)
                    .foregroundColor(.gradientStart)
            } else {
                HStack(spacing: 2) {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                    Text("Locked")
                        .font(.caption2)
                }
                .foregroundColor(.gray.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
        .opacity(isUnlocked ? 1 : 0.7)
    }
}

#Preview {
    NavigationStack {
        AchievementsView(authManager: AuthManager.shared)
    }
}
