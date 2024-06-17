import SwiftUI

struct AchievementsBubbleView: View {
    @State private var streaks: [Int] = []
    
    var body: some View {
        VStack {
                    AchievementEmoji(emoji: "🥉", title: "3 Days", isCompleted: streaks.contains(3), info: "Complete all tasks for 3 consecutive days to earn this achievement.")
                    AchievementEmoji(emoji: "🥈", title: "7 Days", isCompleted: streaks.contains(7), info: "Complete all tasks for 7 consecutive days to earn this achievement.")
                    AchievementEmoji(emoji: "🥇", title: "30 Days", isCompleted: streaks.contains(30), info: "Complete all tasks for 30 consecutive days to earn this achievement.")
                    AchievementEmoji(emoji: "🏆", title: "365 Days", isCompleted: streaks.contains(365), info: "Complete all tasks for 365 consecutive days to earn this achievement.")
                }
        .onAppear {
            streaks = AchievementManager.shared.getStreaks()
        }
    }
}

struct AchievementEmoji: View {
    var emoji: String
    var title: String
    var isCompleted: Bool
    var info: String
    @State private var showInfo: Bool = false
    
    var body: some View {
        VStack {
            Text(emoji)
                .font(.system(size: 50))
                .padding()
                .foregroundColor(isCompleted ? .primary : .gray)
            Text(title)
                .font(.headline)
                .padding(.top, 5)
            Button("Tap to view info") {
                showInfo = true
            }
            .padding(.top, 5)
            .sheet(isPresented: $showInfo) {
                VStack {
                    Text(info)
                        .font(.body)
                        .padding()
                    Button("Close") {
                        showInfo = false
                    }
                    .padding()
                }
            }
        }
    }
}

struct AchievementsBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        AchievementsBubbleView()
    }
}
