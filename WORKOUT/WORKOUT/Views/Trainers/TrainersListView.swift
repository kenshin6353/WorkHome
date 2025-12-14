//
//  TrainersListView.swift
//  WORKOUT
//
//  Created for WorkHome App
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct TrainersListView: View {
    @State private var searchText: String = ""
    @State private var selectedTrainer: Trainer?
    @State private var showTrainerProfile: Bool = false
    
    var filteredTrainers: [Trainer] {
        if searchText.isEmpty {
            return Trainer.sampleTrainers
        }
        return Trainer.sampleTrainers.filter {
            $0.name.lowercased().contains(searchText.lowercased()) ||
            $0.specialty.lowercased().contains(searchText.lowercased())
        }
    }
    
    var featuredTrainer: Trainer? {
        Trainer.sampleTrainers.first { $0.isFeatured }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search trainers...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.08), radius: 10)
                    .padding(.horizontal)
                    
                    // Featured Trainer
                    if let featured = featuredTrainer, searchText.isEmpty {
                        FeaturedTrainerCard(trainer: featured) {
                            selectedTrainer = featured
                            showTrainerProfile = true
                        }
                        .padding(.horizontal)
                    }
                    
                    // All Trainers
                    VStack(alignment: .leading, spacing: 16) {
                        Text("All Trainers")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ForEach(filteredTrainers.filter { !$0.isFeatured || !searchText.isEmpty }) { trainer in
                            TrainerCard(trainer: trainer) {
                                selectedTrainer = trainer
                                showTrainerProfile = true
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.top)
            }
            .background(Color.backgroundGray)
            .navigationTitle("Trainers")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 36, height: 36)
                            Image(systemName: "line.3.horizontal.decrease")
                                .foregroundColor(.gray)
                        }
                    }
                }
                #endif
            }
            .navigationDestination(isPresented: $showTrainerProfile) {
                if let trainer = selectedTrainer {
                    TrainerProfileView(trainer: trainer)
                }
            }
        }
    }
}

// MARK: - Featured Trainer Card
struct FeaturedTrainerCard: View {
    let trainer: Trainer
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Avatar
                AsyncImage(url: URL(string: trainer.imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 64, height: 64)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Featured")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                    
                    Text(trainer.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(trainer.specialty)
                        .font(.subheadline)
                        .opacity(0.9)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text("\(String(format: "%.1f", trainer.rating)) (\(trainer.reviewCount) reviews)")
                            .font(.caption)
                    }
                }
                
                Spacer()
            }
            .foregroundColor(.white)
            .padding()
            .background(LinearGradient.primaryGradient)
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Trainer Card
struct TrainerCard: View {
    let trainer: Trainer
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Content
            Button(action: action) {
                HStack(alignment: .top, spacing: 16) {
                    // Avatar
                    AsyncImage(url: URL(string: trainer.imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 64, height: 64)
                    .cornerRadius(16)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(trainer.name)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", trainer.rating))
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.orange)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.yellow.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        Text(trainer.specialty)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 8) {
                            Text("Certified")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                            
                            Text("\(trainer.yearsExperience) years exp.")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text("•")
                                .foregroundColor(.gray)
                            
                            Text("\(trainer.reviewCount) reviews")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding()
            
            Divider()
                .padding(.horizontal)
            
            // Footer with contact buttons
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.caption)
                    Text("\(trainer.clientCount) clients")
                        .font(.caption)
                }
                .foregroundColor(.gray)
                
                Spacer()
                
                HStack(spacing: 12) {
                    // WhatsApp
                    Button(action: {
                        openWhatsApp(number: trainer.whatsappNumber)
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 40, height: 40)
                            Image(systemName: "message.fill")
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Telegram
                    Button(action: {
                        openTelegram(username: trainer.telegramUsername)
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 40, height: 40)
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.08), radius: 15)
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

#Preview {
    TrainersListView()
}
