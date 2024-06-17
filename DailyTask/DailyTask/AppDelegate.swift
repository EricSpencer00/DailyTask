import UIKit
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        requestNotificationAuthorization()
        
        // Access tasks from TaskManager and schedule reminders
        TaskManager.shared.scheduleDailyReminder()
        
        return true
    }

    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Authorization error: \(error.localizedDescription)")
            } else if granted {
                print("Notification authorization granted.")
            } else {
                print("Notification authorization denied.")
            }
        }
    }

    // UNUserNotificationCenterDelegate methods
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Received notification in the foreground: \(notification.request.content.body)")
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("User responded to notification: \(response.notification.request.content.body)")
        completionHandler()
    }
    
//    func scheduleNotification(for task: Task, at time: Date()) {
//        
//        print("Scheduling notification for task: \(task.name) at \(task.notificationTime)")
//        
//        let content = UNMutableNotificationContent()
//        content.title = "DailyTask"
//        content.body = "Don't forget to: \(task.name)"
//        content.sound = .default
//        
//        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
//        dateComponents.second = 0
//
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
//        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
//
//        UNUserNotificationCenter.current().add(request) { error in
//            if let error = error {
//                print("Error scheduling notification: \(error.localizedDescription)")
//            }
//        }
//    }
    
    func scheduleDailyReminder(at time: Date, tasks: [Task]) {
        for task in tasks {
//            scheduleNotification(for: task, at: time)
        }
    }
}
