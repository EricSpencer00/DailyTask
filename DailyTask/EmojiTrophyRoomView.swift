import SwiftUI

struct EmojiTrophyRoomView: View {
    var tasks: [Task]
    var emoji: String

    var body: some View {
        List {
            ForEach(filteredTasks(), id: \.id) { task in
                VStack(alignment: .leading) {
                    Text(task.name)
                        .font(.headline)
                    Text("Completion\(task.completions == 1 ? "" : "s"): \(task.completions)")
                    Text("Streak: \(StreakManager.shared.getStreak(for: task.id)) day\(StreakManager.shared.getStreak(for: task.id) == 1 ? "" : "s")")
                }
            }
        }
        .navigationTitle("\(emoji) Trophy Room")
    }

    private func filteredTasks() -> [Task] {
        tasks.filter { $0.emoji == emoji }
    }
}

struct EmojiTrophyRoomView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiTrophyRoomView(
            tasks: [
                Task(name: "Task 1", urgency: .high, emoji: "🔥", notificationTime: Date(), notificationEnabled: true, completions: 1),
                Task(name: "Task 2", urgency: .medium, emoji: "🔥", notificationEnabled: false, completions: 3),
                Task(name: "Task 3", urgency: .low, emoji: "⚡️", notificationTime: Date().addingTimeInterval(3600), notificationEnabled: true, completions: 7)
            ],
            emoji: "🔥"
        )
    }
}
