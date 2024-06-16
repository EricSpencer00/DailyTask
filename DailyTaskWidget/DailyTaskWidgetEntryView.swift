//
//  DailyTaskWidgetEntryView.swift
//  DailyTask
//
//  Created by Eric Spencer on 5/29/24.
//

import Foundation
import SwiftUI
import WidgetKit

struct DailyTaskWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Daily Task")
                .font(.headline)
            HStack {
                Text(entry.task.emoji)
                    .font(.largeTitle)
                Text(entry.task.name)
                    .font(.headline)
                Spacer()
                Image(systemName: entry.task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(entry.task.isCompleted ? .green : .red)
            }
        }
        .padding()
        .widgetURL(URL(string: "dailytask://task"))
    }
}
