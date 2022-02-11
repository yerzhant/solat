//
//  Provider.swift
//  WidgetsExtension
//
//  Created by Yerzhan Tulepov on 07.02.2022.
//

import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SolatEntry {
        SolatEntry(
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
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SolatEntry) -> ()) {
        Task {
            let city = Settings.getCity()
            guard city != nil else { return }
            
            let dates = try await SolatTimes.getForToday()
            guard dates != nil else {
                return
            }

            let dateByHijrah = try await SolatTimes.getHijrahDate()
            
            let type = AzanType.asr
            
            let entry = SolatEntry(
                date: Date(),
                city: city!,
                dateByHijrah: dateByHijrah,
                type: type,
                fadjr: dates!.fadjr,
                sunrise: dates!.sunrise,
                dhuhr: dates!.dhuhr,
                asr: dates!.asr,
                maghrib: dates!.maghrib,
                isha: dates!.isha
            )
            
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SolatEntry>) -> ()) {
        var entries: [SolatEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let currentDate = Date()
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = SolatEntry(date: entryDate)
//            entries.append(entry)
//        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SolatEntry: TimelineEntry {
    let date: Date
    let city: String
    let dateByHijrah: String
    let type: AzanType
    let fadjr: String
    let sunrise: String
    let dhuhr: String
    let asr: String
    let maghrib: String
    let isha: String
}

enum AzanType : Int {
    case fadjr = 1, sunrise, dhuhr, asr, maghrib, isha
}
