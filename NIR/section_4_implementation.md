# 4. Реализация

Реализация данного приложения была проведена с учетом описанной выше архитектуры. При добавлении новой функциональности необходимо определить, к какому слою относятся эти новые классы на основе конкретного правила архитектуры приложения.

## 4.1. Используемые технологии

Для разработки данного приложения используется новый фреймворк SwiftUI. SwiftUI – фреймворк представленный компанией Apple в 2019 году, он построен на декларативном синтаксисе, разработчики могут описывать желаемый пользовательский интерфейс и его поведение с помощью ряда структурированных операторов, а не императивно определять каждый отдельный элемент пользовательского интерфейса. Компания Apple активно развивает этот фреймворк, добавляя новые функциональности каждый год, чтобы этот фреймворк стал заменой ранее использовавшемуся фреймворка UIKit.

В качестве среды разработки использовалась IDE Xcode 15, которая доступна на компьютерах с операционной системой macOS версии 14 или новее. Xcode 15 – бесплатная среда разработки, созданная компанией Apple для разработки приложений для платформ экосистемы Apple [32].

На таблице 4.1 приведен список библиотек, использующихся в данном проекте.

**Таблица 4.1 – Список используемых библиотек**

| № | Название библиотеки | Описание |
|---|---------------------|----------|
| 1 | SwiftData [34] | Фреймворк для локального хранения данных |
| 2 | SwiftUI [25] | Декларативный фреймворк для построения UI |
| 3 | HealthKit [10] | Центральный репозиторий данных о здоровье и фитнесе на iPhone и Apple Watch |
| 4 | Combine [35] | Фреймворк для реактивного программирования |
| 5 | Foundation [36] | Базовые типы данных и утилиты |

Для хранения кодовой базы использовалась система контроля версий Git вместе с облачной системой управления репозиторий GitHub [37].

## 4.2. Фреймворк SwiftData

Для сохранения каких-то данных от пользователя приложение требует базы данных. В настоящее время существует несколько вариантов баз данных, которые делятся на две категории: реляционная база данных или широко известная как база данных SQL [38] и база данных NoSQL [39] или нереляционная база данных.

SwiftData – это новый фреймворк от Apple, представленный на WWDC 2023, который предоставляет декларативный подход к определению моделей данных и управлению персистентностью. В отличие от CloudKit, который хранит данные в облаке iCloud, SwiftData использует локальное хранилище на устройстве пользователя, что обеспечивает:

- **Быстрый доступ к данным** – отсутствие сетевых задержек;
- **Работа офлайн** – приложение работает без подключения к интернету;
- **Простота реализации** – не требуется настройка серверной инфраструктуры;
- **Интеграция с SwiftUI** – нативная поддержка через @Query и @Environment.

### Определение моделей данных

SwiftData использует макрос @Model для определения сущностей базы данных. Каждая модель автоматически получает возможности персистентности без написания дополнительного кода (рисунок 4.1).

```swift
@Model
final class User {
    @Attribute(.unique) var id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var password: String
    var weight: Double
    var height: Double
    var totalWorkouts: Int
    var currentStreak: Int
    
    // Связи с другими сущностями
    @Relationship(deleteRule: .cascade) var meals: [Meal]
    @Relationship(deleteRule: .cascade) var workoutHistory: [WorkoutRecord]
    @Relationship(deleteRule: .cascade) var achievements: [UserAchievement]
    
    init(firstName: String, lastName: String, email: String, ...) {
        self.id = UUID()
        self.firstName = firstName
        // ...
    }
}
```

**Рисунок 4.1 – Листинг программы модели User с использованием @Model**

### Связи между сущностями

SwiftData поддерживает определение связей между сущностями с помощью декоратора @Relationship. В данном приложении используются следующие связи (рисунок 4.2):

```swift
// Связь один-ко-многим: User -> Meals
@Relationship(deleteRule: .cascade) var meals: [Meal]

// Связь один-ко-многим: User -> WorkoutRecords  
@Relationship(deleteRule: .cascade) var workoutHistory: [WorkoutRecord]

// Связь один-ко-многим: User -> WeightRecords
@Relationship(deleteRule: .cascade) var weightRecords: [WeightRecord]

// Связь один-ко-многим: User -> UserAchievements
@Relationship(deleteRule: .cascade) var achievements: [UserAchievement]

// Связь один-ко-многим: Meal -> FoodItems
@Relationship(deleteRule: .cascade) var foods: [FoodItem]
```

**Рисунок 4.2 – Листинг программы связей между сущностями**

Параметр `deleteRule: .cascade` указывает, что при удалении родительской записи (User) все связанные записи (Meals, WorkoutRecords и т.д.) также будут удалены.

## 4.3. AuthManager (Менеджер аутентификации)

Для доступа к базе данных приложения было принято решение создать к ней единую точку доступа. Этот класс AuthManager состоит из нескольких методов для работы с базой данных, таких как выборка, удаление, обновление и сохранение данных в базе данных. В реализации этого класса используется паттерн Singleton [52] (Одиночка), поскольку этот паттерн гарантирует, что в приложении существует только один экземпляр этого объекта.

Таким образом, необходимость повторной инициализации объекта AuthManager всякий раз, когда модель представления запрашивает запрос к AuthManager, или необходимость передачи экземпляра AuthManager нескольким моделям представления не требуется. Также в этом классе данные пользователя будут сохраняться при каждом запуске приложения.

На рисунке 4.3 приведена диаграмма классов класса AuthManager.

```
┌─────────────────────────────────────────────────────────────┐
│                      AuthManager                             │
├─────────────────────────────────────────────────────────────┤
│ + shared: AuthManager                                        │
│ + currentUser: User?                                         │
│ + isLoggedIn: Bool                                          │
├─────────────────────────────────────────────────────────────┤
│ + login(email:password:modelContext:) -> Bool                │
│ + register(firstName:lastName:email:...:modelContext:) -> Bool│
│ + logout()                                                   │
│ + loadCurrentUser(modelContext:)                             │
│ + recordWorkoutCompletion(workoutType:duration:...:modelContext:) │
│ - checkAchievements(for:modelContext:)                       │
│ - updateStreak(for:)                                         │
└─────────────────────────────────────────────────────────────┘
```

**Рисунок 4.3 – Диаграмма классов класса AuthManager**

### Метод login() – Чтение данных (READ)

Метод login() был создан для получения записи пользователя из базы данных (рисунок 4.4). Для получения записи пользователя используется FetchDescriptor с предикатом, который фильтрует пользователей по email и password.

```swift
func login(email: String, password: String, modelContext: ModelContext) -> Bool {
    // Создание дескриптора запроса с предикатом
    let descriptor = FetchDescriptor<User>(
        predicate: #Predicate { user in
            user.email == email && user.password == password
        }
    )
    
    do {
        // Выполнение запроса к базе данных
        let users = try modelContext.fetch(descriptor)
        
        if let user = users.first {
            // Пользователь найден - сохраняем в сессию
            currentUser = user
            isLoggedIn = true
            
            // Сохраняем ID в UserDefaults для восстановления сессии
            UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKeys.isLoggedIn)
            UserDefaults.standard.set(user.id.uuidString, forKey: Constants.UserDefaultsKeys.currentUserID)
            
            return true
        }
    } catch {
        print("Login error: \(error)")
    }
    
    return false
}
```

**Рисунок 4.4 – Листинг программы метода для аутентификации пользователя**

### Метод register() – Создание данных (CREATE)

Метод register() используется для создания новой записи пользователя в базе данных (рисунок 4.5). Сначала проверяется, не существует ли уже пользователь с таким email, затем создается новый объект User и вставляется в контекст.

```swift
func register(
    firstName: String, lastName: String, email: String,
    password: String, age: Int, height: Double,
    weight: Double, fitnessGoal: String,
    modelContext: ModelContext
) -> Bool {
    // Проверка на существование пользователя с таким email
    let descriptor = FetchDescriptor<User>(
        predicate: #Predicate { user in
            user.email == email
        }
    )
    
    do {
        let existingUsers = try modelContext.fetch(descriptor)
        if !existingUsers.isEmpty {
            return false // Email уже существует
        }
        
        // Создание нового пользователя
        let newUser = User(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
            age: age,
            height: height,
            weight: weight,
            fitnessGoal: fitnessGoal
        )
        
        // Создание начальной записи веса
        let initialWeight = WeightRecord(weight: weight)
        newUser.weightRecords.append(initialWeight)
        
        // Вставка в базу данных
        modelContext.insert(newUser)
        try modelContext.save()
        
        return true
    } catch {
        print("Registration error: \(error)")
        return false
    }
}
```

**Рисунок 4.5 – Листинг программы метода для регистрации нового пользователя**

### Метод recordWorkoutCompletion() – Обновление данных (UPDATE)

Метод recordWorkoutCompletion() используется для обновления данных пользователя после завершения тренировки (рисунок 4.6). Этот метод обновляет статистику пользователя и создает новую запись тренировки.

```swift
func recordWorkoutCompletion(
    workoutType: String,
    duration: Int,
    caloriesBurned: Int,
    exercisesCompleted: Int,
    modelContext: ModelContext
) {
    guard let user = currentUser else { return }
    
    // Обновление статистики пользователя (UPDATE)
    user.totalWorkouts += 1
    user.totalCaloriesBurned += caloriesBurned
    user.totalPoints += 50
    
    // Обновление streak
    updateStreak(for: user)
    
    // Создание записи тренировки (CREATE)
    let workoutRecord = WorkoutRecord(
        workoutType: workoutType,
        duration: duration,
        caloriesBurned: caloriesBurned,
        exercisesCompleted: exercisesCompleted
    )
    user.workoutHistory.append(workoutRecord)
    
    // Проверка достижений
    checkAchievements(for: user, modelContext: modelContext)
    
    // Сохранение изменений
    try? modelContext.save()
}
```

**Рисунок 4.6 – Листинг программы метода для записи завершенной тренировки**

### Удаление данных (DELETE)

Для удаления записей из базы данных SwiftData используется метод delete() контекста модели. В данном приложении удаление используется для каскадного удаления связанных записей при выходе пользователя (рисунок 4.7).

```swift
// Пример удаления записи из базы данных
func deleteWorkoutRecord(_ record: WorkoutRecord, modelContext: ModelContext) {
    modelContext.delete(record)
    try? modelContext.save()
}

// Пример удаления приема пищи
func deleteMeal(_ meal: Meal, modelContext: ModelContext) {
    // Каскадное удаление - все связанные FoodItem также удалятся
    modelContext.delete(meal)
    try? modelContext.save()
}
```

**Рисунок 4.7 – Листинг программы методов для удаления записей**

### Проверка достижений – checkAchievements()

Метод checkAchievements() проверяет, разблокировал ли пользователь новые достижения после обновления статистики (рисунок 4.8).

```swift
private func checkAchievements(for user: User, modelContext: ModelContext) {
    // Создание множества уже разблокированных ID для O(1) поиска
    let unlockedIds = Set(user.achievements.map { $0.achievementId })
    
    // Проверка достижений по количеству тренировок
    let workoutAchievements = [
        ("workout_1", 1), ("workout_10", 10), 
        ("workout_50", 50), ("workout_100", 100)
    ]
    
    for (achievementId, requirement) in workoutAchievements {
        if !unlockedIds.contains(achievementId) && 
           user.totalWorkouts >= requirement {
            // Создание нового достижения
            let achievement = UserAchievement(
                achievementId: achievementId, 
                progress: user.totalWorkouts
            )
            user.achievements.append(achievement)
            
            // Начисление очков
            if let achDef = AchievementManager.achievement(for: achievementId) {
                user.totalPoints += achDef.points
            }
        }
    }
    
    // Обновление уровня
    user.level = (user.totalPoints / 1000) + 1
}
```

**Рисунок 4.8 – Листинг программы метода для проверки достижений**

## 4.4. Environment Object и ObservableObject

Для ускорения работы этого приложения необходимо минимизировать количество запросов к базе данных. Поэтому было решено создать класс, который сохраняет все данные, в общем, всякий раз, когда пользователь запускает приложение, приложение загружает все данные, чтобы заполнить списки.

В Swift есть обёртка свойств @EnvironmentObject, которую можно применить к классу, реализующему протокол ObservableObject, который помогает обмениваться данными между представлениями [67]. Эта обёртка свойств может гарантировать, что только те части представлений, которые должны получить доступ к этому классу, предоставляя эти дочерние представления из родительских представлений с модификатором .environmentObject() [68].

В данном приложении используются следующие ObservableObject классы:

### AuthManager

AuthManager отвечает за управление аутентификацией и сессией пользователя (рисунок 4.9).

```swift
@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    
    private init() {
        // Восстановление сессии при запуске
        isLoggedIn = UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.isLoggedIn)
    }
}
```

**Рисунок 4.9 – Листинг программы класса AuthManager**

### HealthKitManager

HealthKitManager отвечает за интеграцию с HealthKit и получение данных о здоровье (рисунок 4.10).

```swift
@MainActor
class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    @Published var stepCount: Int = 0
    @Published var caloriesBurned: Double = 0
    @Published var distanceWalked: Double = 0
    @Published var isAuthorized: Bool = false
    
    private let healthStore = HKHealthStore()
    
    func fetchTodaySteps() async {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now)
        
        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, result, _ in
            guard let sum = result?.sumQuantity() else { return }
            let steps = Int(sum.doubleValue(for: HKUnit.count()))
            
            Task { @MainActor in
                self?.stepCount = steps
            }
        }
        
        healthStore.execute(query)
    }
}
```

**Рисунок 4.10 – Листинг программы класса HealthKitManager**

### USDAFoodService

USDAFoodService отвечает за взаимодействие с внешним API для поиска продуктов питания (рисунок 4.11).

```swift
class USDAFoodService: ObservableObject {
    @Published var searchResults: [USDAFood] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let apiKey = "YOUR_API_KEY"
    private let baseURL = "https://api.nal.usda.gov/fdc/v1"
    
    func searchFoods(_ query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        await MainActor.run { isLoading = true }
        
        // Формирование URL запроса
        let urlString = "\(baseURL)/foods/search?api_key=\(apiKey)&query=\(query)"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(USDASearchResponse.self, from: data)
            
            await MainActor.run {
                self.searchResults = response.foods
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
```

**Рисунок 4.11 – Листинг программы класса USDAFoodService**

### Использование в точке входа приложения

Оба класса AuthManager и HealthKitManager создаются в точке входа приложения и передаются в иерархию представлений с помощью .environmentObject() (рисунок 4.12).

```swift
@main
struct WORKOUTApp: App {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var healthKitManager = HealthKitManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(healthKitManager)
                .modelContainer(for: [
                    User.self,
                    Meal.self,
                    FoodItem.self,
                    WorkoutRecord.self,
                    WeightRecord.self,
                    UserAchievement.self
                ])
        }
    }
}
```

**Рисунок 4.12 – Листинг программы точки входа приложения**

### ModelContext и @Environment

Для работы с SwiftData используется ModelContext, который предоставляется через @Environment. Это позволяет любому представлению получить доступ к контексту базы данных (рисунок 4.13).

```swift
struct SomeView: View {
    // Получение контекста модели из окружения
    @Environment(\.modelContext) private var modelContext
    
    // Получение AuthManager из окружения
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        Button("Save Data") {
            // Использование контекста для сохранения
            try? modelContext.save()
        }
    }
}
```

**Рисунок 4.13 – Листинг программы использования @Environment и @EnvironmentObject**

## Таблица CRUD операций

| Операция | Метод SwiftData | Пример в приложении |
|----------|-----------------|---------------------|
| **CREATE** | `modelContext.insert()` | Регистрация пользователя, добавление тренировки |
| **READ** | `modelContext.fetch()` | Вход в систему, загрузка данных пользователя |
| **UPDATE** | Изменение свойств + `modelContext.save()` | Обновление статистики, измерений веса |
| **DELETE** | `modelContext.delete()` | Удаление записи тренировки или приема пищи |

## Сравнение SwiftData и CloudKit

| Характеристика | SwiftData | CloudKit |
|----------------|-----------|----------|
| **Хранение** | Локальное (на устройстве) | Облачное (iCloud) |
| **Синхронизация** | Не требуется | Между устройствами |
| **Работа офлайн** | Полная | Ограниченная |
| **Сложность** | Низкая | Высокая |
| **Стоимость** | Бесплатно | Бесплатно (с лимитами) |
| **Настройка** | Минимальная | Требуется Apple Developer Account |
