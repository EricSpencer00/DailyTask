import SwiftUI
import WidgetKit
import CoreData
import ConfettiSwiftUI

struct ContentView: View {
    @AppStorage("lastResetDate", store: UserDefaults(suiteName: "group.com.yourcompany.DailyTaskChecker")) private var lastResetDate: String = ""
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
                    // Reset isEditing to false when there are no tasks
                    .onAppear {
                        isEditing = false
                    }
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
                .confettiCannon(counter: $confettiTrigger, confettiSize: 20.0, repetitions: 2, repetitionInterval: 0.1)
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
//            .onChange(of: tasks) { newTasks in
//                if newTasks.isEmpty {
//                    isEditing = false
//                }
//            }
        }
        .onAppear {
            loadTasks()
            isFocused = false
        }
    }
    
    private func printAppStorageValues() {
        let tasks = TaskStorage.shared.loadTasks()
        print("Tasks: \(tasks)")
        print("Last Reset Date: \(lastResetDate)")
        let emojiBank = TaskStorage.shared.loadEmojiBank()
        print("Emoji Bank: \(emojiBank)")
        print("Selected Theme: \(selectedTheme)")
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
                    toggleTaskCompletion(for: index)
                    confettiTrigger += 1
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
    }

    private func loadTasks() {
        tasks = TaskStorage.shared.loadTasks()
        emojiBank = TaskStorage.shared.loadEmojiBank()
    }

    private func saveTasks() {
        TaskStorage.shared.saveTasks(tasks)
        TaskStorage.shared.saveEmojiBank(emojiBank)
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

    private func toggleTaskCompletion(for index: Int) {
        tasks[index].isCompleted.toggle()
        if tasks[index].isCompleted {
            StreakManager.shared.incrementCompletion(for: &tasks[index])
        } else {
            StreakManager.shared.resetStreak(for: tasks[index].id)
        }
        saveTasks()
        WidgetCenter.shared.reloadAllTimelines()
        AchievementManager.shared.checkAchievements(for: tasks[index].id)
        AchievementManager.shared.checkAllTasksCompleted(for: tasks)
    }
}

struct TaskBucketView: View {
    @Binding var tasks: [Task]
    @Binding var taskToComplete: Task?
    @Binding var showCompletionConfirmation: Bool
    @Binding var taskToEdit: Task?
    @Binding var isEditing: Bool

    var body: some View {
        ForEach(Urgency.allCases.sorted(by: { $0.priority > $1.priority }), id: \.self) { urgency in
            if !tasks.filter({ $0.urgency == urgency }).isEmpty {
                TaskBucket(
                    urgency: urgency,
                    tasks: $tasks,
                    taskToComplete: $taskToComplete,
                    showCompletionConfirmation: $showCompletionConfirmation,
                    taskToEdit: $taskToEdit,
                    isEditing: $isEditing
                )
            }
        }
    }
}

