//
//  Settings.swift
//  WidgetsExtension
//
//  Created by Yerzhan Tulepov on 12.02.2022.
//

import Foundation

struct Settings {
    private static let city = "city"
    private static let requestHidjrahDateFromServer = "request-hijrah-date-from-server"
    
    private static let settings = UserDefaults(suiteName: appGroup)
    
    static func getCity() -> String? {
        settings?.string(forKey: city)
    }
    
    static func getRequestHidjrahDateFromServer() -> Bool {
        settings?.bool(forKey: requestHidjrahDateFromServer) ?? false
    }
}
