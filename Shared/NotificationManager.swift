//
//  NotificationManager.swift
//  DailyTask
//
//  Created by Eric Spencer on 6/30/24.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private func currentTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }
    
    private func notificationTimeString(for date: Date?) -> String {
        guard let date = date else { return "No notification time set" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    func scheduleNotification(for task: Task) {
        guard task.notificationEnabled, let notificationTime = task.notificationTime else {
            print("\(currentTimeString()) - Task: \(task.name) has no notification time or notifications are disabled.")
            return
        }
        
        let notificationTimeString = self.notificationTimeString(for: notificationTime)
        print("Scheduling notification for task: \(task.name) at \(notificationTimeString)")
        
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = task.name
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func unscheduleNotification(for task: Task) {
        guard let notificationTime = task.notificationTime else {
            print("Unscheduling notification for task: \(task.name) - No notification time set.")
            return
        }
        
        let notificationTimeString = self.notificationTimeString(for: notificationTime)
        print("Unscheduling notification for task: \(task.name) at \(notificationTimeString)")
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [task.id.uuidString])
    }
}
