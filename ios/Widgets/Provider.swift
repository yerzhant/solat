//
//  Provider.swift
//  WidgetsExtension
//
//  Created by Yerzhan Tulepov on 07.02.2022.
//

import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SolatEntry {
        SolatEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SolatEntry) -> ()) {
        let entry = SolatEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SolatEntry>) -> ()) {
        var entries: [SolatEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SolatEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SolatEntry: TimelineEntry {
    let date: Date
//    let current: AzanType
//    let fadjr: String
//    let sunrise: String
//    let dhuhr: String
//    let asr: String
//    let maghrib: String
//    let isha: String
}

enum AzanType : Int {
    case fadjr, sunrise, dhuhr, asr, maghrib, isha
}
