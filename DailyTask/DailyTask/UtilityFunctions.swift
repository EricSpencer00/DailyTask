//
//  UtilityFunctions.swift
//  DailyTask
//
//  Created by Eric Spencer on 5/28/24.
//

import Foundation
import SwiftUI

func color(for urgency: Urgency) -> Color {
    switch urgency {
    case .low:
        return .green
    case .medium:
        return .yellow
    case .high:
        return .red
    }
}
