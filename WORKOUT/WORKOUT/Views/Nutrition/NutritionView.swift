//
//  NutritionView.swift
//  WORKOUT
//
//  Created for WorkHome App
//

import SwiftUI
import SwiftData
import Combine

struct NutritionView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.modelContext) private var modelContext
    
    @State private var showFoodSearch: Bool = false
    @State private var selectedMealType: Constants.MealType = .breakfast
    
    // Foods stored per meal type (name, serving, calories)
    @State private var breakfastFoods: [(String, String, Int)] = [
        ("Oatmeal with Berries", "1 cup", 280),
        ("Boiled Eggs", "2 eggs", 140)
    ]
    @State private var lunchFoods: [(String, String, Int)] = [
        ("Grilled Chicken Salad", "1 serving", 380),
        ("Brown Rice", "1/2 cup", 200)
    ]
    @State private var dinnerFoods: [(String, String, Int)] = [
        ("Apple", "1 medium", 95)
    ]
    @State private var snackFoods: [(String, String, Int)] = []
    
    var breakfastCalories: Int { breakfastFoods.reduce(0) { $0 + $1.2 } }
    var lunchCalories: Int { lunchFoods.reduce(0) { $0 + $1.2 } }
    var dinnerCalories: Int { dinnerFoods.reduce(0) { $0 + $1.2 } }
    var snackCalories: Int { snackFoods.reduce(0) { $0 + $1.2 } }
    
    var totalConsumed: Int {
        breakfastCalories + lunchCalories + dinnerCalories + snackCalories
    }
    
    var calorieGoal: Int {
        Constants.defaultCalorieGoal
    }
    
    var remaining: Int {
        calorieGoal - totalConsumed + 300 // 300 burned from exercise
    }
    
    func addFood(name: String, calories: Int, protein: Double, carbs: Double, fat: Double, servings: Double) {
        let servingText = servings == 1.0 ? "1 serving" : "\(String(format: "%.1f", servings)) servings"
        let foodTuple = (name, servingText, calories)
        
        switch selectedMealType {
        case .breakfast:
            breakfastFoods.append(foodTuple)
        case .lunch:
            lunchFoods.append(foodTuple)
        case .dinner:
            dinnerFoods.append(foodTuple)
        case .snack:
            snackFoods.append(foodTuple)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Calorie Summary Card
                    CalorieSummaryCard(
                        consumed: totalConsumed,
                        goal: calorieGoal,
                        burned: 300,
                        remaining: remaining
                    )
                    .padding(.horizontal)
                    
                    // Today's Meals
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Today's Meals")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        // Breakfast
                        MealCard(
                            mealType: .breakfast,
                            calories: breakfastCalories,
                            foods: breakfastFoods,
                            onAdd: {
                                selectedMealType = .breakfast
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    showFoodSearch = true
                                }
                            }
                        )
                        
                        // Lunch
                        MealCard(
                            mealType: .lunch,
                            calories: lunchCalories,
                            foods: lunchFoods,
                            onAdd: {
                                selectedMealType = .lunch
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    showFoodSearch = true
                                }
                            }
                        )
                        
                        // Dinner
                        MealCard(
                            mealType: .dinner,
                            calories: dinnerCalories,
                            foods: dinnerFoods,
                            onAdd: {
                                selectedMealType = .dinner
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    showFoodSearch = true
                                }
                            }
                        )
                        
                        // Snacks
                        MealCard(
                            mealType: .snack,
                            calories: snackCalories,
                            foods: snackFoods,
                            onAdd: {
                                selectedMealType = .snack
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    showFoodSearch = true
                                }
                            }
                        )
                    }
                    
                    // Dietary Recommendations
                    DietaryRecommendationsCard()
                        .padding(.horizontal)
                    
                    // Daily Tip
                    DailyTipCard()
                        .padding(.horizontal)
                    
                    Spacer(minLength: 100)
                }
                .padding(.top)
            }
            .background(Color.backgroundGray)
            .navigationTitle("Nutrition")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        selectedMealType = .breakfast
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showFoodSearch = true
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.gradientStart)
                                .frame(width: 36, height: 36)
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                        }
                    }
                }
                #endif
            }
            .sheet(isPresented: $showFoodSearch) {
                FoodSearchView(mealType: selectedMealType, onFoodAdded: addFood)
                    .id(selectedMealType.id)
            }
        }
    }
}

// MARK: - Calorie Summary Card
struct CalorieSummaryCard: View {
    let consumed: Int
    let goal: Int
    let burned: Int
    let remaining: Int
    
    var progress: Double {
        min(Double(consumed) / Double(goal), 1.0)
    }
    
    var body: some View {
        HStack(spacing: 24) {
            // Calorie Ring
            ZStack {
                CircularProgressView(progress: progress, lineWidth: 10)
                    .frame(width: 110, height: 110)
                
                VStack(spacing: 2) {
                    Text("\(consumed)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("eaten")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // Stats
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Goal")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(goal) cal")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(LinearGradient.primaryGradient)
                                .frame(width: geometry.size.width * progress, height: 8)
                        }
                    }
                    .frame(height: 8)
                }
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "fork.knife")
                            .font(.caption)
                        Text("\(consumed) eaten")
                            .font(.caption)
                    }
                    .foregroundColor(.green)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                        Text("\(burned) burned")
                            .font(.caption)
                    }
                    .foregroundColor(.orange)
                }
                
                Text("\(remaining) remaining")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.gradientStart)
            }
        }
        .padding()
        .cardStyle()
    }
}

// MARK: - Meal Card
struct MealCard: View {
    let mealType: Constants.MealType
    let calories: Int
    let foods: [(String, String, Int)]
    let onAdd: () -> Void
    
    var iconColor: Color {
        switch mealType {
        case .breakfast: return .yellow
        case .lunch: return .orange
        case .dinner: return .purple
        case .snack: return .pink
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(iconColor.opacity(0.15))
                            .frame(width: 40, height: 40)
                        Image(systemName: mealType.iconName)
                            .foregroundColor(iconColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(mealType.rawValue)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("\(calories) cal")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Button(action: onAdd) {
                    ZStack {
                        Circle()
                            .fill(Color.gradientStart.opacity(0.1))
                            .frame(width: 32, height: 32)
                        Image(systemName: "plus")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gradientStart)
                    }
                }
            }
            .padding()
            
            if !foods.isEmpty {
                Divider()
                    .padding(.horizontal)
                
                // Foods
                VStack(spacing: 12) {
                    ForEach(foods, id: \.0) { food in
                        HStack {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.orange.opacity(0.1))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "leaf.fill")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(food.0)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text(food.1)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Spacer()
                            
                            Text("\(food.2) cal")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
            } else {
                Text("No foods logged")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom)
            }
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 4)
        .padding(.horizontal)
    }
}

// MARK: - Dietary Recommendations Card
struct DietaryRecommendationsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Dietary Recommendations")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("USDA Data")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(10)
            }
            
            RecommendationRow(
                icon: "fish.fill",
                iconColor: .blue,
                bgColor: .blue.opacity(0.1),
                title: "Add More Protein",
                description: "You're 20g below your daily protein goal. Try salmon, chicken, or eggs."
            )
            
            RecommendationRow(
                icon: "leaf.fill",
                iconColor: .green,
                bgColor: .green.opacity(0.1),
                title: "Eat More Vegetables",
                description: "Add leafy greens like spinach or broccoli for fiber and vitamins."
            )
            
            RecommendationRow(
                icon: "drop.fill",
                iconColor: .orange,
                bgColor: .orange.opacity(0.1),
                title: "Stay Hydrated",
                description: "Drink at least 8 glasses of water daily for optimal metabolism."
            )
        }
        .padding()
        .cardStyle()
    }
}

struct RecommendationRow: View {
    let icon: String
    let iconColor: Color
    let bgColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(bgColor)
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(bgColor.opacity(0.3))
        .cornerRadius(12)
    }
}

// MARK: - Daily Tip Card
struct DailyTipCard: View {
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 40, height: 40)
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Daily Tip")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text("Try to eat more protein-rich foods to support muscle recovery after your workouts.")
                    .font(.caption)
                    .opacity(0.9)
            }
        }
        .foregroundColor(.white)
        .padding()
        .background(LinearGradient.successGradient)
        .cornerRadius(20)
    }
}

#Preview {
    NutritionView(authManager: AuthManager.shared)
}
