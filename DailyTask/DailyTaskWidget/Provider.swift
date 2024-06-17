import Foundation
import WidgetKit
import SwiftUI

struct DailyTaskWidget: TimelineProvider {
    @AppStorage("tasks", store: UserDefaults(suiteName: "group.com.yourcompany.DailyTaskChecker")) private var tasksData: Data = Data()
    @AppStorage("lastResetDate", store: UserDefaults(suiteName: "group.com.yourcompany.DailyTaskChecker")) private var lastResetDate: String = ""

    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry(date: Date(), task: Task(name: "Sample Task", isCompleted: false, emoji: "🔲"))
    }

    func getSnapshot(in context: Context, completion: @escaping (TaskEntry) -> Void) {
        let entry = TaskEntry(date: Date(), task: getTopUncompletedTask())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskEntry>) -> Void) {
        var entries: [TaskEntry] = []
        let currentDate = Date()

        // Generate a timeline consisting of entries an hour apart, starting from the current date.
        for hourOffset in 0 ..< 24 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let task = getTopUncompletedTask() // Get the top uncompleted task at each hour
            let entry = TaskEntry(date: entryDate, task: task)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    private func getTopUncompletedTask() -> Task {
        let tasks = checkAndResetTasks()
        return tasks.first { !$0.isCompleted } ?? Task(name: "All tasks completed", isCompleted: true, emoji: "✅")
    }

    private func loadTasks() -> [Task] {
        if let loadedTasks = try? JSONDecoder().decode([Task].self, from: tasksData) {
            return loadedTasks
        }
        return []
    }

    private func checkAndResetTasks() -> [Task] {
        let today = getCurrentDateString()
        var tasks = loadTasks()

        if today != lastResetDate {
            for index in tasks.indices {
                tasks[index].isCompleted = false
            }
            lastResetDate = today
            saveTasks(tasks)
        }

        return tasks
    }

    private func getCurrentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private func saveTasks(_ tasks: [Task]) {
        if let data = try? JSONEncoder().encode(tasks) {
            tasksData = data
        }
    }
}

struct TaskEntry: TimelineEntry {
    let date: Date
    let task: Task
}
