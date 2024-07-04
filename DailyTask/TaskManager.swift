import Foundation
import UserNotifications

class TaskManager {
    static let shared = TaskManager()
    
    private init() {}
    
    func checkAndResetTasks() {
        let today = getCurrentDateString()
        let lastResetDate = UserDefaults.standard.string(forKey: "lastResetDate") ?? ""
        
        if today != lastResetDate {
            var tasks = TaskStorage.shared.loadTasks()
            tasks.indices.forEach { tasks[$0].isCompleted = false }
            TaskStorage.shared.saveTasks(tasks)
            UserDefaults.standard.set(today, forKey: "lastResetDate")
            print("Tasks have been reset for the new day.")
        }
    }
    
    private func getCurrentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    func scheduleNotification(for task: Task) {
        guard let notificationTime = task.notificationTime else { return }

        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = "Time to \(task.name) \(task.emoji)!"
        content.sound = .default

        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
        dateComponents.second = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }

    func updateNotification(for task: Task) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
        scheduleNotification(for: task)
    }

    func removeNotification(for task: Task) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
    }
    
    func scheduleDailyReminder() {
        // Schedule daily reminders for all tasks with notification times
        let tasks = loadTasks() // Assuming loadTasks() fetches the tasks from storage
        for task in tasks {
            if task.notificationTime != nil {
                scheduleNotification(for: task)
            }
        }
    }

    private func loadTasks() -> [Task] {
        return []
    }
}
