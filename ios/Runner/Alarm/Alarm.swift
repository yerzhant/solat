//
//  Alarm.swift
//  Runner
//
//  Created by Yerzhan Tulepov on 19.01.2022.
//

import BackgroundTasks

enum AzanType : Int {
    case fadjr = 1, sunrise, dhuhr, asr, maghrib, isha
}

struct AlarmService {
    
    private static let taskId = "kz.azan.solat.refresh"
    
    static func initialize() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskId, using: nil) { task in
            self.handleRefresh(task: task as! BGAppRefreshTask)
        }
        
        wakeMeUp()
        rescheduleNotifications()
    }
    
    private static func wakeMeUp() {
        let request = BGAppRefreshTaskRequest(identifier: taskId)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 3 * 3600)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Alarm rescheduling failed: \(error)")
        }
    }
    
    private static func handleRefresh(task: BGAppRefreshTask) {
        wakeMeUp()
        rescheduleNotifications()
        task.setTaskCompleted(success: true)
    }
    
    static func rescheduleNotifications() {
        NotificationService.removeAllPending()
        
        Task {
            let times = try await SolatTimes.getForToday()
            
            guard times != nil else { return }
            
            if Settings.getAzanFlag(type: .fadjr) {
                NotificationService.schedule(type: .fadjr, time: times!.fadjr)
            }
            
            if Settings.getAzanFlag(type: .sunrise) {
                NotificationService.schedule(type: .sunrise, time: times!.sunrise)
            }
            
            if Settings.getAzanFlag(type: .dhuhr) {
                NotificationService.schedule(type: .dhuhr, time: times!.dhuhr)
            }
            
            if Settings.getAzanFlag(type: .asr) {
                NotificationService.schedule(type: .asr, time: times!.asr)
            }
            
            if Settings.getAzanFlag(type: .maghrib) {
                NotificationService.schedule(type: .maghrib, time: times!.maghrib)
            }
            
            if Settings.getAzanFlag(type: .isha) {
                NotificationService.schedule(type: .isha, time: times!.isha)
            }
        }
    }
}
