import SwiftUI
import WidgetKit
import UserNotifications
import UserNotificationsUI

struct SettingsView: View {
    @Binding var emojiBank: EmojiBank
    @Binding var tasks: [Task]
    @State private var newEmoji: String = ""
    @State private var showInvalidEmojiAlert = false
    @AppStorage("selectedTheme", store: UserDefaults(suiteName: "group.com.yourcompany.DailyTaskChecker")) private var selectedTheme: String = "System Default"
    //@AppStorage("notificationTime", store: UserDefaults(suiteName: "group.com.yourcompany.DailyTaskChecker")) private var notificationTimeString: String = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short)
    @State private var emojiKeyboardVisible = false

    private let defaultEmojis = ["✅", "💊", "💉", "🩸", "🚴‍♂️", "🏃‍♂️", "🧘‍♂️", "⭐️"]

    var body: some View {
        Form {
            Section(header: Text("Edit Emoji Bank")) {
                EmojiGrid(emojiBank: $emojiBank)
                
                HStack {
                    TextField("New Emoji", text: $newEmoji, onEditingChanged: { _ in
                        emojiKeyboardVisible = true
                    })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .emojiKeyboard($emojiKeyboardVisible)
                    Button(action: addEmoji) {
                        Text("Add")
                    }
                }
                .padding()

                Button(action: resetEmojis) {
                    Text("Reset Emojis to Default")
                        .foregroundColor(.red)
                }
                .padding()
            }
            Section {
                NavigationLink(destination: NotificationView(tasks: $tasks)) {
                    Text("Notification Settings")
                }
            }
            Section(header: Text("Appearance")) {
                Picker("Theme", selection: $selectedTheme) {
                    Text("Light").tag("Light")
                    Text("Dark").tag("Dark")
                    Text("System Default").tag("System Default")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            Section {
                HStack {
                    Spacer()
                    NavigationLink(destination: StreaksView()) {
                        VStack {
                            Image(systemName: "trophy")
                                .resizable()
                                .frame(width: 50, height: 50)
                            Text("Achievements")
                                .font(.headline)
                        }
                        .padding()
                    }
                    Spacer()
                }
            }
        }
        .alert(isPresented: $showInvalidEmojiAlert) {
            Alert(title: Text("Invalid Emoji"), message: Text("Please enter a valid emoji."), dismissButton: .default(Text("OK")))
        }
        .navigationTitle("Settings")
    }

    private func addEmoji() {
        guard isValidEmoji(newEmoji) else {
            showInvalidEmojiAlert = true
            return
        }
        emojiBank.emojis.append(newEmoji)
        newEmoji = ""
        saveEmojiBank()
    }

    private func resetEmojis() {
        emojiBank.emojis = defaultEmojis
        saveEmojiBank()
    }

    private func saveEmojiBank() {
        if let data = try? JSONEncoder().encode(emojiBank) {
            UserDefaults(suiteName: "group.com.yourcompany.DailyTaskChecker")?.set(data, forKey: "emojiBank")
        }
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func isValidEmoji(_ string: String) -> Bool {
        string.unicodeScalars.allSatisfy { $0.properties.isEmoji }
    }

//    private func scheduleDailyReminder() {
//        if let delegate = UIApplication.shared.delegate as? AppDelegate {
//            let reminderTime = getNotificationTime()
//            delegate.scheduleDailyReminder(at: reminderTime, tasks: tasks)
//        }
//    }

//    private func getNotificationTime() -> Date {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .none
//        formatter.timeStyle = .short
//        return formatter.date(from: notificationTimeString) ?? Date()
//    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView(
                emojiBank: .constant(EmojiBank(emojis: ["✅", "💊", "💉"])),
                tasks: .constant([
                    Task(name: "Sample Task 1", urgency: .low),
                    Task(name: "Sample Task 2", urgency: .high, notificationTime: Date(), notificationEnabled: true)
                ])
            )
        }
    }
}
