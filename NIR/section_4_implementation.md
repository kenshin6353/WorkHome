# 4. Реализация

Реализация данного приложения была проведена с учетом описанной выше архитектуры. При добавлении новой функциональности необходимо определить, к какому слою относятся эти новые классы на основе конкретного правила архитектуры приложения.

## 4.1. Используемые технологии

Для разработки данного приложения используется новый фреймворк SwiftUI. SwiftUI – фреймворк представленный компанией Apple в 2019 году, он построен на декларативном синтаксисе, разработчики могут описывать желаемый пользовательский интерфейс и его поведение с помощью ряда структурированных операторов, а не императивно определять каждый отдельный элемент пользовательского интерфейса. Компания Apple активно развивает этот фреймворк, добавляя новые функциональности каждый год, чтобы этот фреймворк стал заменой ранее использовавшемуся фреймворка UIKit.

В качестве среды разработки использовалась IDE Xcode 15, которая доступна на компьютерах с операционной системой macOS версии 14 или новее. Xcode 15 – бесплатная среда разработки, созданная компанией Apple для разработки приложений для платформ экосистемы Apple [32]. Кроме Xcode, существует среда разработки AppCode [33] от компании JetBrains, однако, есть несколько недостатков, таких как: требуются подписки, еще требует приложение Xcode для работы, и с 14 декабря 2022 года среда разработки AppCode больше не будет получать обновления, поэтому эта среда разработки не будет поддерживать какие-либо будущие дополнительные функции от Apple. Следовательно, данную среду разработки было решено не использовать.

На таблице 4.1 приведен список библиотек, использующихся в данном проекте.

**Таблица 4.1 – Список используемых библиотек**

| № | Название библиотеки | Описание |
|---|---------------------|----------|
| 1 | SwiftData [34] | Фреймворк для локального хранения данных с использованием декларативного синтаксиса |
| 2 | SwiftUI [25] | Декларативный фреймворк для построения пользовательского интерфейса |
| 3 | HealthKit [10] | Центральный репозиторий данных о здоровье и фитнесе на iPhone и Apple Watch |
| 4 | Combine [35] | Фреймворк для реактивного программирования и обработки асинхронных событий |
| 5 | Foundation [36] | Базовые типы данных, коллекции и утилиты операционной системы |

Для хранения кодовой базы использовалась система контроля версий Git вместе с облачной системой управления репозиторий GitHub [37].

## 4.2. Фреймворк SwiftData

Для сохранения каких-то данных от пользователя приложение требует базы данных. В настоящее время существует несколько вариантов баз данных, которые делятся на две категории: реляционная база данных или широко известная как база данных SQL [38] и база данных NoSQL [39] или нереляционная база данных. Основное различие между базой данных SQL и базой данных NoSQL заключается в том, как они структурируют свои данные. Базы данных SQL основаны на таблицах, а базы данных NoSQL основаны на документах, ключах и значениях, графах или хранилищах с широкими столбцами. Хотя использование баз данных SQL дает множество преимуществ, в этом проекте была выбрана база данных с локальным хранением, потому что не требуется синхронизация данных в облаке для нескольких устройств. Кроме того, в этом проекте у нас нет сложных отношений между сущностями, и нам нужно быстрое развитие, которое обеспечивает локальная база данных.

SwiftData – это новый фреймворк от Apple, представленный на WWDC 2023, который предоставляет декларативный подход к определению моделей данных и управлению персистентностью [34]. SwiftData является современной заменой фреймворка Core Data, который использовался в iOS разработке более 15 лет. SwiftData использует локальное хранилище SQLite на устройстве пользователя. Это решение было выбрано по нескольким причинам: во-первых, локальное хранение обеспечивает мгновенный доступ к данным без сетевых задержек; во-вторых, приложение может полноценно работать без подключения к интернету; в-третьих, не требуется настройка серверной инфраструктуры.

SwiftData хранит данные в локальном контейнере на устройстве пользователя. Каждое разрабатываемое приложение имеет свой собственный контейнер по умолчанию, который управляет своим собственным хранилищем данных. Контейнер автоматически создается при первом запуске приложения и сохраняется между сессиями. Сначала нужно чтобы познакомиться с терминами, которые используются в SwiftData. ModelContainer [40] – контейнер, который управляет схемой и конфигурацией хранения данных. ModelContext [41] – контекст, через который выполняются все операции с данными (создание, чтение, обновление, удаление). @Model [42] – макрос, который превращает обычный Swift класс в персистентную сущность базы данных. FetchDescriptor [43] – описание запроса для получения данных с возможностью фильтрации и сортировки. #Predicate [44] – типобезопасный предикат для фильтрации данных.

### Определение моделей данных

SwiftData использует макрос @Model для определения сущностей базы данных. Этот макрос автоматически генерирует весь необходимый код для персистентности, включая методы сериализации и десериализации, отслеживание изменений и интеграцию с SwiftUI. В отличие от Core Data, где требовалось создавать отдельные файлы .xcdatamodeld и вручную генерировать NSManagedObject подклассы, SwiftData позволяет определять модели непосредственно в коде Swift, что значительно упрощает процесс разработки и поддержки кода (рисунок 4.1).

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

**Рисунок 4.1 – Листинг программы модели User с использованием макроса @Model**

В данном листинге программы показана модель User, которая представляет пользователя приложения. Декоратор @Attribute(.unique) указывает, что поле id должно быть уникальным в базе данных, что предотвращает создание дублирующихся записей. Модель содержит персональные данные пользователя (имя, email, возраст, рост, вес), а также статистику фитнеса (количество тренировок, текущая серия, очки, уровень). Инициализатор устанавливает значения по умолчанию для статистических полей, что гарантирует корректное начальное состояние для новых пользователей.

### Связи между сущностями

SwiftData поддерживает определение связей между сущностями с помощью декоратора @Relationship. Это позволяет создавать сложные структуры данных с отношениями один-к-одному, один-ко-многим и многие-ко-многим. В данном приложении используются связи один-ко-многим, где один пользователь может иметь множество записей о приемах пищи, тренировках, измерениях веса и достижениях. Параметр deleteRule определяет поведение при удалении родительской записи (рисунок 4.2).

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

**Рисунок 4.2 – Листинг программы связей между сущностями с каскадным удалением**

Параметр deleteRule: .cascade указывает, что при удалении родительской записи (User) все связанные дочерние записи (Meals, WorkoutRecords, WeightRecords, UserAchievements) также будут автоматически удалены из базы данных. Это важно для поддержания целостности данных и предотвращения появления "осиротевших" записей, которые ссылаются на несуществующего пользователя. Альтернативные правила удаления включают .nullify (установка ссылки в null), .deny (запрет удаления при наличии связанных записей) и .noAction (игнорирование связей).

## 4.3. Фреймворк SwiftData и SwiftDataManager

Для доступа к базе данных приложения было принято решение создать к ней единую точку доступа. В данном приложении для работы с локальной базой данных используется фреймворк SwiftData, который предоставляет декларативный и типобезопасный способ работы с персистентными данными. Аналогично тому, как в приложениях с CloudKit создается класс CloudKitManager для абстрагирования операций с облачной базой данных, в данном приложении создан класс SwiftDataManager (в коде называется AuthManager), который инкапсулирует все операции с локальной базой данных SwiftData.

Этот класс SwiftDataManager состоит из нескольких методов для работы с базой данных, таких как выборка (fetch), удаление (delete), обновление (update) и сохранение (save) данных в базе данных. В реализации этого класса используется паттерн Singleton [52] (Одиночка), поскольку этот паттерн гарантирует, что в приложении существует только один экземпляр этого объекта. Таким образом, необходимость повторной инициализации объекта SwiftDataManager всякий раз, когда модель представления запрашивает запрос к SwiftDataManager, или необходимость передачи экземпляра SwiftDataManager нескольким моделям представления не требуется.

Также в этом классе данные пользователя будут сохраняться при каждом запуске приложения, где при каждом запуске значение данных этого пользователя может изменяться, поскольку пользователь меняет свою учетную запись на своем устройстве или выходит из своей учетной записи на своем устройстве. Следовательно, для отслеживания этих изменений и уведомления пользователя с помощью предупреждения необходимо использовать одноэлементный класс. Еще одна причина, по которой паттерн одиночка использовался для реализации класса SwiftDataManager, заключается в том, что Apple iOS SDK широко использует паттерн «Одиночка» [53], например: URLSession.shared [54] — объект, который координирует группу связанных задач передачи данных по сети, этот объект обычно используется для выполнения сетевых вызовов внешнего API; UserDefaults.standard [55] — объект пользовательской базы данных по умолчанию, где пользователь может постоянно хранить пары ключ-значение при запуске приложения.

На рисунке 4.3 приведена диаграмма классов от этого класса SwiftDataManager, следует отметить, что этот класс имеет зависимости с ModelContext для выполнения операций с базой данных SwiftData.

```
┌─────────────────────────────────────────────────────────────┐
│                    SwiftDataManager                          │
├─────────────────────────────────────────────────────────────┤
│ + shared: SwiftDataManager                                   │
│ + currentUser: User?                                         │
│ + isLoggedIn: Bool                                          │
├─────────────────────────────────────────────────────────────┤
│ + fetch<T>(descriptor:) throws -> [T]                        │
│ + insert(_:)                                                 │
│ + delete(_:)                                                 │
│ + save() throws                                              │
│ + login(email:password:modelContext:) -> Bool                │
│ + register(firstName:lastName:email:...:modelContext:) -> Bool│
│ + logout()                                                   │
│ + loadCurrentUser(modelContext:)                             │
│ + recordWorkoutCompletion(workoutType:duration:...:modelContext:) │
│ - checkAchievements(for:modelContext:)                       │
│ - updateStreak(for:)                                         │
└─────────────────────────────────────────────────────────────┘
```

**Рисунок 4.3 – Диаграмма классов класса SwiftDataManager**

Основное отличие SwiftDataManager от CloudKitManager заключается в том, что SwiftData работает с локальным хранилищем на устройстве, в то время как CloudKit работает с облачным хранилищем iCloud. Это означает, что все операции в SwiftDataManager выполняются синхронно и мгновенно, без необходимости обработки сетевых задержек или ошибок подключения. Для выполнения операций с базой данных SwiftDataManager использует ModelContext, который предоставляется через механизм @Environment в SwiftUI.

### Метод login() – Чтение данных (READ)

Метод login() был создан для получения записи текущего пользователя (рисунок 4.4). Во-первых, чтобы получить запись пользователя, необходимо создать FetchDescriptor с предикатом, который фильтрует пользователей по email и password. FetchDescriptor является типобезопасным способом описания запроса к базе данных, а макрос #Predicate позволяет создавать условия фильтрации с проверкой типов на этапе компиляции. Этот completionHandler завершения возвращает как массив найденных пользователей, так и ошибку, затем необходимо проверить, произошла ли ошибка в процессе выборки или нет, используя метод guard let [57]. Следует отметить, что результат запроса является массивом пользователей, но поскольку email является уникальным полем, массив будет содержать максимум один элемент. Если пользователь найден, его данные сохраняются в свойство currentUser, а флаг isLoggedIn устанавливается в true. Хорошей практикой является сохранение идентификатора пользователя в UserDefaults для восстановления сессии при следующем запуске приложения.

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

Методы save() и insert() используются для записи и создания данных в базу данных SwiftData (рисунок 4.5). Основное отличие между ними состоит в том, что insert() добавляет новый объект в контекст, а save() фиксирует все изменения в постоянное хранилище. При создании новой записи сначала необходимо проверить, не существует ли уже пользователь с таким email, поскольку это поле должно быть уникальным для каждого пользователя. Чтобы создать одну или несколько записей, сначала необходимо создать объект модели с помощью инициализатора, заполнив все необходимые поля. Затем объект добавляется в контекст с помощью метода insert(), и изменения сохраняются с помощью метода save(). В SwiftData, в отличие от Core Data, не требуется явно вызывать save() после каждой операции – контекст автоматически сохраняет изменения в определенные моменты. Однако для гарантии сохранения критически важных данных рекомендуется вызывать save() явно.

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

В SwiftData для обновления записи используется простой подход: достаточно изменить свойства объекта, и изменения будут автоматически отслежены контекстом. Затем метод save() используется для сохранения всех изменений в базу данных (рисунок 4.6). Метод recordWorkoutCompletion() вызывается после завершения пользователем тренировки. Он выполняет несколько операций: обновляет статистику пользователя (общее количество тренировок, сожженные калории, очки), проверяет и обновляет серию тренировок (streak), создает новую запись в истории тренировок и проверяет, разблокировал ли пользователь новые достижения. Все эти операции выполняются в рамках одной транзакции для обеспечения целостности данных.

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

Чтобы удалить запись из базы данных, используется метод delete() контекста модели (рисунок 4.7), который принимает объект для удаления в качестве параметра. Поскольку пользователь может редактировать/удалять только записи о своих тренировках и приемах пищи, необходимо только удалить данные из локальной базы данных. При удалении родительской записи важно учитывать связанные дочерние записи. Благодаря настройке deleteRule: .cascade в декораторе @Relationship, все связанные записи удаляются автоматически. Например, при удалении объекта Meal все связанные объекты FoodItem также будут удалены из базы данных.

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

### Метод fetchWorkoutHistory() – Получение истории тренировок

В этом классе SwiftDataManager существуют несколько методов для получения определенных данных для этого приложения. Один из методов используется для получения истории тренировок пользователя — fetchWorkoutHistory() (рисунок 4.9). Этот метод возвращает массив записей тренировок, отсортированных по дате в порядке убывания, чтобы самые последние тренировки отображались первыми. Для сортировки данных используется параметр sortBy в FetchDescriptor, который принимает массив SortDescriptor с указанием ключа сортировки и порядка (ascending: false для убывания).

```swift
func fetchWorkoutHistory(for user: User, modelContext: ModelContext) -> [WorkoutRecord] {
    // Создание дескриптора запроса с сортировкой по дате
    let descriptor = FetchDescriptor<WorkoutRecord>(
        predicate: #Predicate { record in
            record.user?.id == user.id
        },
        sortBy: [SortDescriptor(\.date, order: .reverse)]
    )
    
    do {
        // Выполнение запроса к базе данных SwiftData
        let records = try modelContext.fetch(descriptor)
        return records
    } catch {
        print("Error fetching workout history: \(error)")
        return []
    }
}
```

**Рисунок 4.9 – Листинг программы метода получения истории тренировок пользователя**

### Метод fetchMealsByDate() – Получение приемов пищи за день

Еще один метод для выборки данных — fetchMealsByDate() (рисунок 4.10). Этот метод принимает один параметр типа Date и возвращает массив приемов пищи за указанный день. Во-первых, необходимо создать правильный временной интервал от начала дня до конца этого дня. Swift предоставляет 2 объекта для работы с датой: Calendar и Date. После создания 2 временных ограничений следующим шагом будет создание NSPredicate с логикой: mealDate >= startOfDay && mealDate < endOfDay. Запрошенные данные затем сортируются по времени приема пищи в порядке возрастания.

```swift
func fetchMealsByDate(_ date: Date, for user: User, modelContext: ModelContext) -> [Meal] {
    // Вычисление начала и конца дня
    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: date)
    let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
    
    // Создание дескриптора с предикатом для фильтрации по дате
    let descriptor = FetchDescriptor<Meal>(
        predicate: #Predicate { meal in
            meal.user?.id == user.id &&
            meal.date >= startOfDay &&
            meal.date < endOfDay
        },
        sortBy: [SortDescriptor(\.date, order: .forward)]
    )
    
    do {
        let meals = try modelContext.fetch(descriptor)
        return meals
    } catch {
        print("Error fetching meals: \(error)")
        return []
    }
}
```

**Рисунок 4.10 – Листинг программы метода получения приемов пищи за определенный день**

### Метод fetchWeightProgress() – Получение истории измерений веса

Последний метод чтения для этого класса — fetchWeightProgress() (рисунок 4.11), который используется для получения всего журнала измерений веса пользователя. Этот метод возвращает массив записей WeightRecord, отсортированных по дате в порядке возрастания для построения графика прогресса. Данные используются в разделе Progress для визуализации изменения веса пользователя с течением времени.

```swift
func fetchWeightProgress(for user: User, modelContext: ModelContext) -> [WeightRecord] {
    // Создание дескриптора с сортировкой по дате (от старых к новым)
    let descriptor = FetchDescriptor<WeightRecord>(
        predicate: #Predicate { record in
            record.user?.id == user.id
        },
        sortBy: [SortDescriptor(\.date, order: .forward)]
    )
    
    do {
        let records = try modelContext.fetch(descriptor)
        return records
    } catch {
        print("Error fetching weight progress: \(error)")
        return []
    }
}
```

**Рисунок 4.11 – Листинг программы метода получения истории измерений веса**

## 4.4. Обёртки свойств @StateObject, @ObservedObject и @Environment

В SwiftUI существует несколько обёрток свойств (property wrappers) для управления состоянием и передачи данных между представлениями. В данном приложении используются три основные обёртки: @StateObject, @ObservedObject и @Environment. Каждая из них имеет своё назначение и область применения.

### @StateObject – Создание и владение объектом

Обёртка @StateObject [64] используется для создания экземпляра класса, реализующего протокол ObservableObject, и гарантирует, что объект создается только один раз за время жизни представления. В данном приложении @StateObject используется в точке входа приложения (WORKOUTApp) для создания экземпляра SwiftDataManager (рисунок 4.12). Это важно, потому что @StateObject гарантирует, что объект не будет пересоздаваться при перерисовке представления, что могло бы привести к потере данных.

```swift
@main
struct WORKOUTApp: App {
    // @StateObject создает и владеет объектом SwiftDataManager
    // Объект создается один раз при запуске приложения
    @StateObject private var authManager = AuthManager.shared
    
    // Создание контейнера SwiftData для моделей данных
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            WorkoutRecord.self,
            Meal.self,
            FoodItem.self,
            WeightRecord.self,
            UserAchievement.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            // Передача authManager как параметра в ContentView
            ContentView(authManager: authManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
```

**Рисунок 4.12 – Листинг программы точки входа приложения с использованием @StateObject**

### @ObservedObject – Наблюдение за объектом

Обёртка @ObservedObject [65] используется для наблюдения за объектом, который был создан и передан из другого представления. В отличие от @StateObject, @ObservedObject не владеет объектом, а только наблюдает за его изменениями. Когда свойство с декоратором @Published изменяется, все представления, использующие @ObservedObject, автоматически обновляются (рисунок 4.13).

```swift
struct HomeView: View {
    // @ObservedObject наблюдает за изменениями в authManager
    // authManager был создан в WORKOUTApp и передан через параметры
    @ObservedObject var authManager: AuthManager
    
    // @ObservedObject для наблюдения за данными HealthKit
    @ObservedObject var healthKitManager = HealthKitManager.shared
    
    // @Environment для доступа к контексту SwiftData
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack {
            // UI автоматически обновляется при изменении currentUser
            if let user = authManager.currentUser {
                Text("Welcome, \(user.firstName)!")
                Text("Total workouts: \(user.totalWorkouts)")
                Text("Current streak: \(user.currentStreak) days")
            }
            
            // UI автоматически обновляется при изменении stepCount
            Text("\(healthKitManager.stepCount) steps today")
        }
    }
}
```

**Рисунок 4.13 – Листинг программы использования @ObservedObject в представлении**

### @Environment – Доступ к системным значениям

Обёртка @Environment [66] используется для доступа к значениям, предоставляемым системой SwiftUI или контейнером данных. В данном приложении @Environment используется для получения ModelContext из SwiftData, который необходим для выполнения операций с базой данных (рисунок 4.14). ModelContext автоматически предоставляется модификатором .modelContainer() в точке входа приложения.

```swift
struct ProfileView: View {
    @ObservedObject var authManager: AuthManager
    
    // @Environment получает ModelContext из окружения SwiftUI
    // ModelContext был предоставлен модификатором .modelContainer()
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack {
            if let user = authManager.currentUser {
                // Отображение данных пользователя
                Text("\(user.firstName) \(user.lastName)")
                
                Button("Save Changes") {
                    // Использование modelContext для сохранения изменений
                    do {
                        try modelContext.save()
                    } catch {
                        print("Error saving: \(error)")
                    }
                }
            }
        }
    }
}
```

**Рисунок 4.14 – Листинг программы использования @Environment для доступа к ModelContext**

### Сравнение обёрток свойств

| Обёртка | Назначение | Использование в приложении |
|---------|------------|---------------------------|
| **@StateObject** | Создание и владение объектом | WORKOUTApp создает AuthManager |
| **@ObservedObject** | Наблюдение за переданным объектом | HomeView, ProfileView наблюдают за AuthManager |
| **@Environment** | Доступ к системным значениям | Получение ModelContext для SwiftData |

## Сводная таблица CRUD операций в SwiftData

| Операция | Метод SwiftData | Описание | Пример в приложении |
|----------|-----------------|----------|---------------------|
| **CREATE** | `modelContext.insert()` | Добавление нового объекта в контекст | Регистрация пользователя, добавление тренировки |
| **READ** | `modelContext.fetch()` | Получение объектов по критериям | Вход в систему, загрузка истории тренировок |
| **UPDATE** | Изменение свойств объекта | Автоматическое отслеживание изменений | Обновление статистики, изменение измерений веса |
| **DELETE** | `modelContext.delete()` | Удаление объекта из контекста | Удаление записи тренировки или приема пищи |
