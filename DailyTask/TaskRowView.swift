import SwiftUI
import WidgetKit

struct TaskRowView: View {
    var task: Task
    @Binding var tasks: [Task]
    @Binding var taskToComplete: Task?
    @Binding var showCompletionConfirmation: Bool
    @Binding var taskToEdit: Task?
    @Binding var isEditing: Bool

    var body: some View {
        HStack {
            if isEditing {
                Button(action: {
                    deleteTask(task: task)
                }) {
                    Image(systemName: "x.circle.fill")
                        .foregroundColor(.red)
                        .padding(.trailing, 8)
                }
                .transition(.scale)
            }
            Text(task.emoji)
                .font(.system(size: 20))
            Text(task.name)
                .foregroundColor(.black)
                .padding()
                .cornerRadius(10)
            if let notificationTime = task.notificationTime {
                Text(dateFormatter.string(from: notificationTime))
                    .foregroundColor(.black)
                    .padding()
                    .cornerRadius(10)
                Text("HI")
            }
            Spacer()
            if !isEditing {
                Button(action: {
                    if task.isCompleted {
                        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                            tasks[index].isCompleted.toggle()
                            saveTasks()
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                    } else {
                        taskToComplete = task
                        showCompletionConfirmation = true
                        saveTasks()
                    }
                }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(task.isCompleted ? .green : .red)
                }
            }
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        
    }

    private func saveTasks() {
        if let data = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(data, forKey: "tasks")
        }
    }

    private func deleteTask(task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks.remove(at: index)
            saveTasks()
            WidgetCenter.shared.reloadAllTimelines()
        }
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
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}
