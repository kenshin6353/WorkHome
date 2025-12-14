//
//  Trainer.swift
//  WORKOUT
//
//  Created for WorkHome App
//

import Foundation

struct Trainer: Identifiable {
    let id: UUID
    let name: String
    let specialty: String
    let rating: Double
    let reviewCount: Int
    let yearsExperience: Int
    let clientCount: Int
    let imageURL: String
    let whatsappNumber: String
    let telegramUsername: String
    let isFeatured: Bool
    let bio: String
    
    static let sampleTrainers: [Trainer] = [
        Trainer(
            id: UUID(),
            name: "Mike Johnson",
            specialty: "Strength & Conditioning",
            rating: 4.9,
            reviewCount: 128,
            yearsExperience: 10,
            clientCount: 350,
            imageURL: "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=100&h=100&fit=crop&crop=face",
            whatsappNumber: "1234567890",
            telegramUsername: "mikejohnson",
            isFeatured: true,
            bio: "Certified strength and conditioning specialist with over 10 years of experience helping clients achieve their fitness goals."
        ),
        Trainer(
            id: UUID(),
            name: "Sarah Williams",
            specialty: "Weight Loss Specialist",
            rating: 4.8,
            reviewCount: 89,
            yearsExperience: 5,
            clientCount: 234,
            imageURL: "https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=100&h=100&fit=crop&crop=face",
            whatsappNumber: "1234567891",
            telegramUsername: "sarahwilliams",
            isFeatured: false,
            bio: "Passionate about helping people transform their bodies and lives through sustainable weight loss strategies."
        ),
        Trainer(
            id: UUID(),
            name: "David Chen",
            specialty: "HIIT & Cardio Expert",
            rating: 4.9,
            reviewCount: 156,
            yearsExperience: 8,
            clientCount: 412,
            imageURL: "https://images.unsplash.com/photo-1567013127542-490d757e51fc?w=100&h=100&fit=crop&crop=face",
            whatsappNumber: "1234567892",
            telegramUsername: "davidchen",
            isFeatured: false,
            bio: "High-intensity training specialist focused on maximizing results in minimum time."
        ),
        Trainer(
            id: UUID(),
            name: "Emma Rodriguez",
            specialty: "Yoga & Flexibility",
            rating: 4.7,
            reviewCount: 98,
            yearsExperience: 6,
            clientCount: 189,
            imageURL: "https://images.unsplash.com/photo-1594381898411-846e7d193883?w=100&h=100&fit=crop&crop=face",
            whatsappNumber: "1234567893",
            telegramUsername: "emmarodriguez",
            isFeatured: false,
            bio: "Yoga instructor and flexibility coach helping clients improve mobility and reduce stress."
        ),
        Trainer(
            id: UUID(),
            name: "James Wilson",
            specialty: "Home Workout Expert",
            rating: 4.6,
            reviewCount: 67,
            yearsExperience: 4,
            clientCount: 145,
            imageURL: "https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=100&h=100&fit=crop&crop=face",
            whatsappNumber: "1234567894",
            telegramUsername: "jameswilson",
            isFeatured: false,
            bio: "Specializing in effective home workouts that require no equipment."
        )
    ]
}
