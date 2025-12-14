//
//  Colors.swift
//  WORKOUT
//
//  Created for WorkHome App
//

import SwiftUI

extension Color {
    // Primary Gradient Colors
    static let gradientStart = Color(hex: "667eea")
    static let gradientEnd = Color(hex: "764ba2")
    
    // Background Colors
    static let backgroundGray = Color(hex: "F9FAFB")
    
    // Card Shadow Color
    static let cardShadow = Color.black.opacity(0.08)
    
    // Streak Gradient
    static let streakStart = Color(hex: "FBBF24")
    static let streakEnd = Color(hex: "F97316")
    
    // Success Green
    static let successGreen = Color(hex: "22C55E")
    
    // Custom Workout Colors
    static let workoutBlue = Color(hex: "3B82F6")
    static let workoutGreen = Color(hex: "22C55E")
    static let workoutOrange = Color(hex: "F97316")
    static let workoutPurple = Color(hex: "A855F7")
    static let workoutRed = Color(hex: "EF4444")
    static let workoutTeal = Color(hex: "14B8A6")
    
    // Initialize from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Gradient Definitions
extension LinearGradient {
    static let primaryGradient = LinearGradient(
        colors: [Color.gradientStart, Color.gradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let streakGradient = LinearGradient(
        colors: [Color.streakStart, Color.streakEnd],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let successGradient = LinearGradient(
        colors: [Color(hex: "22C55E"), Color(hex: "10B981")],
        startPoint: .leading,
        endPoint: .trailing
    )
}
