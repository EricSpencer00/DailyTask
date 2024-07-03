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
    @AppStorage("notificationTime", store: UserDefaults(suiteName: "group.com.yourcompany.DailyTaskChecker")) private var notificationTimeString: String = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short)
    
    private let defaultEmojis = ["✅", "💊", "💉", "🩸", "🚴‍♂️", "🏃‍♂️", "🧘‍♂️", "⭐️"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Emoji Bank")) {
                    EmojiGrid(emojiBank: $emojiBank)
                    
                    HStack {
                        TextField("New Emoji", text: $newEmoji)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
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
                        Text("Notification Settings 🕑")
                    }
                }
                Section {
                    NavigationLink(destination: MainTrophyRoomView(tasks: tasks, emojiBank: TaskStorage.shared.loadEmojiBank())) {
                        Text("Trophies 🏆")
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
            }
            .alert(isPresented: $showInvalidEmojiAlert) {
                Alert(title: Text("Invalid Emoji"), message: Text("Please enter a valid emoji."), dismissButton: .default(Text("OK")))
            }
            .navigationTitle("Settings")
        }
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
        if string.isEmpty {
            return false
        }

        for scalar in string.unicodeScalars {
            guard scalar.properties.isEmoji,
                  (scalar.properties.isEmojiPresentation ||
                   scalar.value >= 0x1F600 && scalar.value <= 0x1F64F ||  // Faces
                   scalar.value >= 0x1F300 && scalar.value <= 0x1F5FF ||  // Misc Symbols + Pictographs
                   scalar.value >= 0x1F680 && scalar.value <= 0x1F6FF ||  // Transport + Map
                   scalar.value >= 0x1F1E6 && scalar.value <= 0x1F1FF) // Flags
            else {
                return false
            }
        }
        
        return true
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(
            emojiBank: .constant(EmojiBank(emojis: ["✅", "💊", "💉"])),
            tasks: .constant([
                Task(name: "Sample Task 1", urgency: .low),
                Task(name: "Sample Task 2", urgency: .high, notificationTime: Date(), notificationEnabled: true)
            ])
        )
    }
}
