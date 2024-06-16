import Foundation

class AchievementManager {
    static let shared = AchievementManager()
    private var achievements: Set<Achievement> = []
    private var streaks: [Int] = []

    private init() {}

    func checkAchievements(for taskId: UUID) {
        let streakCount = StreakManager.shared.getStreak(for: taskId)
        switch streakCount {
        case 3:
            achievements.insert(.streak3Days)
        case 7:
            achievements.insert(.streak7Days)
        case 30:
            achievements.insert(.streak30Days)
        case 365:
            achievements.insert(.streak365Days)
        default:
            break
        }
    }

    func checkAllTasksCompleted(for tasks: [Task]) {
        let allCompleted = tasks.allSatisfy { $0.isCompleted }
        if allCompleted {
            // Logic for checking the number of consecutive days all tasks were completed
        }
    }

    func getAchievements() -> [Achievement] {
        return Array(achievements)
    }
    
    func getStreaks() -> [Int] {
        let uniqueStreaks = Set(streaks)
        return Array(uniqueStreaks)
    }
}
