//
//  ActivityCountdownViewController.swift
//  TemApp
//
//  Created by shilpa on 01/07/20.
//

import UIKit

class ActivityCountdownViewController: DIBaseController {

    // MARK: IBOutlets
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var honeyCombImageView: UIImageView!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var activityLogoView: UIView!
    @IBOutlet weak var activityIconImageView: UIImageView!
    @IBOutlet weak var navBar: UIView!
    
    // MARK: Properties
    var timerValue = 3
    var selectedActivity = ActivityData()
    var navigationBar: NavigationBar?
    var isTabbarChild = false
    var t: RepeatingTimer?
    var counter = 1
    var initialDate = Date()
    var activityProgressObject = ActivityProgressData()
    var activityId: Int?
    var categoryType: ActivityCategoryType.RawValue = ActivityCategoryType.mentalStrength.rawValue
    var screenFrom = Constant.ScreenFrom.activity
    var eventID  = ""
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let activityType = self.selectedActivity.activityType,
            let type = ActivityMetric(rawValue: activityType),
            type == .distance {
            appDelegate.initalizeLocation()
            appDelegate.startLocation()
        }
    
   //     self.setDisplay()
    //    self.countdownLabel.text = "\(timerValue)"
    //    self.createCountdownTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let date = Calendar.current.date(byAdding: .second, value: 1, to: self.initialDate) ?? Date()
        self.activityProgressObject = self.getActivityProgressObject(date: date)
        self.navigateToActivityProgressScreen()
    }

    // MARK: Helpers
    private func setNavigationBar() {
        if self.isTabbarChild {
            self.navigationBar = configureNavigtion(onView: navBar, title: "", leftButtonAction: .menuWhite)
        } else {
            self.navigationBar = configureNavigtion(onView: navBar, title: "", leftButtonAction: .backWhite)
        }
    }
    
    private func setDisplay() {
        self.setNavigationBar()
        if let imageUrl = URL(string: self.selectedActivity.image ?? "") {
            self.activityIconImageView.kf.setImage(with: imageUrl, placeholder: #imageLiteral(resourceName: "activity"), options: nil, progressBlock: nil) { (_) in
                self.activityIconImageView.setImageColor(color: UIColor.white)
            }
        }
        self.activityIconImageView.setImageColor(color: UIColor.white)
    }
    
    private func rotateView() {
        DispatchQueue.main.async {
            UIView.transition(with: self.backView, duration: 1.0, options: [.transitionFlipFromLeft], animations: {
            }) { (_) in
            }
        }
    }

    private func createCountdownTimer() {
        t = RepeatingTimer(timeInterval: 1)
        t?.eventHandler = {[weak self] in
            print("Repeating Timer Fired")
            self?.timerCalled()
        }
        t?.resume()
    }
    
    @objc func timerCalled() {
        if timerValue <= 0 {
            DispatchQueue.main.async {
                self.t?.suspend()
//                let date = Calendar.current.date(byAdding: .second, value: 4, to: self.initialDate) ?? Date()
//                self.activityProgressObject = self.getActivityProgressObject(date: date)
           //     self.navigateToActivityProgressScreen()
            }
            return
        }
        self.rotateView()
        timerValue -= 1
        if timerValue == 0 {
            DispatchQueue.main.async {
                self.countdownLabel.isHidden = true
                self.activityLogoView.isHidden = false
            }
        } else {
            DispatchQueue.main.async {
                self.countdownLabel.text = "\(self.timerValue)"
            }
        }
    }
    
    /// set the activity progress object data
    private func getActivityProgressObject(date: Date? = Date()) -> ActivityProgressData {
        let objActivityProgressData:ActivityProgressData = ActivityProgressData()
        objActivityProgressData.activity = self.selectedActivity
        objActivityProgressData.createdAt = date ?? Date()
        objActivityProgressData.elapsed = 0
        objActivityProgressData.startTime = 0
        do {
            let progressDataToSend = objActivityProgressData
            progressDataToSend.startTime = date?.timeIntervalSinceReferenceDate//Date().timeIntervalSinceReferenceDate
            progressDataToSend.isPlaying = true
            objActivityProgressData.saveEncodedInformation()
            let data =  try JSONEncoder().encode(objActivityProgressData)
            let userActivityData = try JSONEncoder().encode(objActivityProgressData.activity)
            let infoDictToPass: [String: Any] = [MessageKeys.inProgressActivityData: data,
                                                 "request": MessageKeys.createdNewActivityOnPhone,
                                                 MessageKeys.userActivityData: userActivityData]
            Watch_iOS_SessionManager.shared.updateApplicationContext(data: infoDictToPass)
        } catch {
            
        }
        return objActivityProgressData
    }
    
    // MARK: Navigation
    private func navigateToActivityProgressScreen(date: Date? = Date()) {
        Defaults.shared.set(value: true, forKey: .isActivity)
        DispatchQueue.main.async {
        let activityProgressController: ActivityProgressController = UIStoryboard(storyboard: .activity).initVC()
        activityProgressController.activityData = self.activityProgressObject//getActivityProgressObject()
        activityProgressController.isTabbarChild = self.isTabbarChild
            activityProgressController.selctedActivityId = self.activityId
            activityProgressController.categoryType = self.categoryType
            activityProgressController.screenFrom = self.screenFrom
            activityProgressController.eventID = self.eventID
            if self.isTabbarChild {
                self.navigationController?.viewControllers = [activityProgressController]
            } else if self.screenFrom == .event {
             //   DispatchQueue.main.async {
                    self.navigationController?.pushViewController(activityProgressController, animated: true)
            //    }
            } else {
                //page child
                if let firstController = self.navigationController?.viewControllers.first {
                    self.navigationController?.viewControllers = [firstController, activityProgressController]
                }
            }
        }
    }
}

class RepeatingTimer {

    let timeInterval: TimeInterval
    
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now() + self.timeInterval, repeating: self.timeInterval)
        t.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return t
    }()

    var eventHandler: (() -> Void)?

    private enum State {
        case suspended
        case resumed
    }

    private var state: State = .suspended

    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        resume()
        eventHandler = nil
    }

    func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }

    func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }
}
