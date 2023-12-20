//
//  EventActivitiesVC.swift
//  TemApp
//
//  Created by PrabSharan on 05/08/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
import HealthKit

class EventActivitiesVC: DIBaseController {
    
    @IBOutlet weak var exitButOut: UIButton!
    // MARK: Properties
    var rightInset: CGFloat = 7
    //    var fitbitAuthHandler: FitbitAuthHandler? = nil
    var activityDates:[AccessTuple] = [AccessTuple]()
    var healthAppType:HealthAppType = .healthKit
    weak var timer: Timer?
    weak var distanceTimer : Timer?
    weak var caloriesTimer: Timer?
    private var startTime: Double = 0
    private var time: Double = 0
    private var elapsed: Double = 0
    private var isPlaying: Bool = false
    var count:Int = 0
    var writeDataCounter = 0
    var activityData:ActivityProgressData = ActivityProgressData()
    var startDate:Date?
    var totalTime:Double?
    var distance:Double = 0.0
    var totalSteps:Double = 0.0
    var totalCalories:Double = 0.0
    var totalDistance:Double = 0.0
    var tempDistance:Double = 0.0
    var timeIntervel:AccessTuple = (Date(),Date(),0)
    var isFromDashBoard:Bool = false
    var selctedActivityId: Int?
    var categoryType: ActivityCategoryType.RawValue = ActivityCategoryType.mentalStrength.rawValue
    var activityPausedDueToAlert = false
    private var activityTypesArray: [ActivityCategory]? //this will hold the list of activity types which the user can choose to create an additional activity
    private var additionalActivity: ActivityData?
    
    var activityPausedState: ActivityPauseState = .none
    private var newProgressIdFromServer: String?
    var isTabbarChild = false
    
    var navBar: NavigationBar?
    private var addedNewActivityOnWatch = false
    var stopAnimation: Bool = false
    private let playIconImage = UIImage(named: "play")
    private let pauseIconImage = UIImage(named: "pauseGreen")
    
    // this is being used in the in-progress mile calculation
    var singleMileCount: Int = 1
    var lastMileCount: Int = 0
    var lastMileCompletedTime: Double = 0
    var avgMile: Double = 0
    var isDistanceTypeActivity: Bool = true
    var totalDisplayedDistance: Double = 0
    var activitiesArray = [[String: Any]]()
    
    private var currentActivityId: String?
    private let viewBackgroundColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.59)
    
    // MARK: IBOutlets
    @IBOutlet weak var distanceView: UIView!
    @IBOutlet weak var metricValueLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var caloriesView: UIView!
    @IBOutlet weak var activityLabelTrailingConstraint: NSLayoutConstraint!
    
    // MARK: IBActions
      
    @IBAction func exitAction(_ sender: Any) {
        print("Exit")
    }
   

    var activityStartTime:String = ""
    override func viewDidLoad(){
        super.viewDidLoad()
    }
}
