//
//  ContentView_Preview.swift
//  DailyTask
//
//  Created by Eric Spencer on 5/28/24.
//

import Foundation
import SwiftUI

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            tasks: .constant([
                Task(name: "Task 1", urgency: .low),
                Task(name: "Task 2", urgency: .medium),
                Task(name: "Task 3", urgency: .high)
            ]),
            newTaskName: .constant(""),
            selectedEmoji: .constant("✅"),
            showCompletionConfirmation: .constant(false),
            taskToComplete: .constant(nil),
            taskToEdit: .constant(nil),
            emojiBank: .constant(EmojiBank(emojis: ["✅", "📈", "🏋️‍♂️", "🎯", "🔔", "⭐️", "📌", "‼️"])),
            isFocused: .constant(false)
        )
    }
}
