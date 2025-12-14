//
//  FoodSearchView.swift
//  WORKOUT
//
//  Created for WorkHome App
//

import SwiftUI
import Combine

struct FoodSearchView: View {
    let mealType: Constants.MealType
    var onFoodAdded: ((String, Int, Double, Double, Double, Double) -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var foodService = USDAFoodService.shared
    
    @State private var searchText: String = ""
    @State private var selectedFood: SimpleFoodItem?
    @State private var showAddModal: Bool = false
    @State private var servingCount: Double = 1.0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search for food...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                        .onChange(of: searchText) { _, newValue in
                            Task {
                                await foodService.searchFoods(query: newValue)
                            }
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            foodService.clearSearch()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.08), radius: 10)
                .padding()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Loading State
                        if foodService.isLoading {
                            HStack {
                                Spacer()
                                VStack(spacing: 12) {
                                    SwiftUI.ProgressView()
                                    Text("Searching USDA database...")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 40)
                        }
                        // Search Results
                        else if !foodService.searchResults.isEmpty {
                            Text("\(foodService.searchResults.count) results found")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                            
                            ForEach(foodService.searchResults) { food in
                                FoodResultRow(
                                    name: food.name,
                                    calories: food.calories,
                                    serving: food.servingSizeText
                                ) {
                                    selectedFood = SimpleFoodItem(
                                        name: food.name,
                                        calories: food.calories,
                                        serving: food.servingSizeText,
                                        protein: food.protein,
                                        carbs: food.carbs,
                                        fat: food.fat,
                                        iconName: "leaf.fill",
                                        iconColor: "green"
                                    )
                                    showAddModal = true
                                }
                            }
                        }
                        // Initial State
                        else if searchText.isEmpty {
                            // Recent Foods
                            Text("Recent Foods")
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            ForEach(USDAFoodService.recentFoods) { food in
                                FoodResultRow(
                                    name: food.name,
                                    calories: food.calories,
                                    serving: food.serving
                                ) {
                                    selectedFood = food
                                    showAddModal = true
                                }
                            }
                            
                            // Popular Foods
                            Text("Popular Foods")
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                                .padding(.top)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(USDAFoodService.popularFoods.prefix(6)) { food in
                                    PopularFoodButton(food: food) {
                                        searchText = food.name.components(separatedBy: ",").first ?? food.name
                                        Task {
                                            await foodService.searchFoods(query: searchText)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        // No Results
                        else if !foodService.isLoading {
                            HStack {
                                Spacer()
                                VStack(spacing: 12) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray.opacity(0.5))
                                    Text("No foods found")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                    Text("Try a different search term")
                                        .font(.caption)
                                        .foregroundColor(.gray.opacity(0.7))
                                }
                                Spacer()
                            }
                            .padding(.vertical, 40)
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .background(Color.backgroundGray)
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.gray)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text("Add Food")
                            .font(.headline)
                        Text("Search USDA Food Database")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            .sheet(isPresented: $showAddModal) {
                if let food = selectedFood {
                    AddFoodSheet(
                        food: food,
                        mealType: mealType,
                        servingCount: $servingCount,
                        onAdd: {
                            // Call the callback with food data
                            let totalCalories = Int(Double(food.calories) * servingCount)
                            onFoodAdded?(food.name, totalCalories, food.protein * servingCount, food.carbs * servingCount, food.fat * servingCount, servingCount)
                            dismiss()
                        }
                    )
                    .presentationDetents([.medium])
                }
            }
        }
    }
}

// MARK: - Food Result Row
struct FoodResultRow: View {
    let name: String
    let calories: Int
    let serving: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: "fork.knife")
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Text("\(calories) cal per \(serving)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "plus")
                    .foregroundColor(.gradientStart)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
}

// MARK: - Popular Food Button
struct PopularFoodButton: View {
    let food: SimpleFoodItem
    let action: () -> Void
    
    var iconColor: Color {
        switch food.iconColor {
        case "red": return .red
        case "yellow": return .yellow
        case "blue": return .blue
        case "amber": return .orange
        case "pink": return .pink
        case "green": return .green
        default: return .gray
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: food.iconName)
                        .foregroundColor(iconColor)
                }
                
                Text(food.name.components(separatedBy: ",").first ?? food.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Add Food Sheet
struct AddFoodSheet: View {
    let food: SimpleFoodItem
    let mealType: Constants.MealType
    @Binding var servingCount: Double
    let onAdd: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var totalCalories: Int {
        Int(Double(food.calories) * servingCount)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 4) {
                Text(food.name)
                    .font(.title3)
                    .fontWeight(.bold)
                Text("\(food.calories) cal per \(food.serving)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.top)
            
            // Serving Size
            VStack(spacing: 12) {
                Text("Serving Size")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 16) {
                    Button(action: {
                        if servingCount > 0.5 {
                            servingCount -= 0.5
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 44, height: 44)
                            Image(systemName: "minus")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Text(String(format: "%.1f", servingCount))
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(width: 80)
                    
                    Button(action: {
                        if servingCount < 10 {
                            servingCount += 0.5
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 44, height: 44)
                            Image(systemName: "plus")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Text("servings")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Nutrition Info
            VStack(spacing: 12) {
                NutritionRow(label: "Calories", value: "\(totalCalories)")
                NutritionRow(label: "Protein", value: String(format: "%.1fg", food.protein * servingCount))
                NutritionRow(label: "Carbs", value: String(format: "%.1fg", food.carbs * servingCount))
                NutritionRow(label: "Fat", value: String(format: "%.1fg", food.fat * servingCount))
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            
            // Meal Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Add to Meal")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Image(systemName: mealType.iconName)
                        .foregroundColor(.gradientStart)
                    Text(mealType.rawValue)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
            
            // Buttons
            VStack(spacing: 12) {
                GradientButton("Add Food") {
                    onAdd()
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

struct NutritionRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .fontWeight(label == "Calories" ? .bold : .medium)
        }
    }
}

#Preview {
    FoodSearchView(mealType: .breakfast)
}
