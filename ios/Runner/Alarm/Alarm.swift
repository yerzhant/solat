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
            
        }
        
        reschedule()
    }
    
    private static func reschedule() {
        let request = BGAppRefreshTaskRequest(identifier: taskId)
        
        var when = DateComponents()
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
        
        task.setTaskCompleted(success: true)
    }
}
