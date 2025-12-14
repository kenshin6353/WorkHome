# WorkHome - iOS Fitness App

A comprehensive home workout and nutrition tracking iOS app built with SwiftUI and SwiftData.

## 📱 Features

### Authentication
- **Login Screen** - Email/password authentication with gradient background
- **Register Screen** - User registration with fitness goal selection (Lose Weight, Build Muscle, Stay Fit)

### Main App (5 Tab Navigation)

#### 🏠 Home
- Personalized greeting based on time of day
- Today's workout card with quick start
- **Real-time step counter** with HealthKit integration
- Calories burned and distance walked
- Quick stats (total calories burned, workouts this week)
- Current streak tracker with best streak display
- Recent achievement card

#### 💪 Workouts
- 6 workout categories:
  - Upper Body (Chest, Arms, Shoulders)
  - Lower Body (Legs, Glutes, Calves)
  - Core (Abs, Obliques, Back)
  - Full Body (Complete workout)
  - Cardio HIIT (High intensity intervals)
  - Stretching (Flexibility & Recovery)
- Workout detail modal with exercise list
- **Interactive workout session** with:
  - Circular timer with progress ring
  - Play/pause controls
  - Previous/next exercise navigation
  - Rest timer between exercises
  - Workout completion modal with stats

#### 🍎 Nutrition
- Daily calorie summary with circular progress ring
- Meal tracking (Breakfast, Lunch, Dinner, Snacks)
- Food logging with calorie counts
- **USDA Food Database integration** (real API)
- Dietary recommendations
- Daily nutrition tips

#### 👥 Trainers
- Featured trainer card
- Trainer list with ratings and reviews
- Trainer profile with certifications
- **Direct contact via WhatsApp and Telegram**
- Search functionality

#### 📊 Progress
- Stats overview (workouts, calories, time)
- **Weight progress chart** with Swift Charts
- Period selection (Week, Month, 3 Months)
- Recent achievements display
- Body measurements (Weight, Height, BMI)
- Update measurements modal

### 🏆 Achievements (Gamification)
- Points and XP system
- Level progression
- Achievement categories:
  - Streak achievements (3-day, 7-day, 30-day)
  - Workout achievements (1, 10, 50, 100, 500 workouts)
  - Weight goals (1kg, 3kg, 5kg lost)
  - Step achievements (10K, 15K, 20K steps)
- Progress tracking for locked achievements

### 👤 Profile
- User profile with avatar (initials)
- Personal information display/edit
- Notification settings toggles
- App settings
- Logout functionality

## 🛠 Technical Stack

- **UI Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **Health Data**: HealthKit
- **Charts**: Swift Charts
- **API Integration**: USDA FoodData Central API
- **Minimum iOS**: iOS 17.0+

## 📁 Project Structure

```
WORKOUT/
├── App/
│   └── WORKOUTApp.swift
├── Models/
│   ├── User.swift
│   ├── WorkoutRecord.swift
│   ├── Meal.swift
│   ├── FoodItem.swift
│   ├── WeightRecord.swift
│   ├── UserAchievement.swift
│   └── Trainer.swift
├── Views/
│   ├── Auth/
│   │   ├── LoginView.swift
│   │   └── RegisterView.swift
│   ├── Main/
│   │   └── MainTabView.swift
│   ├── Home/
│   │   └── HomeView.swift
│   ├── Workout/
│   │   ├── WorkoutListView.swift
│   │   └── WorkoutSessionView.swift
│   ├── Nutrition/
│   │   ├── NutritionView.swift
│   │   └── FoodSearchView.swift
│   ├── Progress/
│   │   ├── ProgressView.swift
│   │   └── AchievementsView.swift
│   ├── Profile/
│   │   └── ProfileView.swift
│   └── Trainers/
│       ├── TrainersListView.swift
│       └── TrainerProfileView.swift
├── Components/
│   ├── CircularProgressView.swift
│   ├── GradientButton.swift
│   └── CardViews.swift
├── Services/
│   ├── HealthKitManager.swift
│   ├── USDAFoodService.swift
│   └── AuthManager.swift
└── Utilities/
    ├── Colors.swift
    └── Constants.swift
```

## 🔑 API Keys

The app uses the USDA FoodData Central API for food search functionality.
- API Key is configured in `Constants.swift`
- Get your own key at: https://fdc.nal.usda.gov/api-key-signup.html

## 📋 Requirements

### Xcode Configuration

1. **HealthKit Capability**
   - Add HealthKit capability in Signing & Capabilities
   - Enable "Health Records" if needed

2. **Info.plist**
   - `NSHealthShareUsageDescription` - For reading health data
   - `NSHealthUpdateUsageDescription` - For writing health data

## 🚀 Getting Started

1. Open `WORKOUT.xcodeproj` in Xcode
2. Select your development team in Signing & Capabilities
3. Add HealthKit capability
4. Build and run on simulator or device

## 🎨 Design

The app follows Apple's Human Interface Guidelines with:
- Modern gradient styling (Purple #667eea → #764ba2)
- Card-based UI with subtle shadows
- Circular progress indicators
- Smooth animations and transitions
- Tab-based navigation

## 📱 Screenshots

The prototype HTML files in the `/New` folder show the design reference for each screen.

## 👨‍💻 Author

Created for WorkHome iOS App Project

## 📄 License

This project is for educational purposes.
