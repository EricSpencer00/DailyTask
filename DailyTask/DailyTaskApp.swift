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

class MyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up title view
        let titleView = UIView()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        navigationItem.titleView = titleView
        
        // Ensure the navigation bar content view has a proper width constraint
        if let navigationBarContentView = navigationController?.navigationBar.subviews.first(where: { $0.isKind(of: NSClassFromString("_UINavigationBarContentView")!) }) {
            navigationBarContentView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                navigationBarContentView.widthAnchor.constraint(greaterThanOrEqualToConstant: 200) // Example width
            ])
        }
        
        // Add the title view constraints
        let marginsGuide = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(greaterThanOrEqualTo: marginsGuide.leadingAnchor),
            titleView.trailingAnchor.constraint(lessThanOrEqualTo: marginsGuide.trailingAnchor),
            titleView.centerXAnchor.constraint(equalTo: marginsGuide.centerXAnchor),
            titleView.widthAnchor.constraint(equalToConstant: 200), // Example width
        ])
    }
}


