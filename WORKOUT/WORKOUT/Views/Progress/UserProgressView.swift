//
//  UserProgressView.swift
//  WORKOUT
//
//  Created for WorkHome App
//

import SwiftUI
import SwiftData
import Charts
import Combine

struct UserProgressView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedPeriod: String = "month"
    @State private var showUpdateModal: Bool = false
    @State private var newWeight: Double = 72
    @State private var newHeight: Double = 170
    
    // Dynamic weight calculations
    var startingWeight: Double {
        authManager.currentUser?.startingWeight ?? 75
    }
    
    var currentWeight: Double {
        authManager.currentUser?.weight ?? 72
    }
    
    var weightChange: Double {
        currentWeight - startingWeight
    }
    
    var weightChangeText: String {
        let change = weightChange
        if change == 0 {
            return "No change"
        } else if change < 0 {
            return String(format: "%.1f kg", change)
        } else {
            return String(format: "+%.1f kg", change)
        }
    }
    
    var weightChangeColor: Color {
        if weightChange < 0 {
            return .green // Lost weight
        } else if weightChange > 0 {
            return .red // Gained weight
        }
        return .gray
    }
    
    // Dynamic chart data based on current weight
    var weekData: [(String, Double)] {
        let w = currentWeight
        return [
            ("Mon", w + 0.5), ("Tue", w + 0.3), ("Wed", w + 0.4),
            ("Thu", w + 0.2), ("Fri", w + 0.1), ("Sat", w), ("Sun", w)
        ]
    }
    
    var monthData: [(String, Double)] {
        let w = currentWeight
        let s = startingWeight
        let diff = s - w
        return [
            ("Week 1", s), ("Week 2", s - diff * 0.4),
            ("Week 3", s - diff * 0.7), ("Week 4", w)
        ]
    }
    
    var threeMonthData: [(String, Double)] {
        let w = currentWeight
        let s = startingWeight
        let mid = (s + w) / 2
        return [
            ("Month 1", s), ("Month 2", mid), ("Month 3", w)
        ]
    }
    
    var chartData: [(String, Double)] {
        switch selectedPeriod {
        case "week": return weekData
        case "3month": return threeMonthData
        default: return monthData
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Stats Overview
                    HStack(spacing: 12) {
                        MiniStatCard(value: "\(authManager.currentUser?.totalWorkouts ?? 24)", label: "Workouts", color: .blue)
                        MiniStatCard(value: "12.5k", label: "Calories", color: .orange)
                        MiniStatCard(value: "18h", label: "Total Time", color: .green)
                    }
                    .padding(.horizontal)
                    
                    // Weight Progress Chart
                    WeightChartCard(
                        selectedPeriod: $selectedPeriod,
                        chartData: chartData,
                        startWeight: startingWeight,
                        currentWeight: currentWeight,
                        weightChange: weightChange
                    )
                    .padding(.horizontal)
                    
                    // Recent Achievements
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Achievements")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            NavigationLink(destination: AchievementsView(authManager: authManager)) {
                                Text("View All")
                                    .font(.subheadline)
                                    .foregroundColor(.gradientStart)
                            }
                        }
                        
                        ProgressAchievementRow(
                            icon: "flame.fill",
                            iconColor: .yellow,
                            bgColor: .yellow.opacity(0.1),
                            title: "7-Day Streak",
                            description: "Workout 7 days in a row",
                            isNew: true
                        )
                        
                        ProgressAchievementRow(
                            icon: "dumbbell.fill",
                            iconColor: .blue,
                            bgColor: .blue.opacity(0.1),
                            title: "First 10 Workouts",
                            description: "Complete 10 workouts",
                            isCompleted: true
                        )
                        
                        ProgressAchievementRow(
                            icon: "scalemass.fill",
                            iconColor: .green,
                            bgColor: .green.opacity(0.1),
                            title: "First Kg Lost",
                            description: "Lose your first kilogram",
                            isCompleted: true
                        )
                    }
                    .padding()
                    .cardStyle()
                    .padding(.horizontal)
                    
                    // Body Measurements
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Body Measurements")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button("Update") {
                                newWeight = authManager.currentUser?.weight ?? 72
                                newHeight = authManager.currentUser?.height ?? 170
                                showUpdateModal = true
                            }
                            .font(.subheadline)
                            .foregroundColor(.gradientStart)
                        }
                        
                        MeasurementRow(
                            icon: "scalemass.fill",
                            iconColor: .purple,
                            label: "Weight",
                            value: "\(Int(currentWeight)) kg",
                            change: weightChangeText,
                            changeColor: weightChangeColor
                        )
                        
                        MeasurementRow(
                            icon: "ruler.fill",
                            iconColor: .blue,
                            label: "Height",
                            value: "\(Int(authManager.currentUser?.height ?? 170)) cm",
                            change: nil,
                            changeColor: .gray
                        )
                        
                        MeasurementRow(
                            icon: "function",
                            iconColor: .orange,
                            label: "BMI",
                            value: String(format: "%.1f", authManager.currentUser?.bmi ?? 24.9),
                            change: authManager.currentUser?.bmiCategory ?? "Normal",
                            changeColor: .green
                        )
                    }
                    .padding()
                    .cardStyle()
                    .padding(.horizontal)
                    
                    Spacer(minLength: 100)
                }
                .padding(.top)
            }
            .background(Color.backgroundGray)
            .navigationTitle("Progress")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AchievementsView(authManager: authManager)) {
                        ZStack {
                            Circle()
                                .fill(Color.yellow.opacity(0.2))
                                .frame(width: 36, height: 36)
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                }
                #endif
            }
            .sheet(isPresented: $showUpdateModal) {
                UpdateMeasurementsSheet(
                    weight: $newWeight,
                    height: $newHeight,
                    onSave: {
                        // Save to user model
                        if let user = authManager.currentUser {
                            user.weight = newWeight
                            user.height = newHeight
                            try? modelContext.save()
                        }
                        showUpdateModal = false
                    }
                )
                .presentationDetents([.medium])
            }
            .onAppear {
                // Initialize with current user values
                if let user = authManager.currentUser {
                    newWeight = user.weight
                    newHeight = user.height
                }
            }
        }
    }
}

// MARK: - Mini Stat Card
struct MiniStatCard: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .cardStyle()
    }
}

// MARK: - Weight Chart Card
struct WeightChartCard: View {
    @Binding var selectedPeriod: String
    let chartData: [(String, Double)]
    let startWeight: Double
    let currentWeight: Double
    let weightChange: Double // positive = lost weight, negative = gained weight
    
    var changeText: String {
        let change = currentWeight - startWeight
        if change == 0 {
            return "0 kg"
        } else if change < 0 {
            return "\(Int(change)) kg" // Shows as negative (lost weight)
        } else {
            return "+\(Int(change)) kg" // Shows as positive (gained weight)
        }
    }
    
    var changeColor: Color {
        let change = currentWeight - startWeight
        if change < 0 {
            return .green // Lost weight - good
        } else if change > 0 {
            return .red // Gained weight
        }
        return .gray
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Weight Progress")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Picker("Period", selection: $selectedPeriod) {
                    Text("Week").tag("week")
                    Text("Month").tag("month")
                    Text("3 Months").tag("3month")
                }
                .pickerStyle(.menu)
                .tint(.gradientStart)
            }
            
            // Chart
            Chart {
                ForEach(chartData, id: \.0) { item in
                    LineMark(
                        x: .value("Time", item.0),
                        y: .value("Weight", item.1)
                    )
                    .foregroundStyle(Color.gradientStart)
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Time", item.0),
                        y: .value("Weight", item.1)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.gradientStart.opacity(0.3), Color.gradientStart.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                    
                    PointMark(
                        x: .value("Time", item.0),
                        y: .value("Weight", item.1)
                    )
                    .foregroundStyle(Color.gradientStart)
                    .symbolSize(50)
                }
            }
            .chartYScale(domain: (chartData.map { $0.1 }.min() ?? 70) - 2 ... (chartData.map { $0.1 }.max() ?? 80) + 2)
            .chartYAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let weight = value.as(Double.self) {
                            Text("\(Int(weight)) kg")
                                .font(.caption)
                        }
                    }
                }
            }
            .frame(height: 180)
            
            Divider()
            
            // Stats
            HStack {
                VStack(spacing: 2) {
                    Text("Start")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(Int(startWeight)) kg")
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text("Current")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(Int(currentWeight)) kg")
                        .fontWeight(.bold)
                        .foregroundColor(.gradientStart)
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text("Change")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(changeText)
                        .fontWeight(.bold)
                        .foregroundColor(changeColor)
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

// MARK: - Progress Achievement Row
struct ProgressAchievementRow: View {
    let icon: String
    let iconColor: Color
    let bgColor: Color
    let title: String
    let description: String
    var isNew: Bool = false
    var isCompleted: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(bgColor)
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
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
            } else if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(bgColor.opacity(0.5))
        .cornerRadius(12)
    }
}

// MARK: - Measurement Row
struct MeasurementRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String
    let change: String?
    let changeColor: Color
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                }
                
                Text(label)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(value)
                    .fontWeight(.bold)
                if let change = change {
                    Text(change)
                        .font(.caption)
                        .foregroundColor(changeColor)
                }
            }
        }
    }
}

// MARK: - Update Measurements Sheet
struct UpdateMeasurementsSheet: View {
    @Binding var weight: Double
    @Binding var height: Double
    let onSave: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Update Measurements")
                .font(.title3)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Weight (kg)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("Weight", value: $weight, format: .number)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Height (cm)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("Height", value: $height, format: .number)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            }
            
            VStack(spacing: 12) {
                GradientButton("Save Changes") {
                    onSave()
                }
                
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

#Preview {
    UserProgressView(authManager: AuthManager.shared)
}
