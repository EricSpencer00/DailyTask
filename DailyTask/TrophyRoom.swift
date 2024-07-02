//
//  TrophyRoom.swift
//  DailyTask
//
//  Created by Eric Spencer on 7/2/24.
//

import SwiftUI
import Foundation

struct TrophyRoomView: View {
    var tasks: [Task]

    var body: some View {
        List {
            ForEach(tasks) { task in
                Section(header: Text(task.name)) {
                    Text("Completions: \(task.completions)")
                    Text("Streak: \(StreakManager.shared.getStreak(for: task.id)) days")
                }
            }
        }
        .navigationTitle("Trophy Room")
    }
}

struct TrophyRoomView_Previews: PreviewProvider {
    static var previews: some View {
        TrophyRoomView(tasks: [
            Task(name: "Sample Task 1", urgency: .low),
            Task(name: "Sample Task 2", urgency: .high, notificationTime: Date(), notificationEnabled: true)
        ])
    }
}

