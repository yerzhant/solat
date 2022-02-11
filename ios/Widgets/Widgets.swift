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
        WidgetsEntryView(entry: SolatEntry(
            date: DateComponents(year: 2022, month: 2, day: 12).date!,
            city: "Алматы",
            dateByHijrah: "10 Раджаб 1443",
            type: .asr,
            fadjr: "06:35",
            sunrise: "07:52",
            dhuhr: "13:09",
            asr: "16:38",
            maghrib: "18:22",
            isha: "19:38"
        ))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
