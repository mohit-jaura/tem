//
//  CreateEventActivityController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 29/12/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import SSNeumorphicView


struct CreateEventActivity{
    var activityAddOn:[[String:Any]] = []
    var checkList:[Rounds] = []
    
}

class CreateEventActivityController: DIBaseController {
    
    var isEditEvent = false
    var eventID = ""
    var eventDetail : EventDetail?
    var saveEventDetails : SaveEventDetails?
    var activityDataModal:[ActivityAddOns]?
    var createActivity : CreateEventActivity?
    // MARK: IBOutlets
    @IBOutlet  var BgShadowViews: [SSNeumorphicView]!{
        didSet{
            for view in BgShadowViews{
                view.setShadow(view: view, shadowType: .outerShadow, mainColor: UIColor.newAppThemeColor.cgColor)
            }
        }
    }
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var checklistTogleImageView: UIImageView!
    @IBOutlet weak var activityToggleImageView: UIImageView!
    @IBOutlet weak var checklistToggleShadowView: SSNeumorphicView!{
        didSet{
            setToggleShadow(view: checklistToggleShadowView)
        }
    }
    @IBOutlet weak var activityToggleShadowView: SSNeumorphicView!{
        didSet{
            setToggleShadow(view: activityToggleShadowView)
        }
    }
    
    
    var checkList = [Rounds]()
    var fetchedRounds:[EventRounds]?
    var addFetchedRounds = true
    var addFetchedMedia = true
    
    // MARK: App life Cycle....
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.endEditing(true)
        if isEditEvent{
            submitButton.setTitle("UPDATE", for: .normal)
        }else{
            submitButton.setTitle("SAVE", for: .normal)
        }
        self.navigationController?.navigationBar.isHidden = true
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide
        if  activityDataModal?.count != 0 && activityDataModal != nil {
            activityToggleImageView.image = UIImage(named: "Oval Copy 3")
        }else{
            activityToggleImageView.image = UIImage(named: "")
        }
        if checkList.count != 0{
            checklistTogleImageView.image = UIImage(named: "Oval Copy 3")
        }else{
            checklistTogleImageView.image = UIImage(named: "")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.previousNextDisplayMode = .default
    }
    
    private func configureViewForEditEvent() {
        if let event = self.eventDetail {
            activityDataModal = event.activityAddOn
        }
    }
    
    private func initActivitiesData() {
        decodeActivities()
        checkList = createActivity?.checkList ?? []
    }

    private func decodeActivities() {
        guard let activityData = self.createActivity else { return }
        DIWebLayer().decodeFrom(data: activityData.activityAddOn, success: { (result) in
            self.activityDataModal = result
        }, failure: { (error) in
            debugPrint(error.title)
        })
    }
    
    func setToggleShadow(view:SSNeumorphicView){
        view.viewDepthType = .innerShadow
        view.viewNeumorphicMainColor = UIColor.newAppThemeColor.cgColor
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = view.frame.height / 2
    }
    func initialize(){
        configureView()
    }
    
    func configureView(){
        if isEditEvent {
            configureViewForEditEvent()
            initActivitiesData()
        } else {
            initActivitiesData()
        }
    }
    
    // MARK: IBAction
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func checklistTapped(_ sender: UIButton) {
        let createRoundVC: RoundChecklistViewController = UIStoryboard(storyboard: .createevent).initVC()
        createRoundVC.delegate = self
        self.convertFetchedRoundsToCreatedRounds()
        createRoundVC.createdRounds = self.checkList
        createRoundVC.eventId = self.eventID
        self.navigationController?.pushViewController(createRoundVC, animated: true)
    }
    @IBAction func activityAdOnTapped(_ sender: UIButton) {
        let VC = loadVC(.ActivityAddOnListVC) as! ActivityAddOnListVC
        VC.getActivityAddOnData = {[weak self](activityArr) in
            self?.activityDataModal = activityArr
        }
        VC.activityAddOnsArr = activityDataModal
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    func editSuccessEvent() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.NotiName.editEvent), object: nil, userInfo: [Constant.NotiName.editEvent:eventDetail])
    }
    
    func convertFetchedRoundsToCreatedRounds(){
        if addFetchedRounds{
            fetchedRounds = self.eventDetail?.rounds ?? []
            if let fetchedRounds = fetchedRounds, fetchedRounds.count > 0{
                for fetchedRound in fetchedRounds {
                    var round = Rounds()
                    round.roundId = fetchedRound.id ?? nil
                    round.round_name = fetchedRound.roundName ?? ""
                    round.tasks = []
                    if let fetchedTasks = fetchedRound.tasks, fetchedTasks.count > 0{
                        for fetchedTask in fetchedTasks {
                            var task = Tasks()
                            task.task_name = fetchedTask.taskName ?? ""
                            task.taskId = fetchedTask.id ?? nil
                            task.file = fetchedTask.file ?? ""
                            task.fileType = fetchedTask.fileType ?? 0
                            round.tasks?.append(task)
                        }
                    }
                    checkList.append(round)
                }
            }
            addFetchedRounds = false
        }
    }
    
    func getEventParams(editMode: EditRecurringEventMode = .thisEvent) -> CreateEventActivity {
        var event = CreateEventActivity()
        event.activityAddOn  = ActivityAddOns.inDic(activityDataModal) ?? []
        if isEditEvent {
            convertFetchedRoundsToCreatedRounds()
        }
        event.checkList = checkList
        return event
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        let params = getEventParams()
        print(params)
        saveEventDetails?.saveActivity(data: params, isActivitiesEdited: true)
        self.navigationController?.popViewController(animated: true)
    }
    
}


extension CreateEventActivityController: RoundChecklistViewControllerDelegate{
    func passChecklistsModal(newCheckList: [Rounds]) {
        self.checkList = newCheckList
    }
}
