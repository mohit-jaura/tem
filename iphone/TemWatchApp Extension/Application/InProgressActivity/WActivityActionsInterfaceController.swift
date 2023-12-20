//
//  WActivityActionsInterfaceController.swift
//  TemWatchApp Extension
//
//  Created by shilpa on 10/06/20.
//

import WatchKit
import Foundation


class WActivityActionsInterfaceController: WKInterfaceController {

    // MARK: Properties
    let playIconName = "play"
    let pauseIconName = "pauseact"
    
    // MARK: IBOutlets
    @IBOutlet weak var buttonsGroup: WKInterfaceGroup!
    @IBOutlet weak var activityIndicatorImage: WKInterfaceImage!
    @IBOutlet weak var activityIndicatorGroup: WKInterfaceGroup!
    @IBOutlet weak var addNewGroup: WKInterfaceGroup!
    @IBOutlet weak var addNewButton: WKInterfaceButton!
    @IBOutlet weak var pausePlayGroup: WKInterfaceGroup!
    @IBOutlet weak var pauseButton: WKInterfaceButton!
    @IBOutlet weak var stopGroup: WKInterfaceGroup!
    @IBOutlet weak var stopButton: WKInterfaceButton!
    
    // MARK: IBActions
    @IBAction func pausePlayTapped() {
        NotificationCenter.default.post(name: Notification.Name.watchActivityPausedTapped, object: nil)
    }
    
    @IBAction func addNewActivityTapped() {
        NotificationCenter.default.post(name: Notification.Name.watchActivityAddNewButtonTapped, object: nil)
        self.pauseButton.setBackgroundImageNamed(playIconName)
    }
    
    @IBAction func stopButtonTapped() {
        NotificationCenter.default.post(name: Notification.Name.watchActivityStopButtonTapped, object: nil, userInfo: nil)
        self.showStopActivityAlert()
    }
    
    // MARK: View Life Cycle
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        self.addNotificationObservers()
        self.configureSize()
        self.configureInitialDisplay()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.setAddButtonDisplay()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        self.activityIndicatorImage.stopAnimating()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Helpers
    private func addNotificationObservers() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(addNewActivityFromInProgressScreen(notification:)), name: Notification.Name.watchActivityAddNewActivityFromInProgressScreen, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(activityStateChanged(notification:)), name: Notification.Name.watchActivityStateChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(errorInCompleteActivityApi(notification:)), name: Notification.Name.watchErrorInCompleteActivity, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(completeActivityApiSucceeded), name: Notification.Name.watchCompleteActivityApiSucceeded, object: nil)
    }
    
    private func configureInitialDisplay() {
        if let data = Defaults.shared.get(forKey: .sharedActivityInProgress) {
            //there is already an activity in running state
            do {
                guard let data = data as? Data else {return}
                let runActData = try JSONDecoder().decode(ActivityProgressData.self, from: data)
                if let isPlaying = runActData.isPlaying {
                    self.pauseButton.setBackgroundImageNamed(isPlaying ? pauseIconName : playIconName)
                }
                self.setTitle(runActData.activity?.name ?? nil)
            } catch(let error) {
                print("error: \(error)")
            }
        }
    }
    
    /// enable the add new button if the less than 3 activities are created
    private func setAddButtonDisplay() {
        if let _ = Defaults.shared.get(forKey: .sharedActivityInProgress),
            let activities = CombinedActivity.currentActivityInfo(),
            activities.count == 2 { //maximum of 3 combined activities can be performed at a time.
            self.addNewButton.setEnabled(false)
        }
    }
    
    private func configureSize() {
        let resol = WKInterfaceDevice.currentResolution()
        switch resol {
        case .Watch40mm, .Watch38mm:
            self.set40MMWatch()
        default:
            
            break
        }
    }
    
    private func set40MMWatch() {
        let height: CGFloat = 60
        self.addNewButton.setHeight(height)
        self.addNewButton.setWidth(height)
        self.pauseButton.setHeight(height)
        self.pauseButton.setWidth(height)
        self.stopButton.setHeight(height)
        self.stopButton.setWidth(height)
        self.addNewGroup.setHeight(height)
        self.pausePlayGroup.setHeight(height)
        self.stopGroup.setHeight(height)
    }
    
    /// start loader on screen
    private func startLoader() {
        self.buttonsGroup.setHidden(true)
        self.activityIndicatorGroup.setHidden(false)
        activityIndicatorImage.setImageNamed("Activity")
        activityIndicatorImage.startAnimatingWithImages(in: NSRange(location: 0,
                                                                        length: 30), duration: 5, repeatCount: 0)
    }
    
    private func hideLoader() {
        self.buttonsGroup.setHidden(false)
        self.activityIndicatorGroup.setHidden(true)
        self.activityIndicatorImage.stopAnimating()
    }
    
    private func showStopActivityAlert() {
        let startAction = WKAlertAction(title: "YES", style: WKAlertActionStyle.default) {
            print("Stop Activity")
            self.startLoader()
            NotificationCenter.default.post(name: Notification.Name.watchStopActivity, object: nil)
        }
        
        let noAction = WKAlertAction(title: "NO", style: WKAlertActionStyle.destructive) {
            print("Don't Stop Activity")
            NotificationCenter.default.post(name: Notification.Name.watchDontStopActivity, object: nil)
        }
        presentAlert(withTitle: "Stop Activity", message: "Are you sure you want to stop the current activity?", preferredStyle: WKAlertControllerStyle.alert, actions:[startAction,noAction])
    }
    
    // MARK: Notification selectors
    @objc func addNewActivityFromInProgressScreen(notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any] {
            DispatchQueue.main.async {
                self.presentController(withName: "WChooseActivityVC", context: userInfo)
            }
        }
    }
    
    @objc func activityStateChanged(notification: Notification) {
        if let userInfo = notification.userInfo,
            let state = userInfo["isPlaying"] as? Bool {
            self.pauseButton.setBackgroundImageNamed(state ? pauseIconName : playIconName)
        }
    }
    
    @objc func errorInCompleteActivityApi(notification: Notification) {
        if let userInfo = notification.userInfo,
            let error = userInfo["error"] as? String {
            self.hideLoader()
            self.showLoginAlert(error, isUserLoggedIn: true)
        }
    }
    
    @objc func completeActivityApiSucceeded() {
        self.hideLoader()
    }
}
