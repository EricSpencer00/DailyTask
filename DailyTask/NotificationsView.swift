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
                Section(header: Text(task.name)) {
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
                if let notificationTime = tasks[index].notificationTime {
                    NotificationManager.shared.scheduleNotification(for: tasks[index])
                }
            }
        }
        TaskStorage.shared.saveTasks(tasks)
    }

    private func handleNotificationEnabledChange(for task: Task, isEnabled: Bool) {
        if isEnabled {
            if let notificationTime = task.notificationTime {
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
        Task(name: "Task 1", urgency: .high, notificationTime: Date(), notificationEnabled: true),
        Task(name: "Task 2", urgency: .medium, notificationEnabled: false),
        Task(name: "Task 3", urgency: .low, notificationTime: Date().addingTimeInterval(3600), notificationEnabled: true)
    ]
    
    static var previews: some View {
        NavigationView {
            NotificationView(tasks: $tasks)
        }
    }
}
