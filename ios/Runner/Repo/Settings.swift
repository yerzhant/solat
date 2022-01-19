//
//  Settings.swift
//  Runner
//
//  Created by Yerzhan Tulepov on 19.01.2022.
//

struct Settings {
    private static let city = "city"
    private static let latitude = "latitude"
    private static let longitude = "longitude"
    private static let requestHidjrahDateFromServer = "request-hijrah-date-from-server"
    
    private static let settings = UserDefaults.standard
    
    static func getCity() -> String? {
        settings.string(forKey: city)
    }
    
    static func setCity(name: String) {
        settings.set(name, forKey: city)
    }
    
    static func removeCity() {
        settings.removeObject(forKey: city)
    }
    
    static func getLatitude() -> String? {
        settings.string(forKey: latitude)
    }
    
    static func setLatitude(to value: String) {
        settings.set(value, forKey: latitude)
    }
    
    static func getLongitude() -> String? {
        settings.string(forKey: longitude)
    }
    
    static func setLongitude(to value: String) {
        settings.set(value, forKey: longitude)
    }
    
    static func getRequestHidjrahDateFromServer() -> Bool {
        settings.bool(forKey: requestHidjrahDateFromServer)
    }
    
    static func setRequestHidrahDateFromServer(to value: Bool) {
        settings.set(value, forKey: requestHidjrahDateFromServer)
    }
}