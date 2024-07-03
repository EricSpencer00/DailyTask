import SwiftUI

struct MainTrophyRoomView: View {
    var tasks: [Task]
    var emojiBank: EmojiBank

    var body: some View {
        NavigationView {
            List {
                ForEach(emojiBank.emojis, id: \.self) { emoji in
                    NavigationLink(destination: EmojiTrophyRoomView(tasks: tasks, emoji: emoji)) {
                        HStack {
                            Text(emoji)
                                .font(.largeTitle)
                            Spacer()
                            Text("\(tasksCount(for: emoji)) task\(tasksCount(for: emoji) == 1 ? "" : "s"), \(totalCompletions(for: emoji)) completion\(totalCompletions(for: emoji) == 1 ? "" : "s")")
                        }
                    }
                }
            }
            .navigationTitle("Trophy Room")
        }
    }
    
    private func totalCompletions(for emoji: String) -> Int {
        tasks.filter { $0.emoji == emoji }.reduce(0) { $0 + $1.completions }
    }
    
    private func tasksCount(for emoji: String) -> Int {
        tasks.filter { $0.emoji == emoji }.count
    }
    
    private func filteredEmojis() -> [String] {
        emojiBank.emojis.filter { emoji in
            tasks.contains { $0.emoji == emoji }
        }
    }
}

struct MainTrophyRoomView_Previews: PreviewProvider {
    static var previews: some View {
        MainTrophyRoomView(
            tasks: [
                Task(name: "Task 1", urgency: .high, emoji: "🔥", notificationTime: Date(), notificationEnabled: true),
                Task(name: "Task 2", urgency: .medium, emoji: "⚡️", notificationEnabled: false),
                Task(name: "Task 3", urgency: .low, emoji: "💧", notificationTime: Date().addingTimeInterval(3600), notificationEnabled: true)
            ],
            emojiBank: EmojiBank(emojis: ["🔥", "⚡️", "💧"])
        )
    }
}
