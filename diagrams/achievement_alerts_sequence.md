# Sequence Diagram: Achievement Alerts

## Scientific Paper Description

Figure X illustrates the sequence diagram for the Achievement Alerts notification subsystem within the WorkHome fitness application. Unlike time-based notifications such as workout and meal reminders, achievement alerts implement an event-driven notification architecture that triggers immediately upon achievement unlock events. This reactive pattern ensures users receive instant gratification and positive reinforcement when they reach fitness milestones, which is psychologically important for maintaining long-term engagement with the application. The achievement alert system integrates directly with the achievement verification logic in AuthManager, creating a seamless flow from goal completion to celebratory notification.

The achievement alert flow demonstrates the coordination between the data persistence layer and the notification subsystem. When a user completes a workout, the AuthManager's `checkAchievements()` function evaluates whether any new achievements have been unlocked based on updated statistics (total workouts, streak count, etc.). If a new achievement is detected and the user has enabled achievement alerts, the system immediately dispatches a local notification containing the achievement title, description, and point value. This notification is delivered using UNTimeIntervalNotificationTrigger with a minimal delay (1 second), ensuring near-instantaneous delivery while allowing the notification system to properly queue the request. The deep-link payload directs users to the Achievements view where they can review their complete badge collection.

## Flow Description
This diagram shows how Achievement Alerts are triggered when users unlock new achievements and how they are delivered.

## Mermaid Sequence Diagram

```mermaid
sequenceDiagram
    autonumber
    
    participant User
    participant WorkoutSessionView
    participant AuthManager
    participant AchievementManager
    participant NotificationService as Notification Service
    participant UNCenter as UNUserNotificationCenter
    participant iOS as iOS System
    participant AchievementsView
    
    %% Workout Completion Triggers Achievement Check
    rect rgb(240, 248, 255)
        Note over User,AuthManager: Workout Completion
        
        User->>WorkoutSessionView: Complete workout
        WorkoutSessionView->>AuthManager: recordWorkoutCompletion()
        
        AuthManager->>AuthManager: Update user stats
        Note over AuthManager: totalWorkouts += 1<br/>totalCaloriesBurned += X<br/>currentStreak updated
        
        AuthManager->>AuthManager: checkAchievements(user, modelContext)
    end
    
    %% Achievement Verification
    rect rgb(240, 255, 240)
        Note over AuthManager,AchievementManager: Achievement Verification
        
        AuthManager->>AchievementManager: Get all achievement definitions
        AchievementManager-->>AuthManager: Return [Achievement]
        
        AuthManager->>AuthManager: Build Set of unlocked IDs
        
        loop For each achievement category
            AuthManager->>AuthManager: Check if requirements met
            
            alt New Achievement Unlocked
                AuthManager->>AuthManager: Create UserAchievement entity
                AuthManager->>AuthManager: user.achievements.append()
                AuthManager->>AuthManager: user.totalPoints += points
                
                Note over AuthManager: Achievement: "10 Workouts"<br/>Points: +200
                
                AuthManager->>NotificationService: sendAchievementAlert(achievement)
            end
        end
    end
    
    %% Send Achievement Notification
    rect rgb(255, 250, 240)
        Note over NotificationService,iOS: Send Achievement Alert
        
        NotificationService->>NotificationService: Check achievementAlerts enabled
        
        alt Alerts Enabled
            NotificationService->>NotificationService: Create notification content
            Note over NotificationService: title: "🏆 Achievement Unlocked!"<br/>body: "10 Workouts - +200 points"<br/>sound: celebratory
            
            NotificationService->>NotificationService: Create immediate trigger
            Note over NotificationService: UNTimeIntervalNotificationTrigger<br/>timeInterval: 1 second
            
            NotificationService->>UNCenter: add(UNNotificationRequest)
            UNCenter->>iOS: Deliver notification immediately
            iOS->>User: Display achievement banner
            Note over User: 🏆 "Achievement Unlocked!"<br/>"10 Workouts - You earned 200 points!"
            
        else Alerts Disabled
            Note over NotificationService: Skip notification<br/>Achievement still saved
        end
    end
    
    %% User Interaction
    rect rgb(255, 245, 238)
        Note over User,AchievementsView: User Response
        
        alt User taps notification
            User->>iOS: Tap achievement banner
            iOS->>AchievementsView: Navigate to achievements
            AchievementsView->>User: Display all achievements
            Note over AchievementsView: Highlight newly<br/>unlocked badge
        else User dismisses
            User->>iOS: Dismiss notification
            Note over iOS: Achievement still saved
        end
    end
```

## Components Involved

| Component | Type | Responsibility |
|-----------|------|----------------|
| **User** | Actor | Completes workout, receives alert |
| **WorkoutSessionView** | SwiftUI View | Triggers completion flow |
| **AuthManager** | ObservableObject | Records workout, checks achievements |
| **AchievementManager** | Static Registry | Provides achievement definitions |
| **NotificationService** | Service Class | Sends achievement notification |
| **UNUserNotificationCenter** | iOS Framework | Delivers notification |
| **AchievementsView** | SwiftUI View | Deep-link destination |

## Achievement Categories

| Category | Example | Trigger Condition |
|----------|---------|-------------------|
| **Workout Count** | "10 Workouts" | totalWorkouts >= 10 |
| **Streak** | "7-Day Streak" | currentStreak >= 7 |
| **Calories** | "10K Calories" | totalCaloriesBurned >= 10000 |
| **Special** | "Night Owl" | Workout after 9 PM |

## Key Implementation Code

### 1. Toggle State Binding
**File:** `ProfileView.swift`

```swift
@State private var achievementAlerts: Bool = true

NotificationToggleRow(
    icon: "trophy.fill", 
    label: "Achievement Alerts", 
    isOn: $achievementAlerts
)
```

### 2. Check Achievements After Workout
**File:** `AuthManager.swift`

Called after every workout completion:

```swift
func recordWorkoutCompletion(
    workoutType: String,
    duration: Int,
    caloriesBurned: Int,
    exercisesCompleted: Int,
    modelContext: ModelContext
) {
    guard let user = currentUser else { return }
    
    // Update stats
    user.totalWorkouts += 1
    user.totalCaloriesBurned += caloriesBurned
    user.totalPoints += 50
    
    // Check for new achievements
    checkAchievements(for: user, modelContext: modelContext)
    
    try? modelContext.save()
}
```

### 3. Achievement Verification & Alert Trigger
**File:** `AuthManager.swift`

Check and trigger notification for new achievements:

```swift
private func checkAchievements(for user: User, modelContext: ModelContext) {
    let unlockedIds = Set(user.achievements.map { $0.achievementId })
    
    let workoutAchievements = [
        ("workout_1", 1), ("workout_10", 10), 
        ("workout_50", 50), ("workout_100", 100)
    ]
    
    for (achievementId, requirement) in workoutAchievements {
        if !unlockedIds.contains(achievementId) && 
           user.totalWorkouts >= requirement {
            
            // Create achievement record
            let achievement = UserAchievement(
                achievementId: achievementId,
                progress: user.totalWorkouts
            )
            user.achievements.append(achievement)
            
            // Get achievement definition
            if let achDef = AchievementManager.achievement(for: achievementId) {
                user.totalPoints += achDef.points
                
                // Send notification if enabled
                if user.achievementAlerts {
                    NotificationService.shared.sendAchievementAlert(
                        title: achDef.title,
                        points: achDef.points
                    )
                }
            }
        }
    }
}
```

### 4. Send Achievement Notification
**File:** `NotificationService.swift`

Immediate notification delivery:

```swift
func sendAchievementAlert(title: String, points: Int) {
    let center = UNUserNotificationCenter.current()
    
    let content = UNMutableNotificationContent()
    content.title = "🏆 Achievement Unlocked!"
    content.body = "\(title) - You earned \(points) points!"
    content.sound = UNNotificationSound(named: UNNotificationSoundName("celebration.wav"))
    content.userInfo = ["destination": "achievements"]
    
    // Trigger immediately (1 second delay)
    let trigger = UNTimeIntervalNotificationTrigger(
        timeInterval: 1,
        repeats: false
    )
    
    let request = UNNotificationRequest(
        identifier: "achievement_\(UUID().uuidString)",
        content: content,
        trigger: trigger
    )
    
    center.add(request)
}
```

### 5. Handle Achievement Notification Tap
**File:** `AppDelegate.swift`

Navigate to achievements view:

```swift
func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse
) async {
    let userInfo = response.notification.request.content.userInfo
    
    if let destination = userInfo["destination"] as? String,
       destination == "achievements" {
        NotificationCenter.default.post(
            name: .navigateToAchievements,
            object: nil
        )
    }
}
```

## Event-Driven vs Time-Based

```
┌─────────────────────────────────────────────────────────────┐
│           ACHIEVEMENT ALERT ARCHITECTURE                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  TIME-BASED (Workout/Meal Reminders)                        │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐                 │
│  │ Schedule│───▶│ Wait for│───▶│ Deliver │                 │
│  │ at time │    │  time   │    │  alert  │                 │
│  └─────────┘    └─────────┘    └─────────┘                 │
│                                                             │
│  EVENT-DRIVEN (Achievement Alerts)                          │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐                 │
│  │ User    │───▶│ Check   │───▶│ Deliver │                 │
│  │ action  │    │ unlock  │    │  INSTANT│                 │
│  └─────────┘    └─────────┘    └─────────┘                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Code Summary Table

| # | Code Section | File | Purpose |
|---|--------------|------|---------|
| 1 | Achievement toggle | ProfileView.swift | Enable/disable alerts |
| 2 | `recordWorkoutCompletion()` | AuthManager.swift | Trigger achievement check |
| 3 | `checkAchievements()` | AuthManager.swift | Verify & trigger notification |
| 4 | `sendAchievementAlert()` | NotificationService.swift | Immediate notification |
| 5 | `didReceive response` | AppDelegate.swift | Deep link to achievements |
