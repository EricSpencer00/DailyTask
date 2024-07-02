import Foundation
import UserNotifications

struct Task: Identifiable, Codable {
    var id: UUID
    var name: String
    var isCompleted: Bool
    var emoji: String
    var urgency: Urgency
    var notificationTime: Date?
    var notificationEnabled: Bool
    var completions: Int
    var lastCompletionDate: Date?

    init(id: UUID = UUID(), 
         name: String,
         urgency: Urgency = .low,
         isCompleted: Bool = false,
         emoji: String = "✅",
         notificationTime: Date? = nil,
         notificationEnabled: Bool = false,
         completions: Int = 0,
         lastCompletionDate: Date? = nil
         )
    {
        self.id = id
        self.name = name
        self.urgency = urgency
        self.isCompleted = isCompleted
        self.emoji = emoji
        self.notificationTime = notificationTime
        self.notificationEnabled = notificationEnabled
        self.completions = completions
        self.lastCompletionDate = lastCompletionDate
    }
}

class TaskStorage {
    static let shared = TaskStorage()
    
    private let taskKey = "tasks"
    private let emojiBankKey = "emojiBank"
    private let suiteName = "group.com.yourcompany.DailyTaskChecker"
    
    private var userDefaults: UserDefaults {
        return UserDefaults(suiteName: suiteName)!
    }
    
    func saveTasks(_ tasks: [Task]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(tasks)
            UserDefaults.standard.set(data, forKey: "tasks")
        } catch {
            print("Failed to encode tasks: \(error.localizedDescription)")
        }
    }
    
    func loadTasks() -> [Task] {
        guard let data = UserDefaults.standard.data(forKey: "tasks") else { return [] }
        
        do {
            let decoder = JSONDecoder()
            let tasks = try decoder.decode([Task].self, from: data)
            return tasks
        } catch {
            print("Failed to decode tasks: \(error.localizedDescription)")
            return []
        }
    }
    
    func loadTasksAsync(completion: @escaping ([Task]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let tasks = self.loadTasks()
            DispatchQueue.main.async {
                completion(tasks)
            }
        }
    }

    func saveEmojiBank(_ emojiBank: EmojiBank) {
        do {
            let data = try JSONEncoder().encode(emojiBank)
            userDefaults.set(data, forKey: emojiBankKey)
        } catch {
            print("Failed to save emoji bank: \(error.localizedDescription)")
        }
    }
    
    func loadEmojiBank() -> EmojiBank {
        guard let data = userDefaults.data(forKey: emojiBankKey),
              let emojiBank = try? JSONDecoder().decode(EmojiBank.self, from: data) else {
            return EmojiBank(emojis: ["✅", "💊", "💉", "🩸", "🚴‍♂️", "🏃‍♂️", "🧘‍♂️", "⭐️"])
        }
        return emojiBank
    }
}

struct TaskDate {
    var id: UUID
    var taskId: UUID
    var date: Date
}

struct EmojiBank: Codable {
    var emojis: [String]
}

enum Urgency: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var displayName: String {
        switch self {
        case .low:
            return "Low Priority"
        case .medium:
            return "Urgent"
        case .high:
            return "Red Hot"
        }
    }
    
    var priority: Int {
        switch self {
        case .high:
            return 3
        case .medium:
            return 2
        case .low:
            return 1
        }
    }
}

extension Array where Element == Task {
    func getHighestPriorityTask() -> Task? {
        return self.sorted(by: { $0.urgency.priority > $1.urgency.priority }).first
    }
}

enum Achievement: String, Codable, CaseIterable, Hashable {
    case streak3Days = "3 Day Streak"
    case streak7Days = "7 Day Streak"
    case streak30Days = "30 Day Streak"
    case streak365Days = "365 Day Streak"
    
    var description: String {
        return self.rawValue
    }
}

struct UserAchievement: Identifiable, Codable, Hashable {
    var id = UUID()
    var type: Achievement
    var dateEarned: Date
}

class StreakManager {
    static let shared = StreakManager()
    private var streaks: [UUID: Int] = [:] // Dictionary to store taskId and its streak count
    private var lastCompletionDates: [UUID: Date] = [:] // Dictionary to store the last completion date for each task

    private init() {}

    func updateStreak(for taskId: UUID) {
        let currentDate = Date()
        if let lastCompletionDate = lastCompletionDates[taskId] {
            if Calendar.current.isDateInYesterday(lastCompletionDate) {
                streaks[taskId, default: 0] += 1
            } else if !Calendar.current.isDateInToday(lastCompletionDate) {
                streaks[taskId] = 1
            }
        } else {
            streaks[taskId] = 1
        }
        lastCompletionDates[taskId] = currentDate
    }

    func getStreak(for taskId: UUID) -> Int {
        return streaks[taskId] ?? 0
    }

    func resetStreak(for taskId: UUID) {
        streaks[taskId] = 0
        lastCompletionDates[taskId] = nil
    }

    func incrementCompletion(for task: inout Task) {
        let currentDate = Date()
        if let lastCompletionDate = task.lastCompletionDate {
            if Calendar.current.isDateInToday(lastCompletionDate) {
                // Already completed today
                return
            }
        }
        task.completions += 1
        task.lastCompletionDate = currentDate
        updateStreak(for: task.id)
    }
}


