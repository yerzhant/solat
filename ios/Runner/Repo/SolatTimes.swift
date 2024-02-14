//
//  SolatRepo.swift
//  Runner
//
//  Created by Yerzhan Tulepov on 19.01.2022.
//

import Foundation

struct SolatTimes {

    static func getForToday() -> Times? {
        if Settings.getCity() == nil { return nil }

        func offsetOf(min: Int) -> NSMutableDictionary {
            [
                "fajr": 0,
                "sunrise": -min,
                "dhuhr": min,
                "asr": min,
                "sunset": 0,
                "maghrib": min,
                "isha": 0,
            ]
        }

        let prayTime = PrayTime()
        prayTime.setCalcMethod(Int32(prayTime.isna))
        prayTime.setAsrMethod(Int32(prayTime.hanafi))
        prayTime.setHighLatsMethod(Int32(prayTime.angleBased))

        let now = Date()
        let latitude = Double(Settings.getLatitude()!)!
        let longitude = Double(Settings.getLongitude()!)!
        let timeZoneSwitchDate = Calendar.current.date(from: DateComponents(year: 2024, month: 3, day: 1))!
        let timeZone = if now < timeZoneSwitchDate { Double(Settings.getTimeZone()!) } else { 5.0 }

        prayTime.tune(offsetOf(min: latitude < 48 ? 3 : 5))

        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month, .day], from: now)
        let times = prayTime.getPrayerTimes(comps, andLatitude: latitude, andLongitude: longitude, andtimeZone: timeZone)!

        return Times(
            fadjr: String(describing: times[0]),
            sunrise: String(describing: times[1]),
            dhuhr: String(describing: times[2]),
            asr: String(describing: times[3]),
            maghrib: String(describing: times[5]),
            isha: String(describing: times[6])
        )
    }
    
    static func saveCityParams(city: String, latitude: String, longitude: String, timeZone: Int) {
        Settings.removeCity()
        
        Settings.setLatitude(to: latitude)
        Settings.setLongitude(to: longitude)
        Settings.setTimeZone(to: timeZone)
        Settings.setCity(name: city)
    }
    
    static func getHijrahDate() async throws -> String {
        if Settings.getRequestHidjrahDateFromServer() {
            return try await AzanService.getCurrentDateByHijrah()
        } else {
            return getCurrentHijrahDate()
        }
    }
}
