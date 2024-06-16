//
//  EditTaskView.swift
//  DailyTask
//
//  Created by Eric Spencer on 5/28/24.
//

import Foundation
import SwiftUI

struct EditTaskView: View {
    @Binding var task: Task
    @Binding var emojiBank: EmojiBank
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            TextField("Task Name", text: $task.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Picker("Emoji", selection: $task.emoji) {
                ForEach(emojiBank.emojis, id: \.self) { emoji in
                    Text(emoji).tag(emoji)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .padding()
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Save")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
}

