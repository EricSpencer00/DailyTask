import SwiftUI
import WidgetKit
import ConfettiSwiftUI

struct TaskRowView: View {
    var task: Task
    @Binding var tasks: [Task]
    @Binding var taskToComplete: Task?
    @Binding var showCompletionConfirmation: Bool
    @Binding var taskToEdit: Task?
    @Binding var isEditing: Bool

    var body: some View {
        Group {
            if isEditing {
                HStack {
                    Button(action: {
                        deleteTask(task: task)
                    }) {
                        Image(systemName: "x.circle.fill")
                            .foregroundColor(.red)
                            .padding(.trailing, 8)
                    }
                    .transition(.scale)
                    Text(task.emoji)
                        .font(.system(size: 20))
                    Text(task.name)
                        .foregroundColor(.black)
                        .padding()
                        .cornerRadius(10)
                    Spacer()
                    if let notificationTime = task.notificationTime {
                        Text(clockEmoji(for: notificationTime))
                            .padding(.trailing, 4)
                    }
                }
                .padding(8)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
            } else {
                Button(action: {
                    if task.isCompleted {
                        // Directly toggle the task completion without confirmation
                        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                            toggleTaskCompletion(for: index)
                        }
                    } else {
                        // Show confirmation for completing the task
                        taskToComplete = task
                        showCompletionConfirmation = true
                    }
                }) {
                    HStack {
                        Text(task.emoji)
                            .font(.system(size: 20))
                        Text(task.name)
                            .foregroundColor(.black)
                            .padding()
                            .cornerRadius(10)
                        Spacer()
                        if let notificationTime = task.notificationTime {
                            Text(clockEmoji(for: notificationTime))
                                .padding(.trailing, 4)
                        }
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(task.isCompleted ? .green : .red)
                    }
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                }
                .buttonStyle(PlainButtonStyle()) // Ensures button looks like a row
            }
        }
    }

    private func saveTasks() {
        TaskStorage.shared.saveTasks(tasks)
    }

    private func deleteTask(task: Task) {
        NotificationManager.shared.unscheduleNotification(for: task)
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks.remove(at: index)
            saveTasks()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    private func toggleTaskCompletion(for index: Int) {
        tasks[index].isCompleted.toggle()
        if tasks[index].isCompleted {
            StreakManager.shared.incrementCompletion(for: &tasks[index])
        } else {
            StreakManager.shared.resetStreak(for: tasks[index].id)
        }
        saveTasks()
        WidgetCenter.shared.reloadAllTimelines()
        AchievementManager.shared.checkAchievements(for: tasks[index].id)
        AchievementManager.shared.checkAllTasksCompleted(for: tasks)
    }

    private func color(for urgency: Urgency) -> Color {
        switch urgency {
        case .low:
            return .green
        case .medium:
            return .yellow
        case .high:
            return .red
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }
    
    func clockEmoji(for date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        guard let hour = components.hour, let minute = components.minute else { return "🕒" }

        // Define time ranges for different parts of the day
        switch (hour, minute) {
        case (6..<9, _):
            return "☀️⬆️" // Sunrise
        case (9..<12, _):
            return "☀️" // Morning sun
        case (12..<15, _):
            return "🌤" // Afternoon sun
        case (15..<18, _):
            return "☀️⬇️" // Sunset
        case (18..<21, _):
            return "💤" // Dusk
        case (21..<24, _), (0..<6, _):
            return "🌙" // Night moon
        default:
            return ""
        }
    }
}

struct TaskRowView_Previews: PreviewProvider {
    @State static var tasks = [
        Task(name: "Task 1", urgency: .high, notificationTime: Date(), notificationEnabled: true),
        Task(name: "Task 2", urgency: .medium, notificationEnabled: false),
        Task(name: "Task 3", urgency: .low, notificationTime: Date().addingTimeInterval(3600), notificationEnabled: true)
    ]
    @State static var taskToComplete: Task? = nil
    @State static var showCompletionConfirmation = false
    @State static var taskToEdit: Task? = nil
    @State static var isEditing = false

    static var previews: some View {
        TaskRowView(
            task: tasks[0],
            tasks: $tasks,
            taskToComplete: $taskToComplete,
            showCompletionConfirmation: $showCompletionConfirmation,
            taskToEdit: $taskToEdit,
            isEditing: $isEditing
        )
    }
}
