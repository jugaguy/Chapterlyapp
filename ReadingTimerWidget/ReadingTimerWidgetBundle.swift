//
//  ReadingTimerWidgetBundle.swift
//  ReadingTimerWidget
//
//  Created by arslaan ahmed on 21/12/2024.
//

import WidgetKit
import SwiftUI


@main
struct ReadingTimerWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        ReadingTimerWidget()
        ReadingTimerWidgetControl()
    }
}




