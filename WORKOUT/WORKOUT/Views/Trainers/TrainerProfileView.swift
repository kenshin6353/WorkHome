//
//  TrainerProfileView.swift
//  WORKOUT
//
//  Created for WorkHome App
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct TrainerProfileView: View {
    let trainer: Trainer
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 16) {
                    // Avatar
                    AsyncImage(url: URL(string: trainer.imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(color: .black.opacity(0.1), radius: 10)
                    
                    VStack(spacing: 4) {
                        Text(trainer.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(trainer.specialty)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // Rating
                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(trainer.rating) ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                        }
                        Text("(\(trainer.reviewCount) reviews)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    // Stats
                    HStack(spacing: 32) {
                        VStack(spacing: 4) {
                            Text("\(trainer.yearsExperience)")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Years Exp.")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Divider()
                            .frame(height: 40)
                        
                        VStack(spacing: 4) {
                            Text("\(trainer.clientCount)")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Clients")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Divider()
                            .frame(height: 40)
                        
                        VStack(spacing: 4) {
                            Text(String(format: "%.1f", trainer.rating))
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Rating")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.08), radius: 15)
                .padding(.horizontal)
                
                // About
                VStack(alignment: .leading, spacing: 12) {
                    Text("About")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(trainer.bio)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineSpacing(4)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.08), radius: 15)
                .padding(.horizontal)
                
                // Certifications
                VStack(alignment: .leading, spacing: 12) {
                    Text("Certifications")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    VStack(spacing: 12) {
                        CertificationRow(title: "Certified Personal Trainer", issuer: "ACE Fitness")
                        CertificationRow(title: "Nutrition Specialist", issuer: "NASM")
                        CertificationRow(title: "First Aid Certified", issuer: "Red Cross")
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.08), radius: 15)
                .padding(.horizontal)
                
                // Contact Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        openWhatsApp(number: trainer.whatsappNumber)
                    }) {
                        HStack {
                            Image(systemName: "message.fill")
                            Text("Contact via WhatsApp")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    }
                    
                    Button(action: {
                        openTelegram(username: trainer.telegramUsername)
                    }) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                            Text("Contact via Telegram")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
            .padding(.top)
        }
        .background(Color.backgroundGray)
        .navigationTitle("Trainer Profile")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    private func openWhatsApp(number: String) {
        #if os(iOS)
        if let url = URL(string: "https://wa.me/\(number)") {
            UIApplication.shared.open(url)
        }
        #endif
    }
    
    private func openTelegram(username: String) {
        #if os(iOS)
        if let url = URL(string: "https://t.me/\(username)") {
            UIApplication.shared.open(url)
        }
        #endif
    }
}

// MARK: - Certification Row
struct CertificationRow: View {
    let title: String
    let issuer: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(issuer)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        TrainerProfileView(trainer: Trainer.sampleTrainers.first!)
    }
}
