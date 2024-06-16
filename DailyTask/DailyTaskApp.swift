//
//  DailyTaskApp.swift
//  DailyTask
//
//  Created by Eric Spencer on 5/27/24.
//
import Foundation
import SwiftUI
import HealthKit

@main
struct DailyTaskApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//    @StateObject private var healthStore = HealthStore()
    
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}

