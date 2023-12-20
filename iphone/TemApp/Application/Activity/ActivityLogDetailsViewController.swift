//
//  ActivityLogDetailsViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 02/02/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

class ActivityLogDetailsViewController: DIBaseController {

    var activityLog:ActivitiesLog?
    var rightInset: CGFloat = 7
    var index = 0 // to keep track the activity to be shown from an array of acttivityLog
    
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var summaryDistanceLabel: UILabel!
    @IBOutlet weak var ratedLabel: UILabel!
    @IBOutlet weak var activityNameLAbel: UILabel!
    @IBOutlet weak var totalTimeValueLabel: UILabel!
    @IBOutlet weak var newsFeedLogoImageView: UIImageView!
    @IBOutlet var newsFeedView: UIView!
    @IBOutlet weak var activityNewsNameLabel: UILabel!
    @IBOutlet weak var caloriesValueLabel: UILabel!
    @IBOutlet weak var distanceTitleLabel: UILabel!
    @IBOutlet weak var distanceValueLabel: UILabel!
    @IBOutlet weak var distanceNewsFeedImageView: UIImageView!
    @IBOutlet weak var activityLabelTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var editButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
    override func viewWillAppear(_ animated: Bool) {
        getActivityLog()
    }
    // MARK: Helper Function
    func configureViews(){
        if activityLog?.isBinary == true{
            editButton.isHidden = true
        } else{
            editButton.isHidden = false
        }
        activityNameLAbel.text = (activityLog?.activityName ?? "").capitalized
        if let cal = activityLog?.calories , let duration = activityLog?.duration, let distance = activityLog?.distance{
            
            let timeConverted = Utility.shared.secondsToHoursMinutesSeconds(seconds: Int(duration))
            
            let displayTime = Utility.shared.formattedTimeWithLeadingZeros(hours: timeConverted.hours, minutes: timeConverted.minutes, seconds: timeConverted.seconds)
            
            
            caloriesLabel.text = "\(cal.rounded(toPlaces: 2))"
            durationLabel.text = "\(displayTime)"
            summaryDistanceLabel.text = "\(distance)"
        }
        if let rating = activityLog?.rating{
            ratedLabel.text = "\(rating)/5"
        }
        
    }
    private func getActivityLog() {
        if self.isConnectedToNetwork() {
            self.showLoader()
            DIWebLayerReportsAPI().getActivitiesLog { response in
                self.hideLoader()
                self.activityLog = response[self.index]
                self.configureViews()
            } failure: { error in
                self.hideLoader()
                print("error\(error)")
            }
        }
        else{
            self.showAlert(message: AppMessages.AlertTitles.noInternet)
        }
    }
    // MARK: IBAction
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editTapped(_ sender: UIButton) {
        let editActivityVC: ActivityEditController = UIStoryboard(storyboard: .activityedit).initVC()
        editActivityVC.isFromActivityLog = true
        editActivityVC.categoryType = Int(activityLog?.categoryType ?? "0") ?? 0
        editActivityVC.activityLogData = ActivityLogData(duration: activityLog?.duration , distance: activityLog?.distance, name: activityLog?.activityName,activityTypeId:activityLog?.activityId, activityType: activityLog?.activityType, calories: activityLog?.calories, id: activityLog?.id, rating: activityLog?.rating)
        self.navigationController?.pushViewController(editActivityVC, animated: true)
    }
    
    @IBAction func shareTapped(_ sender: UIButton) {
        self.shareActivity()
    }
    
    private func shareActivity() {
        self.setNewsFeedData()
        if let screenshot = self.newsFeedView.screenshot() { // get screenshot
            let image = resizedImage(at: screenshot, for: CGSize(width:Constant.ScreenSize.IPHONE_MAX_WIDTH, height: screenshot.size.height+(screenshot.size.height*0.10)))
            let createPostVC: CreatePostViewController = UIStoryboard(storyboard: .post).initVC()
            createPostVC.type = .activity
            createPostVC.isFromActivityLog = true
            createPostVC.screenshot = UIScreen.main.bounds.width < Constant.ScreenSize.IPHONE_MAX_WIDTH ? image : screenshot
            createPostVC.isComingFromActivity = true
            createPostVC.isFromDashBoard = true
//            self.isFromDashBoard = false
            self.navigationController?.pushViewController(createPostVC, animated: true)
        }
    }
    func resizedImage(at image: UIImage, for size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (_) in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    private func setNewsFeedData() {
        self.activityNewsNameLabel.text = activityLog?.activityName
  
        self.totalTimeValueLabel.text = durationLabel.text ?? "" //"\(activityLog?.duration.rounded(toPlaces: 2) ?? 0)"

        let distance: Int? = Int(activityLog?.distance ?? 0.0)
        
        if distance == 0{
            self.distanceValueLabel.isHidden = true
            distanceNewsFeedImageView.isHidden = true

            self.distanceTitleLabel.isHidden = true
            self.newsFeedLogoImageView.isHidden = true
        }else{
            self.distanceValueLabel.text = "\(activityLog?.distance.rounded(toPlaces: 2) ?? 0)"
            self.newsFeedLogoImageView.isHidden = true
            self.distanceTitleLabel.isHidden = false
        }
        
        self.caloriesValueLabel.text = "\(activityLog?.calories.rounded(toPlaces: 2) ?? 0)"
        
    }
}

