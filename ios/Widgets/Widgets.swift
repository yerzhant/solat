//
//  Widgets.swift
//  Widgets
//
//  Created by Yerzhan Tulepov on 07.02.2022.
//

import WidgetKit
import SwiftUI

struct WidgetsEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        Text(entry.date, style: .time)
    }
}

@main
struct Widgets: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "kz.azan.solat.widget", provider: Provider()) { entry in
            WidgetsEntryView(entry: entry)
        }
        .configurationDisplayName("Время намаза")
        .description("Время намаза для Казахстана.")
        .supportedFamilies([.systemMedium])
    }
}

struct Widgets_Previews: PreviewProvider {
    static var previews: some View {
        WidgetsEntryView(entry: Provider.previewEntry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
