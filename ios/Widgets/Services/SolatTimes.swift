//
//  SolatTimes.swift
//  WidgetsExtension
//
//  Created by Yerzhan Tulepov on 12.02.2022.
//

import Foundation

struct SolatTimes {
    
    static func getForToday() async throws -> Times? {
        let format = DateFormatter()
        format.locale = Locale(identifier: "ru")
        format.dateFormat = "dd-MM-yyyy"
        let today = format.string(from: Date())
        
        if let times = try Database().find(on: today) {
            return times
//            return Times(date: "19-01-2022", fadjr: "12:22", sunrise: "12:22", dhuhr: "12:22", asr: "12:22", maghrib: "12:22", isha: "19:11")
        }
        
        return nil
    }
    
    static func getHijrahDate() async throws -> String {
        if Settings.getRequestHidjrahDateFromServer() {
            return try await AzanService.getCurrentDateByHijrah()
        } else {
            return getCurrentHijrahDate()
        }
    }
}
