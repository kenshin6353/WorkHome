//
//  USDAFoodService.swift
//  WORKOUT
//
//  Created for WorkHome App
//

import Foundation
import Combine

// MARK: - USDA API Response Models
struct USDASearchResponse: Codable {
    let foods: [USDAFood]?
    let totalHits: Int?
}

struct USDAFood: Codable, Identifiable {
    let fdcId: Int
    let description: String
    let foodNutrients: [USDANutrient]?
    let brandOwner: String?
    let servingSize: Double?
    let servingSizeUnit: String?
    
    var id: Int { fdcId }
    
    var name: String { description }
    
    var calories: Int {
        let energyNutrient = foodNutrients?.first { $0.nutrientName?.lowercased().contains("energy") == true }
        return Int(energyNutrient?.value ?? 0)
    }
    
    var protein: Double {
        let proteinNutrient = foodNutrients?.first { $0.nutrientName?.lowercased().contains("protein") == true }
        return proteinNutrient?.value ?? 0
    }
    
    var carbs: Double {
        let carbNutrient = foodNutrients?.first { $0.nutrientName?.lowercased().contains("carbohydrate") == true }
        return carbNutrient?.value ?? 0
    }
    
    var fat: Double {
        let fatNutrient = foodNutrients?.first { $0.nutrientName?.lowercased().contains("total lipid") == true || $0.nutrientName?.lowercased() == "fat" }
        return fatNutrient?.value ?? 0
    }
    
    var servingSizeText: String {
        if let size = servingSize, let unit = servingSizeUnit {
            return "\(Int(size))\(unit)"
        }
        return "100g"
    }
}

struct USDANutrient: Codable {
    let nutrientName: String?
    let value: Double?
    let unitName: String?
}

// MARK: - Food Service
class USDAFoodService: ObservableObject {
    static let shared = USDAFoodService()
    
    @Published var searchResults: [USDAFood] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let apiKey = Constants.usdaAPIKey
    private let baseURL = Constants.usdaBaseURL
    
    private init() {}
    
    // MARK: - Search Foods
    func searchFoods(query: String) async {
        guard !query.isEmpty, query.count >= 2 else {
            await MainActor.run {
                self.searchResults = []
            }
            return
        }
        
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        let urlString = "\(baseURL)/foods/search?api_key=\(apiKey)&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)&pageSize=20"
        
        guard let url = URL(string: urlString) else {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Invalid URL"
            }
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Server error"
                }
                return
            }
            
            let decoder = JSONDecoder()
            let searchResponse = try decoder.decode(USDASearchResponse.self, from: data)
            
            await MainActor.run {
                self.searchResults = searchResponse.foods ?? []
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Clear Search
    func clearSearch() {
        searchResults = []
        errorMessage = nil
    }
    
    // MARK: - Popular Foods (Mock Data)
    static let popularFoods: [SimpleFoodItem] = [
        SimpleFoodItem(name: "Apple, raw", calories: 52, serving: "100g", protein: 0.3, carbs: 14, fat: 0.2, iconName: "apple", iconColor: "red"),
        SimpleFoodItem(name: "Chicken Breast, grilled", calories: 165, serving: "100g", protein: 31, carbs: 0, fat: 3.6, iconName: "fork.knife", iconColor: "orange"),
        SimpleFoodItem(name: "Egg, whole, boiled", calories: 155, serving: "100g", protein: 13, carbs: 1.1, fat: 11, iconName: "oval.fill", iconColor: "yellow"),
        SimpleFoodItem(name: "Brown Rice, cooked", calories: 112, serving: "100g", protein: 2.6, carbs: 24, fat: 0.9, iconName: "leaf.fill", iconColor: "amber"),
        SimpleFoodItem(name: "Salmon, Atlantic", calories: 208, serving: "100g", protein: 20, carbs: 0, fat: 13, iconName: "fish.fill", iconColor: "pink"),
        SimpleFoodItem(name: "Broccoli, raw", calories: 34, serving: "100g", protein: 2.8, carbs: 7, fat: 0.4, iconName: "leaf.fill", iconColor: "green"),
        SimpleFoodItem(name: "Banana, raw", calories: 89, serving: "100g", protein: 1.1, carbs: 23, fat: 0.3, iconName: "leaf.fill", iconColor: "yellow"),
        SimpleFoodItem(name: "Milk, whole", calories: 61, serving: "100ml", protein: 3.2, carbs: 4.8, fat: 3.3, iconName: "drop.fill", iconColor: "blue"),
        SimpleFoodItem(name: "Bread, whole wheat", calories: 247, serving: "100g", protein: 13, carbs: 41, fat: 3.4, iconName: "rectangle.fill", iconColor: "amber"),
        SimpleFoodItem(name: "Oatmeal, cooked", calories: 68, serving: "100g", protein: 2.4, carbs: 12, fat: 1.4, iconName: "circle.grid.2x2.fill", iconColor: "orange")
    ]
    
    static let recentFoods: [SimpleFoodItem] = [
        SimpleFoodItem(name: "Chicken Breast", calories: 165, serving: "100g", protein: 31, carbs: 0, fat: 3.6, iconName: "fork.knife", iconColor: "orange"),
        SimpleFoodItem(name: "Brown Rice", calories: 112, serving: "100g", protein: 2.6, carbs: 24, fat: 0.9, iconName: "leaf.fill", iconColor: "amber"),
        SimpleFoodItem(name: "Banana", calories: 89, serving: "1 medium", protein: 1.1, carbs: 23, fat: 0.3, iconName: "leaf.fill", iconColor: "yellow")
    ]
}

// MARK: - Simple Food Item for UI
struct SimpleFoodItem: Identifiable {
    let id = UUID()
    let name: String
    let calories: Int
    let serving: String
    let protein: Double
    let carbs: Double
    let fat: Double
    let iconName: String
    let iconColor: String
}
