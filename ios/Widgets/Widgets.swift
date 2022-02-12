//
//  Widgets.swift
//  Widgets
//
//  Created by Yerzhan Tulepov on 07.02.2022.
//

import SwiftUI
import WidgetKit

@main
struct Widgets: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "kz.azan.solat.widget", provider: Provider()) { entry in
            MediumWidget(entry: entry)
        }
        .configurationDisplayName("Время намаза")
        .description("Время намаза для Казахстана.")
        .supportedFamilies([.systemMedium])
    }
}
