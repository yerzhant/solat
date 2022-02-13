//
//  Widgets.swift
//  Widgets
//
//  Created by Yerzhan Tulepov on 07.02.2022.
//

import SwiftUI
import WidgetKit

let appGroup = "group.kz.azan.solat"

@main
struct Widgets: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "kz.azan.solat.widget", provider: Provider()) { entry in
            MediumWidget(entry: entry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("WidgetBackground"))
        }
        .configurationDisplayName("Время намаза")
        .description("Время намаза для Казахстана.")
        .supportedFamilies([.systemMedium])
    }
}
