import SwiftUI
import WidgetKit
import CoreData
import ConfettiSwiftUI

struct ContentView: View {
    @AppStorage("tasks", store: UserDefaults(suiteName: "group.com.yourcompany.DailyTaskChecker")) private var tasksData: Data = Data()
    @AppStorage("lastResetDate", store: UserDefaults(suiteName: "group.com.yourcompany.DailyTaskChecker")) private var lastResetDate: String = ""
    @AppStorage("emojiBank", store: UserDefaults(suiteName: "group.com.yourcompany.DailyTaskChecker")) private var emojiBankData: Data = Data()
    @AppStorage("selectedTheme", store: UserDefaults(suiteName: "group.com.yourcompany.DailyTaskChecker")) private var selectedTheme: String = "System Default"
    @AppStorage("notificationTime", store: UserDefaults(suiteName: "group.com.yourcompany.DailyTaskChecker")) private var notificationTimeString: String = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short)
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var tasks: [Task] = []
    @State private var newTaskName: String = ""
    @State private var selectedEmoji: String = "✅"
    @State private var selectedUrgency: Urgency = .low
    @State private var showCompletionConfirmation = false
    @State private var taskToComplete: Task?
    @State private var taskToEdit: Task?
    @State private var confettiTrigger: Int = 0
    @State private var emojiBank: EmojiBank = EmojiBank(emojis: ["✅", "💊", "💉", "🩸", "🚴‍♂️", "🏃‍♂️", "🧘‍♂️", "⭐️"])
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var isFocused: Bool
    
    @State private var isEditing = false
    
    var body: some View {
        NavigationView {
            VStack {
                if tasks.isEmpty {
                    Text("No tasks, create some below!")
                        .font(.title)
                        .padding()
                } else {
                    ScrollView(.vertical) {
                        VStack(spacing: 10) {
                            TaskBucketView(tasks: $tasks, taskToComplete: $taskToComplete, showCompletionConfirmation: $showCompletionConfirmation, taskToEdit: $taskToEdit, isEditing: $isEditing)
                        }
                        .padding()
                    }
                }
                NewTaskView(
                    newTaskName: $newTaskName,
                    selectedEmoji: $selectedEmoji,
                    selectedUrgency: $selectedUrgency,
                    emojiBank: $emojiBank,
                    tasks: $tasks,
                    addTaskAction: addTask,
                    isFocused: _isFocused
                )
                .confettiCannon(counter: $confettiTrigger, confettiSize: 20.0, repetitions: 3, repetitionInterval: 0.5)
            }
            .onAppear(perform: checkAndResetTasks)
            .onOpenURL(perform: handleOpenURL)
            .alert(isPresented: $showCompletionConfirmation, content: taskCompletionAlert)
            .sheet(item: $taskToEdit) { task in
                EditTaskView(task: $tasks[tasks.firstIndex(where: { $0.id == task.id })!], emojiBank: $emojiBank)
            }
            .navigationBarTitle("Daily Tasks", displayMode: .inline)
            .preferredColorScheme(getColorScheme(for: selectedTheme))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView(emojiBank: $emojiBank, tasks: $tasks)) {
                        Text("Settings")
                    }
                }
                if !tasks.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            withAnimation {
                                isEditing.toggle()
                            }
                        }) {
                            Text(isEditing ? "Done" : "Edit")
                        }
                    }
                }
            }
        }
        .onAppear {
            isFocused = false
        }
    }
    
    private func printAppStorageValues() {
        // Decode tasksData
        if let decodedTasks = try? JSONDecoder().decode([Task].self, from: tasksData) {
            print("Tasks:")
            for task in decodedTasks {
                print(task)
            }
        } else {
            print("Failed to decode tasksData.")
        }

        // Print lastResetDate
        print("Last Reset Date: \(lastResetDate)")

        // Decode emojiBankData
        if let decodedEmojiBank = try? JSONDecoder().decode(EmojiBank.self, from: emojiBankData) {
            print("Emoji Bank:")
            print(decodedEmojiBank)
        } else {
            print("Failed to decode emojiBankData.")
        }

        // Print selectedTheme
        print("Selected Theme: \(selectedTheme)")

        // Print notificationTimeString
        print("Notification Time: \(notificationTimeString)")
    }

    private func handleOpenURL(url: URL) {
        if url.scheme == "dailytask" && url.host == "task" {
            if let task = tasks.first(where: { !$0.isCompleted }) {
                taskToComplete = task
                showCompletionConfirmation = true
            }
        }
    }

    private func taskCompletionAlert() -> Alert {
        Alert(
            title: Text("Complete Task"),
            message: Text("Are you sure you \(taskToComplete?.name ?? "")'d today?"),
            primaryButton: .default(Text("Yes")) {
                if let task = taskToComplete, let index = tasks.firstIndex(where: { $0.id == task.id }) {
                    tasks[index].isCompleted.toggle()
                    saveTasks()
                    WidgetCenter.shared.reloadAllTimelines()
                    StreakManager.shared.updateStreak(for: task.id)
                    AchievementManager.shared.checkAchievements(for: task.id)
                    AchievementManager.shared.checkAllTasksCompleted(for: tasks)

                    if tasks.allSatisfy({ $0.isCompleted }) {
                        confettiTrigger += 1
                    }
                }
            },
            secondaryButton: .cancel()
        )
    }

    private func checkAndResetTasks() {
        let today = getCurrentDateString()
        if today != lastResetDate {
            tasks.indices.forEach { tasks[$0].isCompleted = false }
            lastResetDate = today
            saveTasks()
        }
        loadTasks()
    }

    private func loadTasks() {
        if let loadedTasks = try? JSONDecoder().decode([Task].self, from: tasksData) {
            tasks = loadedTasks
        }
        if let loadedEmojiBank = try? JSONDecoder().decode(EmojiBank.self, from: emojiBankData) {
            emojiBank = loadedEmojiBank
        }
    }

    private func saveTasks() {
        if let data = try? JSONEncoder().encode(tasks) {
            tasksData = data
        }
        if let data = try? JSONEncoder().encode(emojiBank) {
            emojiBankData = data
        }
    }

    private func addTask() {
        guard !newTaskName.isEmpty else { return }
        let newTask = Task(name: newTaskName, urgency: selectedUrgency, emoji: selectedEmoji)
        tasks.append(newTask)
        newTaskName = ""
        saveTasks()
        WidgetCenter.shared.reloadAllTimelines()
        isFocused = false
    }

    private func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        saveTasks()
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func deleteTask(task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks.remove(at: index)
            saveTasks()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    private func moveTask(from source: IndexSet, to destination: Int) {
        tasks.move(fromOffsets: source, toOffset: destination)
        saveTasks()
    }

    private func getColorScheme(for theme: String) -> ColorScheme? {
        switch theme {
        case "Light":
            return .light
        case "Dark":
            return .dark
        default:
            return nil
        }
    }

    private func getCurrentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private func saveCompletion(task: Task) {
        let completion = TaskCompletion(context: viewContext)
        completion.taskId = task.id
        completion.completionDate = Date()

        do {
            try viewContext.save()
        } catch {
            // Handle the Core Data error.
        }
    }
}

struct TaskBucketView: View {
    @Binding var tasks: [Task]
    @Binding var taskToComplete: Task?
    @Binding var showCompletionConfirmation: Bool
    @Binding var taskToEdit: Task?
    @Binding var isEditing: Bool

    var body: some View {
        ForEach(Urgency.allCases, id: \.self) { urgency in
            if !tasks.filter({ $0.urgency == urgency }).isEmpty {
                TaskBucket(urgency: urgency, tasks: $tasks, taskToComplete: $taskToComplete, showCompletionConfirmation: $showCompletionConfirmation, taskToEdit: $taskToEdit, isEditing: $isEditing)
            }
        }
    }
}
