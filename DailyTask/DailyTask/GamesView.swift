//
//  GamesView.swift
//  DailyTask
//
//  Created by Eric Spencer on 5/31/24.
//

import Foundation

import SwiftUI

struct StreaksView: View {
    @State private var achievements: [Achievement] = []

    var body: some View {
        NavigationView {
            VStack {
                AchievementsBubbleView()
                List(achievements, id: \.self) { achievement in
                    Text(achievement.description)
                }
                .navigationTitle("Achievements")
                .onAppear {
                    achievements = AchievementManager.shared.getAchievements()
                }
            }
        }
    }
}

struct StreaksView_Previews: PreviewProvider {
    static var previews: some View {
        StreaksView()
    }
}
