//
//  StreakWidgetBundle.swift
//  StreakWidget
//
//  Created by arslaan ahmed on 25/12/2024.
//

import WidgetKit
import SwiftUI

@main
struct StreakWidgetBundle: WidgetBundle {
    var body: some Widget {
        StreakWidget()
        StreakWidgetControl()
        StreakWidgetLiveActivity()
    }
}
