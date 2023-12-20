//
//  BackgroundTask.swift
//

import UIKit

class BackgroundTask {
    
    var taskInvalid = UIBackgroundTaskIdentifier.invalid
    var tasking = false
    var timeOut = false
    
    func registerBackgroundTask() {
        tasking = true
        taskInvalid = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            [unowned self] in
            self.timeOut = true
            self.endBackgroundTask()
        })
        appDelegate.stopLocation()
        print("register backgroundtask")
    }
    
    func endBackgroundTask() {
        if timeOut {
            appDelegate.startLocation()
        }
        tasking = false
        UIApplication.shared.endBackgroundTask(taskInvalid)
        taskInvalid = UIBackgroundTaskIdentifier.invalid
        print("end backgroundtask")
    }
    
}
