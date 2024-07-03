import SwiftUI

struct NotificationView: View {
    @Binding var tasks: [Task]
    @State private var disableAll: Bool = false

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $disableAll) {
                    Text("Disable Notifications")
                }
                .onChange(of: disableAll) { newValue in
                    handleDisableAllChange(newValue)
                }
            }

            ForEach($tasks, id: \.id) { $task in
                Section(header: Text("\(task.name) \(task.emoji)")) {
                    Toggle(isOn: $task.notificationEnabled) {
                        Text("Enable Notifications")
                    }
                    .onChange(of: task.notificationEnabled) { newValue in
                        handleNotificationEnabledChange(for: task, isEnabled: newValue)
                    }

                    if task.notificationEnabled {
                        DatePicker("Notification Time", selection: Binding(
                            get: { task.notificationTime ?? Date() },
                            set: { newValue in
                                task.notificationTime = newValue
                                NotificationManager.shared.scheduleNotification(for: task)
                                TaskStorage.shared.saveTasks(tasks)
                            }
                        ), displayedComponents: .hourAndMinute)
                        .onChange(of: task.notificationTime) { newValue in
                            NotificationManager.shared.scheduleNotification(for: task)
                            TaskStorage.shared.saveTasks(tasks)
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Notification Settings", displayMode: .inline)
    }

    private func handleDisableAllChange(_ newValue: Bool) {
        for index in tasks.indices {
            tasks[index].notificationEnabled = !newValue
            if newValue {
                NotificationManager.shared.unscheduleNotification(for: tasks[index])
            } else {
                if tasks[index].notificationTime != nil {
                    NotificationManager.shared.scheduleNotification(for: tasks[index])
                }
            }
        }
        TaskStorage.shared.saveTasks(tasks)
    }

    private func handleNotificationEnabledChange(for task: Task, isEnabled: Bool) {
        if isEnabled {
            if task.notificationTime != nil {
                NotificationManager.shared.scheduleNotification(for: task)
            } else {
                // Schedule a default notification time if needed
                _ = Date().addingTimeInterval(60 * 60) // 1 hour from now
                NotificationManager.shared.scheduleNotification(for: task)
            }
        } else {
            NotificationManager.shared.unscheduleNotification(for: task)
        }
        TaskStorage.shared.saveTasks(tasks)
    }
}

struct NotificationView_Previews: PreviewProvider {
    @State static var tasks = [
        Task(name: "Task 1", urgency: .high, emoji: "🔥", notificationTime: Date(), notificationEnabled: true),
        Task(name: "Task 2", urgency: .medium, emoji: "⚡️", notificationEnabled: false),
        Task(name: "Task 3", urgency: .low, emoji: "💧", notificationTime: Date().addingTimeInterval(3600), notificationEnabled: true)
    ]

    static var previews: some View {
        NavigationView {
            NotificationView(tasks: $tasks)
        }
    }
}
