//
//  Provider.swift
//  WidgetsExtension
//
//  Created by Yerzhan Tulepov on 07.02.2022.
//

import WidgetKit

struct Provider: TimelineProvider {
    func getSnapshot(in context: Context, completion: @escaping (SolatEntry) -> ()) {
        completion(Provider.previewEntry)
        //        let noDataEntry = SolatEntry(
        //            date: Date(),
        //            city: "",
        //            dateByHijrah: "",
        //            type: .fadjr,
        //            times: Times(date: "", fadjr: "", sunrise: "", dhuhr: "", asr: "", maghrib: "", isha: "")
        //        )
        //
        //        let city = Settings.getCity()
        //        guard city != nil else {
        //            completion(noDataEntry)
        //            return
        //        }
        //
        //        Task {
        //            let times = try await SolatTimes.getForToday()
        //            guard times != nil else {
        //                completion(noDataEntry)
        //                return
        //            }
        //
        //            let dateByHijrah = try await SolatTimes.getHijrahDate()
        //
        //            let type = getAzanType(times: times!)
        //
        //            let entry = SolatEntry(
        //                date: Date(),
        //                city: city!,
        //                dateByHijrah: dateByHijrah,
        //                type: type,
        //                times: times!
        //            )
        //
        //            completion(entry)
        //        }
    }
    
    private func getAzanType(times: Times) -> AzanType {
        let now = Date()
        
        if now < toDate(time: times.fadjr) { return .isha }
        if now < toDate(time: times.sunrise) { return .fadjr }
        if now < toDate(time: times.dhuhr) { return .sunrise }
        if now < toDate(time: times.asr) { return .dhuhr }
        if now < toDate(time: times.maghrib) { return .asr }
        if now < toDate(time: times.isha) { return .maghrib }
        else { return .isha}
    }
    
    private func toDate(time: String) -> Date {
        let timeParts = time.trimmingCharacters(in: CharacterSet.whitespaces).split(separator: ":")
        let hour = Int(timeParts[0])!
        let minute = Int(timeParts[1])!
        
        return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SolatEntry>) -> ()) {
        Task {
            if let city = Settings.getCity() {
                if let times = try await SolatTimes.getForToday() {
                    let dateByHijrah = try await SolatTimes.getHijrahDate()
                    
                    var entries: [SolatEntry] = []
                    
                    entries.append(SolatEntry(date: toDate(time: times.fadjr), city: city, dateByHijrah: dateByHijrah, type: .fadjr, times: times))
                    entries.append(SolatEntry(date: toDate(time: times.sunrise), city: city, dateByHijrah: dateByHijrah, type: .sunrise, times: times))
                    entries.append(SolatEntry(date: toDate(time: times.dhuhr), city: city, dateByHijrah: dateByHijrah, type: .dhuhr, times: times))
                    entries.append(SolatEntry(date: toDate(time: times.asr), city: city, dateByHijrah: dateByHijrah, type: .asr, times: times))
                    entries.append(SolatEntry(date: toDate(time: times.maghrib), city: city, dateByHijrah: dateByHijrah, type: .maghrib, times: times))
                    entries.append(SolatEntry(date: toDate(time: times.isha), city: city, dateByHijrah: dateByHijrah, type: .isha, times: times))
                    
                    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
                    let refreshDate = Calendar.current.date(bySettingHour: 0, minute: 11, second: 0, of: tomorrow)!
                    
                    let timeline = Timeline(entries: entries, policy: .after(refreshDate))
                    completion(timeline)
                }
            }
        }
    }
    
    static let times = Times(
        date: "",
        fadjr: "06:35",
        sunrise: "07:52",
        dhuhr: "13:09",
        asr: "16:38",
        maghrib: "18:22",
        isha: "19:38"
    )
    
    static let previewEntry = SolatEntry(
        date: Calendar.current.date(from: DateComponents(year: 2022, month: 2, day: 12))!,
        city: "Алматы",
        dateByHijrah: "10 Раджаб 1443",
        type: .asr,
        times: times
    )
    
    func placeholder(in context: Context) -> SolatEntry {
        Provider.previewEntry
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
    
    init(date: Date, city: String, dateByHijrah: String, type: AzanType, times: Times) {
        self.date = date
        self.city = city
        self.dateByHijrah = dateByHijrah
        self.type = type
        self.fadjr = times.fadjr
        self.sunrise = times.sunrise
        self.dhuhr = times.dhuhr
        self.asr = times.asr
        self.maghrib = times.maghrib
        self.isha = times.isha
    }
}

enum AzanType : Int {
    case fadjr = 1, sunrise, dhuhr, asr, maghrib, isha
}
