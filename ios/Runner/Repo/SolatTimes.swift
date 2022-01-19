//
//  SolatRepo.swift
//  Runner
//
//  Created by Yerzhan Tulepov on 19.01.2022.
//

struct SolatTimes {

    static func getForToday() async throws -> Times? {
        let format = DateFormatter()
        format.locale = Locale(identifier: "ru")
        format.dateFormat = "dd-MM-yyyy"
        let today = format.string(from: Date())
        
        if let times = try Database().find(on: today) {
            return times
//            return Times(date: "19-01-2022", fadjr: "22:22", sunrise: "22:22", dhuhr: "22:22", asr: "22:22", maghrib: "22:22", isha: "23:18")
        }
        
        if let times = try await refreshTimesIfCityIsSet(today: today) {
            return times
        }
        
        return nil
    }
    
    private static func refreshTimesIfCityIsSet(today: String) async throws -> Times? {
        if let city = Settings.getCity() {
            let latitude = Settings.getLatitude()!
            let longitude = Settings.getLongitude()!
            try await refresh(city: city, latitude: latitude, longitude: longitude)
            return try Database().find(on: today)
        } else {
            return nil
        }
    }
    
    static func refresh(city: String, latitude: String, longitude: String) async throws {
        let times = try await getTimes(latitude: latitude, longitude: longitude)
        
        Settings.removeCity()
        
        try Database().replaceAll(by: times)
        
        Settings.setLatitude(to: latitude)
        Settings.setLongitude(to: longitude)
        Settings.setCity(name: city)
    }
    
    private static func getTimes(latitude: String, longitude: String) async throws -> [Times] {
        let result = try await MuftiyatService.getTimes(latitude: latitude, longitude: longitude)
        
        guard result.success else {
            throw Err.getTimesRequestFailed
        }
        
        return result.result.map { t in
            Times(date: t.date, fadjr: t.Fajr, sunrise: t.Sunrise, dhuhr: t.Dhuhr, asr: t.Asr, maghrib: t.Maghrib, isha: t.Isha)
        }
    }
    
    static func getHijrahDate() async throws -> String {
        if Settings.getRequestHidjrahDateFromServer() {
            return try await AzanService.getCurrentDateByHijrah()
        } else {
            return getCurrentHidrahDate()
        }
    }
    
    enum Err : Error {
        case getTimesRequestFailed
    }
}
