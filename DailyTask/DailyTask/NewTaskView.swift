//
//  NewTaskView.swift
//  DailyTask
//
//  Created by Eric Spencer on 5/28/24.
//
import SwiftUI
import WidgetKit
import Foundation

struct CollapsedTaskView: View {
    @Binding var isExpanded: Bool
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "chevron.up")
                        .foregroundColor(.gray)
                    Text("Create New Task")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color.black : Color.white)
    }
}

struct NewTaskView: View {
    @Binding var newTaskName: String
    @Binding var selectedEmoji: String
    @Binding var selectedUrgency: Urgency
    @Binding var emojiBank: EmojiBank
    @State private var notificationTime: Date? = nil
    @State private var isNotificationEnabled: Bool = false
    @Binding var tasks: [Task]
    @State private var isExpanded: Bool = true
    var addTaskAction: () -> Void
    @FocusState var isFocused: Bool
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
            VStack {
                if tasks.count < 2 || !isExpanded {
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                isExpanded = true
                            }) {
                                Image(systemName: "chevron.left.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding()
                            }
                        }
                        
                        TextField("New Task", text: $newTaskName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($isFocused)
                            .padding(.bottom, 8)
                        
                        HStack {
                            Picker("Urgency", selection: $selectedUrgency) {
                                ForEach(Urgency.allCases, id: \.self) { urgency in
                                    Text(customLabel(for: urgency)).tag(urgency)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                            Picker("Emoji", selection: $selectedEmoji) {
                                ForEach(emojiBank.emojis, id: \.self) { emoji in
                                    Text(emoji).tag(emoji)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        Toggle(isOn: $isNotificationEnabled) {
                            Text("Enable Notification")
                        }
                        .padding(.bottom, 8)
                        
                        if isNotificationEnabled {
                            DatePicker("Notification Time", selection: Binding(
                                get: {
                                    notificationTime ?? Date()
                                },
                                set: { newValue in
                                    notificationTime = newValue
                                }
                            ), displayedComponents: .hourAndMinute)
                            .padding(.bottom, 8)
                        }

                        Button(action: {
                            addTaskAction()
                            if isNotificationEnabled, let notificationTime = notificationTime {
                                let newTask = Task(
                                    name: newTaskName,
                                    urgency: selectedUrgency,
                                    emoji: selectedEmoji,
                                    notificationTime: notificationTime
                                )
                                TaskManager.shared.scheduleNotification(for: newTask)
                            }
                        }) {
                            Text("Add")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(colorScheme == .dark ? Color.black : Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 10)
                    .transition(AnyTransition.asymmetric(
                        insertion: .identity,
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
                    .animation(Animation.easeInOut(duration: 0.5).delay(0.1), value: isExpanded)
                } else {
                    CollapsedTaskView(isExpanded: $isExpanded)
                }
            }
        }
    
    private func customLabel(for urgency: Urgency) -> String {
        switch urgency {
        case .low:
            return "Low Priority"
        case .medium:
            return "Medium Priority"
        case .high:
            return "High Priority"
        }
    }
}


