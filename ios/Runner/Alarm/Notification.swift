//
//  Notification.swift
//  Runner
//
//  Created by Yerzhan Tulepov on 19.01.2022.
//

struct NotificationService {
    
    private static let center = UNUserNotificationCenter.current()
    
    static func initialize(app: AppDelegate) {
        requestAuthorization()
        center.delegate = app
    }
    
    private static func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound]) { _, error in
            if let error = error {
                print("User notification auth request error: \(error)")
            }
        }
    }
    
    static func schedule(type: AzanType, time: String) {
        let timeParts = time.trimmingCharacters(in: CharacterSet.whitespaces).split(separator: ":")
        let hour = Int(timeParts[0])!
        let minute = Int(timeParts[1])!
        
        let now = Date()
        
        guard now <= Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: now)! else { return }

        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            
            let content = UNMutableNotificationContent()
            content.body = time
            content.sound = UNNotificationSound.default
            switch type {
            case .fadjr:
                content.title = "Фаджр"
            case .sunrise:
                content.title = "Восход"
            case .dhuhr:
                content.title = "Зухр"
            case .asr:
                content.title = "Аср"
            case .maghrib:
                content.title = "Магриб"
            case .isha:
                content.title = "Иша"
            }
            
            var when = DateComponents()
            when.hour = hour
            when.minute = minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: when, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("Notification scheduling failed: \(error)")
                }
            }
        }
    }
}
