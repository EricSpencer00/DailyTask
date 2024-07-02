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
    
    func scheduleNotification(for task: Task) {
        print("Scheduling notification for task: \(task.name)")
        guard task.notificationEnabled, let notificationTime = task.notificationTime else { return }
        
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
        print("Unscheduling notification for task: \(task.name)")
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [task.id.uuidString])
    }
}

