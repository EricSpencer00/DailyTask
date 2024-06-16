//
//  DailyTaskWidgetBundle.swift
//  DailyTaskWidget
//
//  Created by Eric Spencer on 5/26/24.
//

import WidgetKit
import SwiftUI

@main
struct DailyTaskWidgetBundle: WidgetBundle {
    var body: some Widget {
        DailyTaskWidget()
        DailyTaskWidgetLiveActivity()
    }
}
