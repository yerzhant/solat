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
        
        reschedule()
        rescheduleNotifications()
    }
    
    private static func reschedule() {
        let request = BGAppRefreshTaskRequest(identifier: taskId)
        
        var when = DateComponents()
        when.hour = 0
        when.minute = 5
        
        request.earliestBeginDate = when.date
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Alarm rescheduling failed: \(error)")
        }
    }
    
    private static func handleRefresh(task: BGAppRefreshTask) {
        reschedule()
        rescheduleNotifications()
        task.setTaskCompleted(success: true)
    }
    
    private static func rescheduleNotifications() {
        Task {
            let times = try await SolatTimes.getForToday()
            
            guard times != nil else { return }
            
            NotificationService.schedule(type: .fadjr, time: times!.fadjr)
            NotificationService.schedule(type: .sunrise, time: times!.sunrise)
            NotificationService.schedule(type: .dhuhr, time: times!.dhuhr)
            NotificationService.schedule(type: .asr, time: times!.asr)
            NotificationService.schedule(type: .maghrib, time: times!.maghrib)
            NotificationService.schedule(type: .isha, time: times!.isha)
        }
    }
}
