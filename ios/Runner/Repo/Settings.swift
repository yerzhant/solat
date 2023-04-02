//
//  Settings.swift
//  Runner
//
//  Created by Yerzhan Tulepov on 19.01.2022.
//

import Foundation

struct Settings {
    private static let city = "city"
    private static let latitude = "latitude"
    private static let longitude = "longitude"
    private static let timeZone = "time-zone"
    private static let requestHidjrahDateFromServer = "request-hijrah-date-from-server"
    private static let azanTypePrefix = "azan-type-"
    
    private static let settings = UserDefaults(suiteName: appGroup)
    
    static func getCity() -> String? {
        settings?.string(forKey: city)
    }
    
    static func setCity(name: String) {
        settings?.set(name, forKey: city)
    }
    
    static func removeCity() {
        settings?.removeObject(forKey: city)
    }
    
    static func getLatitude() -> String? {
        settings?.string(forKey: latitude)
    }
    
    static func setLatitude(to value: String) {
        settings?.set(value, forKey: latitude)
    }
    
    static func getLongitude() -> String? {
        settings?.string(forKey: longitude)
    }
    
    static func setLongitude(to value: String) {
        settings?.set(value, forKey: longitude)
    }
    
    static func getTimeZone() -> Int? {
        settings?.integer(forKey: timeZone)
    }
    
    static func setTimeZone(to value: Int) {
        settings?.set(value, forKey: timeZone)
    }
    
    static func getRequestHidjrahDateFromServer() -> Bool {
        settings?.bool(forKey: requestHidjrahDateFromServer) ?? false
    }
    
    static func setRequestHidrahDateFromServer(to value: Bool) {
        settings?.set(value, forKey: requestHidjrahDateFromServer)
    }
    
    static func getAzanFlag(type: AzanType) -> Bool {
        settings?.bool(forKey: azanTypePrefix + String(type.rawValue)) ?? false
    }
    
    static func setAzanFlag(to value: Bool, type: AzanType) {
        settings?.set(value, forKey: azanTypePrefix + String(type.rawValue))
    }
}
