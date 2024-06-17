import SwiftUI
import UniformTypeIdentifiers

struct TaskBucket: View {
    let urgency: Urgency
    @Binding var tasks: [Task]
    @Binding var taskToComplete: Task?
    @Binding var showCompletionConfirmation: Bool
    @Binding var taskToEdit: Task?
    @Binding var isEditing: Bool

    @State private var isHovered: Bool = false

    var body: some View {
        VStack {
            Text(urgency.displayName)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(color(for: urgency))
                .cornerRadius(10)
            VStack {
                ForEach(tasks.filter { $0.urgency == urgency }) { task in
                    TaskRowView(
                        task: task,
                        tasks: $tasks,
                        taskToComplete: $taskToComplete,
                        showCompletionConfirmation: $showCompletionConfirmation,
                        taskToEdit: $taskToEdit,
                        isEditing: $isEditing
                    )
                    .onDrag {
                        NSItemProvider(object: task.id.uuidString as NSString)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 5)
        }
        .padding()
        .background(isHovered ? color(for: urgency).opacity(0.8) : color(for: urgency))
        .cornerRadius(15)
        .shadow(radius: 5)
        .onDrop(of: [UTType.text], delegate: TaskDropDelegate(task: Task(id: UUID(), name: "", urgency: urgency), tasks: $tasks, currentUrgency: urgency))
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
}
