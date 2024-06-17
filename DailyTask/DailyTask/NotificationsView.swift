import SwiftUI

struct NotificationView: View {
    @Binding var tasks: [Task]

    var body: some View {
        Form {
            ForEach($tasks) { $task in
                Section(header: Text(task.name)) {
                    Toggle(isOn: $task.notificationEnabled) {
                        Text("Enable Notifications")
                    }
                    
                    if task.notificationEnabled {
                        DatePicker("Notification Time", selection: Binding(
                            get: { task.notificationTime ?? Date() },
                            set: { task.notificationTime = $0 }
                        ), displayedComponents: .hourAndMinute)
                    }
                }
            }
        }
        .navigationBarTitle("Notification Settings", displayMode: .inline)
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
