//
//  CountdownInterfaceController.swift
//  TemWatchApp Extension
//
//  Created by shilpa on 10/06/20.
//

import WatchKit
import Foundation


class CountdownInterfaceController: WKInterfaceController {

    // MARK: IBOutlets
    @IBOutlet weak var timerLabel: WKInterfaceLabel!
    @IBOutlet weak var activityIndicatorImage: WKInterfaceImage!
    @IBOutlet weak var honeyCombView: WKInterfaceImage!
    
    // MARK: Properties
    var timerValue = 3
    var timer: Timer?
    var contextDict: [String: Any]?
    private var selectedActivity = ActivityData()
    private var initialDate = Date()
    
    // MARK: Life Cycle
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        NotificationCenter.default.addObserver(self, selector: #selector(selectro), name: Notification.Name("willEnterForeground"), object: nil)
        // Configure interface objects here.
        self.timerLabel.setText("3")
        if let context = context as? [String: Any] {
            self.contextDict = context
            if let activityInfo = context["selectedActivity"] as? ActivityData {
                selectedActivity = activityInfo
            }
        }
        self.createCountdownTimer()
        
    }
    
    @objc func selectro() {
        /*let difference = Date().timeIntervalSince(initialDate)
        if difference > 4 {
            self.showLoader()
            //on activation of this screen, push to activity screen
            self.timer?.invalidate()
            self.timer = nil
            let date = Calendar.current.date(byAdding: .second, value: 4, to: initialDate) ?? Date()
            self.contextDict?["activityProgressData"] = self.getActivityProgressObject(date: date)
            guard let dict = self.contextDict else {return}
            DispatchQueue.main.async {
                WKInterfaceController.reloadRootPageControllers(withNames: ["WActivityActionsInterfaceController", "WInProgressActivityVC", "PlayingViewInterfaceController"], contexts: [[:] as AnyObject, dict], orientation: .horizontal, pageIndex: 1)
            }
        } */
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        print("will activate called")
        //check the difference between current date and timer start date
        let difference = Date().timeIntervalSince(initialDate)
        if difference > 4 {
            print("This is now called")
            self.showLoader()
            //on activation of this screen, push to activity screen
            self.timer?.invalidate()
            self.timer = nil
            let date = Calendar.current.date(byAdding: .second, value: 4, to: initialDate) ?? Date()
            self.contextDict?["activityProgressData"] = self.getActivityProgressObject(date: date)
            guard let dict = self.contextDict else {return}
            WKInterfaceController.reloadRootPageControllers(withNames: ["WActivityActionsInterfaceController", "WInProgressActivityVC", "PlayingViewInterfaceController"], contexts: [[:] as AnyObject, dict], orientation: .horizontal, pageIndex: 1)
        }
    }
    
    

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        print("did deactiavte is called")
    }

    // MARK: Helpers
    private func showLoader() {
        DispatchQueue.main.async {
            self.timerLabel.setHidden(true)
            self.honeyCombView.setHidden(true)
            self.activityIndicatorImage.setHidden(false)
            self.activityIndicatorImage.setImageNamed("Activity")
            self.activityIndicatorImage.startAnimatingWithImages(in: NSRange(location: 0,
                                                                        length: 30), duration: 5, repeatCount: 0)
        }
    }
    
    private func createCountdownTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCalled), userInfo: nil, repeats: true)
    }
    
    @objc func timerCalled() {
        DispatchQueue.main.async {
            if self.timerValue <= 0 {
                print("this timer is called")
                self.timer?.invalidate()
                self.timer = nil
                Defaults.shared.set(value: true, forKey: .isActivityWatchApp)
                self.contextDict?["activityProgressData"] = self.getActivityProgressObject()
                guard let dict = self.contextDict else {return}
                WKInterfaceController.reloadRootPageControllers(withNames: ["WActivityActionsInterfaceController", "WInProgressActivityVC", "PlayingViewInterfaceController"], contexts: [[:] as AnyObject, dict], orientation: .horizontal, pageIndex: 1)
                return
            }
            self.timerValue -= 1
            if self.timerValue == 0 {
                self.timerLabel.setText("GO!")
            } else {
                self.timerLabel.setText("\(self.timerValue)")
            }
        }
    }
    
    /// set the activity progress object data
    private func getActivityProgressObject(date: Date? = Date()) -> ActivityProgressData {
        let objActivityProgressData:ActivityProgressData = ActivityProgressData()
        objActivityProgressData.activity = self.selectedActivity
        objActivityProgressData.createdAt = date!
        objActivityProgressData.elapsed = 0
        objActivityProgressData.startTime = 0
        let progressDataToSend = objActivityProgressData
        progressDataToSend.startTime = date!.timeIntervalSinceReferenceDate
        progressDataToSend.isPlaying = true
        let data =  try! JSONEncoder().encode(objActivityProgressData)
        let userActivityData = try! JSONEncoder().encode(objActivityProgressData.activity)
        //in watch app
        Defaults.shared.set(value: data, forKey: .sharedActivityInProgress)
        let infoDictToPass: [String: Any] = [MessageKeys.inProgressActivityData: data,
                                             "request": MessageKeys.createdNewActivityOnWatch,
                                             MessageKeys.userActivityData: userActivityData]
        WatchKitConnection.shared.updateApplicationContext(context: infoDictToPass)
        return objActivityProgressData
    }
}
