//
//  DailyTaskWidget.swift
//  DailyTask
//
//  Created by Eric Spencer on 5/29/24.
//

import Foundation
import WidgetKit
import SwiftUI

struct DailyTaskWidget: TimelineProvider {
    @AppStorage("tasks", store: UserDefaults(suiteName: "group.com.yourcompany.DailyTaskChecker")) private var tasksData: Data = Data()
    @AppStorage("lastResetDate", store: UserDefaults(suiteName: "group.com.yourcompany.DailyTaskChecker")) private var lastResetDate: String = ""

    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry(date: Date(), task: Task(name: "Sample Task", isCompleted: false, emoji: "⏳"))
    }

    func getSnapshot(in context: Context, completion: @escaping (TaskEntry) -> Void) {
        let entry = TaskEntry(date: Date(), task: getTopUncompletedTask())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskEntry>) -> Void) {
        var entries: [TaskEntry] = []
        let currentDate = Date()
        let task = getTopUncompletedTask()

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        for hourOffset in 0 ..< 24 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
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

struct DailyTaskWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Daily Task")
                .font(.headline)
            HStack {
                Text(entry.task.emoji)
                    .font(.largeTitle)
                Text(entry.task.name)
                    .font(.headline)
                Spacer()
                Image(systemName: entry.task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(entry.task.isCompleted ? .green : .red)
            }
        }
        .padding()
        .widgetURL(URL(string: "dailytask://task"))
    }
}

struct DailyTaskWidget: Widget {
    let kind: String = "DailyTaskWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DailyTaskWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Daily Task Checker")
        .description("Check if you have completed your daily tasks.")
    }
}

struct DailyTaskWidget_Previews: PreviewProvider {
    static var previews: some View {
        DailyTaskWidgetEntryView(entry: TaskEntry(date: .now, task: Task(name: "Example Task", isCompleted: false, emoji: "🔲")))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

#Preview(as: .systemSmall) {
    DailyTaskWidget()
} timeline: {
    TaskEntry(date: .now, task: Task(name: "Example Task", isCompleted: false, emoji: "⏳"))
    TaskEntry(date: .now, task: Task(name: "Example Task", isCompleted: true, emoji: "✅"))
}
