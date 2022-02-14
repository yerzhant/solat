//
//  Provider.swift
//  WidgetsExtension
//
//  Created by Yerzhan Tulepov on 07.02.2022.
//

import WidgetKit

struct Provider: TimelineProvider {
    func getSnapshot(in context: Context, completion: @escaping (SolatEntry) -> ()) {
        guard let city = Settings.getCity() else {
            completion(Provider.noDataEntry)
            return
        }
        
        Task {
            guard let times = try await SolatTimes.getForToday() else {
                completion(Provider.noDataEntry)
                return
            }
            
            let dateByHijrah = try await SolatTimes.getHijrahDate()
            
            let type = getAzanType(times: times)
            
            let entry = SolatEntry(
                date: Date(),
                city: city,
                dateByHijrah: dateByHijrah,
                type: type,
                times: times
            )
            
            completion(entry)
        }
    }
    
    fileprivate func getAzanType(times: Times) -> AzanType {
        let now = Date()
        
        if now < times.fadjr.toDate() { return .isha }
        if now < times.sunrise.toDate() { return .fadjr }
        if now < times.dhuhr.toDate() { return .sunrise }
        if now < times.asr.toDate() { return .dhuhr }
        if now < times.maghrib.toDate() { return .asr }
        if now < times.isha.toDate() { return .maghrib }
        else { return .isha}
    }
    
    fileprivate func getNoDataTimeline(_ completion: (Timeline<SolatEntry>) -> ()) {
        let entry = [Provider.noDataEntry]
        
        let timeline = Timeline(entries: entry, policy: .never)
        completion(timeline)
    }
    
    fileprivate func getEntitiesFor(city: String, dateByHijrah: String, times: Times) -> [SolatEntry] {
        var entries: [SolatEntry] = []
        
        let now = Date()
        
        entries.append(SolatEntry(date: now, city: city, dateByHijrah: dateByHijrah, type: getAzanType(times: times), times: times))
        
        if now < times.fadjr.toDate() {
            entries.append(SolatEntry(date: times.fadjr.toDate(), city: city, dateByHijrah: dateByHijrah, type: .fadjr, times: times))
        }
        
        if now < times.sunrise.toDate() {
            entries.append(SolatEntry(date: times.sunrise.toDate(), city: city, dateByHijrah: dateByHijrah, type: .sunrise, times: times))
        }
        
        if now < times.dhuhr.toDate() {
            entries.append(SolatEntry(date: times.dhuhr.toDate(), city: city, dateByHijrah: dateByHijrah, type: .dhuhr, times: times))
        }
        
        if now < times.asr.toDate() {
            entries.append(SolatEntry(date: times.asr.toDate(), city: city, dateByHijrah: dateByHijrah, type: .asr, times: times))
        }
        
        if now < times.maghrib.toDate() {
            entries.append(SolatEntry(date: times.maghrib.toDate(), city: city, dateByHijrah: dateByHijrah, type: .maghrib, times: times))
        }
        
        if now < times.isha.toDate() {
            entries.append(SolatEntry(date: times.isha.toDate(), city: city, dateByHijrah: dateByHijrah, type: .isha, times: times))
        }
        
        return entries
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SolatEntry>) -> ()) {
        Task {
            guard let city = Settings.getCity() else {
                getNoDataTimeline(completion)
                return
            }
            
            guard let times = try await SolatTimes.getForToday() else {
                getNoDataTimeline(completion)
                return
            }
            
            let dateByHijrah = try await SolatTimes.getHijrahDate()
            
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            let refreshDate = Calendar.current.date(bySettingHour: 0, minute: 11, second: 0, of: tomorrow)!
            
            let timeline = Timeline(entries: getEntitiesFor(city: city, dateByHijrah: dateByHijrah, times: times), policy: .after(refreshDate))
            
            completion(timeline)
        }
    }
    
    func placeholder(in context: Context) -> SolatEntry {
        return Provider.previewEntry
    }
    
    static let noDataEntry = SolatEntry(
        date: Date(),
        city: "",
        dateByHijrah: "Нет данных",
        type: .fadjr,
        times: Times(date: "", fadjr: "", sunrise: "", dhuhr: "", asr: "", maghrib: "", isha: "")
    )
    
    static let previewEntry = SolatEntry(
        date: Calendar.current.date(from: DateComponents(year: 2022, month: 2, day: 12))!,
        city: "Алматы",
        dateByHijrah: "10 Раджаб 1443",
        type: .asr,
        times: Times(date: "", fadjr: "06:35", sunrise: "07:52", dhuhr: "13:09", asr: "16:38", maghrib: "18:22", isha: "19:38")
    )
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

enum AzanType : String {
    case fadjr = "Фаджр", sunrise = "Восход", dhuhr = "Зухр", asr = "Аср", maghrib = "Магриб", isha = "Иша"
}

fileprivate extension String {
    func toDate() -> Date {
        let timeParts = split(separator: ":")
        let hour = Int(timeParts[0])!
        let minute = Int(timeParts[1])!
        
        return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!
    }
}
