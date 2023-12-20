//
//  ActivitySheet.swift
//  TemApp
//
//  Created by Harpreet_kaur on 22/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit

protocol ActivitySheetProtocol: AnyObject {
    func handleSelection(index:Int,type:SheetDataType)
    func handleSelection(indices: [Int], type: SheetDataType)
    func cancelSelection(type: SheetDataType)
    func didSelectRowWithValue(data: Any, type: SheetDataType)
}

extension ActivitySheetProtocol {
    func didSelectRowWithValue(data: Any, type: SheetDataType) {}
}

enum SheetDataType {
    case activity
    case metric
    case metricValue
    case duration
    case editEvent
    case deleteEvent
    case interests
    case groupVisibility
    case taggedList
    case additionalActivity
    case nutritionTrackingPercent
    case fundraisingDestination
    case searchCategory
    case recurrence
    case recurrenceFinish
    case eventVisibility
    case eventType
    case activitySelectionType
    case activityCategory
    case rateActivity
    case trackingNutrition
    case happinessSurvey
    case totalAssesment
    case fileType
    case signUpSheetType
    case startActivity
    case coachingTools
    case checkInFrequency
    case healthInfoType
}

class ActivitySheet: UIView {
    
    // MARK: Variables
    var itemArray = [String]()
    var indexSelected:IndexSelected? = nil
    var itemImageArray = [String]()
    var tap:UITapGestureRecognizer!
    var isImages:Bool = false
    var actionSheetArray:[Any] = [Any]()
    var type:SheetDataType = .activity
    var multipleSelectionOn = false
    weak var delegate:ActivitySheetProtocol?
    
    var selectedIndices: [Int]? //this will hold the row numbers which are selected, in case the multiple selection is on
    private var heightConstant: CGFloat = 0
    
    // MARK: IBOulets.
    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonContainer: UIView!
    
    @IBAction func doneTapped(_ sender: UIButton) {
        if let selected = self.selectedIndices {
            self.delegate?.handleSelection(indices: selected, type: type)
        }
        self.removeXib()
    }
    
    // MARK: UITableViewFunctions
    override func awakeFromNib() {
        table.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: table.frame.size.width, height: 1))
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initialize() {
        setTapGesture()
        //        let nib = UINib.init(nibName: ActivitySheetTableCell.reuseIdentifier, bundle: nil)
        //        self.xibTableView.register(nib, forCellReuseIdentifier: ActivitySheetTableCell.reuseIdentifier)
        self.table.registerNibs(nibNames: [ActivitySheetTableCell.reuseIdentifier, TaggedUserTableViewCell.reuseIdentifier])
        if type == .taggedList {
            heightConstant = 10
        }
        tableHeight.constant = CGFloat(self.actionSheetArray.count*54) + heightConstant + 10
        let height = (UIApplication.shared.keyWindow?.frame.height) ?? 0
        if height == 812 {
            if CGFloat(self.actionSheetArray.count*54) > height - 100 {
                tableHeight.constant = (height - 150) + 10
                table.isScrollEnabled = true
            }
        } else {
            if CGFloat(self.actionSheetArray.count*54) > height - 40 {
                tableHeight.constant = height - 200 + 10
                table.isScrollEnabled = true
            }
        }
        if actionSheetArray.count <= 0 {
            tableHeight.constant = 54 + heightConstant
        }
    }
    
    func configureSheet(actionSheetArray:[Any],type:SheetDataType, multipleSelectionOn: Bool? = false, selectedIndices: [Int]? = nil,indexSelected:IndexSelected? = nil) {
        self.multipleSelectionOn = multipleSelectionOn ?? true
        self.buttonContainer.isHidden = !self.multipleSelectionOn
        if let selected = selectedIndices {
            self.selectedIndices = selected
        }
        self.indexSelected = indexSelected
        self.actionSheetArray = actionSheetArray
        self.type = type
        self.table.reloadData()
    }
    
    // MARK: CreateTapGesture to remove Xib from its superview.
    func setTapGesture() {
        tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction(sender:)))
        dimView.isUserInteractionEnabled = true
        dimView.addGestureRecognizer(tap)
    }
    
    // MARK:Function to remove Xib from its superview.
    func removeXib() {
        UIView.animate(withDuration: 0.2, animations: {
            self.removeFromSuperview()
        }) { (_) in
        }
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        if tap != nil{
            dimView.removeGestureRecognizer(tap)
        }
        self.delegate?.cancelSelection(type: self.type)
        removeXib()
    }
}



// MARK: UITableViewDelegate&UITableViewDataSource
extension ActivitySheet:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if actionSheetArray.count <= 0 {
            return 1
        }
        return actionSheetArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if type == .taggedList {
            if let cell = tableView.dequeueReusableCell(withIdentifier: TaggedUserTableViewCell.reuseIdentifier, for: indexPath) as? TaggedUserTableViewCell {
                if let data = self.actionSheetArray as? [UserTag] {
                    cell.setTaggedUserData(data: data[indexPath.row])
                }
                return cell
            }
            return UITableViewCell()
        }
        
        guard let cell:ActivitySheetTableCell = tableView.dequeueReusableCell(withIdentifier: ActivitySheetTableCell.reuseIdentifier) as? ActivitySheetTableCell else {
            return  UITableViewCell()
        }
        if actionSheetArray.count <= 0 {
            cell.itemName.text = "No Data Found"
            cell.itemName.textAlignment = .center
            cell.hideImageView()
            return cell
        }
        if self.selectedIndices?.contains(indexPath.row) == true {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        switch type {
        case .startActivity:
            let data = self.actionSheetArray as? [ActivityData]
            cell.setActivityData(data: data?[indexPath.row] ?? ActivityData())
        case .activity, .additionalActivity:
            let data = self.actionSheetArray as? [ActivityData]
            cell.setActivityData(data: data?[indexPath.row] ?? ActivityData())
        case .metric:
            let data = self.actionSheetArray as? [ActivityMetric]
            cell.setMetricData(data: data?[indexPath.row] ?? .distance)
        case .metricValue:
            let data = self.actionSheetArray as? [MetricValue]
            cell.setForMetricValue(data: data?[indexPath.row] ?? MetricValue())
        case .duration:
            if let data = self.actionSheetArray as? [String] {
                cell.setDataWith(value: data[indexPath.row])
            }
        case .editEvent:
            if let data = self.actionSheetArray as? [EditRecurringEventMode] {
                cell.setDataWith(value: data[indexPath.row].getTitle())
            }
        case .deleteEvent:
            if let data = self.actionSheetArray as? [String] {
                cell.setDataWith(value: data[indexPath.row])
            }
        case .interests:
            if let data = self.actionSheetArray as? [Activity] {
                cell.setDataWith(value: data[indexPath.row].name ?? "")
                cell.lineView.isHidden = true
            }
        case .groupVisibility:
            if let data = self.actionSheetArray as? [GroupVisibility] {
                cell.setDataWith(value: data[indexPath.row].name)
            }
        case .nutritionTrackingPercent:
            if let data = self.actionSheetArray as? [NutritionPercent] {
                cell.setDataWith(value: data[indexPath.row].value)
            }
        case .taggedList:
            break
        case .fundraisingDestination:
            if let data = self.actionSheetArray as? [GNCFundraisingDestination] {
                cell.setDataWith(value: data[indexPath.row].description())
            }
        case .searchCategory:
            if let data = self.actionSheetArray as? [SearchSelection] {
                cell.setDataWith(value: data[indexPath.row].title)
            }
        case .recurrence:
            if let data = self.actionSheetArray as? [RecurrenceType] {
                cell.setDataWith(value: data[indexPath.row].getTitle())
            }
        case .recurrenceFinish:
            if let data = self.actionSheetArray as? [RecurrenceFinishType] {
                cell.setDataWith(value: data[indexPath.row].getTitle())
            }
        case .eventVisibility:
            if let data = self.actionSheetArray as? [EventVisibility] {
                cell.setDataWith(value: data[indexPath.row].name)
            }
        case .eventType:
            if let data = self.actionSheetArray as? [EventType] {
                cell.setDataWith(value: data[indexPath.row].getTitle())
            }
        case .activitySelectionType:
            if let data = self.actionSheetArray as? [ActivitySelectionType] {
                cell.setDataWith(value: data[indexPath.row].title)
            }
        case .activityCategory:
            if let data = self.actionSheetArray as? [Category]{
                cell.setActivityCategory(data: (data[indexPath.row]) )
                
            }else if let data = self.actionSheetArray as? [ActivityCategory] {
                cell.setActivityCategory(data: Category(type: data[indexPath.row].categoryType, name: data[indexPath.row].name.capitalized))
            }
        case .rateActivity:
            if let data = self.actionSheetArray as? [RateActivityData]{
                cell.setRateActivityData(data: (data[indexPath.row]) )
                
            }
        case .trackingNutrition:
            if let data = self.actionSheetArray as? [TrackingNutrition] {
                cell.setDataWith(value: data[indexPath.row].value)
            }
        case .happinessSurvey:
            if let data = self.actionSheetArray as? [TrackingNutrition] {
                cell.setDataWith(value: data[indexPath.row].value)
            }
        case .totalAssesment:
            if let data = self.actionSheetArray as? [TrackingNutrition] {
                cell.setDataWith(value: data[indexPath.row].value)
            }
        case .fileType:
            if let data = self.actionSheetArray as? [String] {
                cell.setDataWith(value: data[indexPath.row])
            }
        case .signUpSheetType:
            if let data = self.actionSheetArray as? [SignUpSheetType]{
                cell.setDataWith(value: data[indexPath.row].title)
            }
        case .coachingTools:
            if let data = self.actionSheetArray as? [CoachList]{
                cell.setCoachList(data: data[indexPath.row])
            }
        case .checkInFrequency:
            if let data = self.actionSheetArray as? [CheckInType] {
                cell.setDataWith(value: data[indexPath.row].getTitle())
            }
        case .healthInfoType:
            if let data = self.actionSheetArray as? [HealthInfoType] {
                cell.setDataWith(value: data[indexPath.row].getTitle())
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !multipleSelectionOn else {
            //in case of multiple rows selection
            if self.selectedIndices?.contains(indexPath.row) == true {
                let index = selectedIndices?.firstIndex(of: indexPath.row)
                if index != nil {
                    selectedIndices?.remove(at: index!)
                }
            } else {
                if self.selectedIndices == nil {
                    self.selectedIndices = []
                }
                self.selectedIndices?.append(indexPath.row)
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
            return
        }
        if self.type == .taggedList {
            self.delegate?.didSelectRowWithValue(data: actionSheetArray[indexPath.row], type: .taggedList)
        }
        //check for network connection
        if self.type == .additionalActivity,
           !isConnectedToNetwork() {
            return
        }
        if (self.type == .groupVisibility) {
            self.delegate?.handleSelection(indices: [indexPath.row], type: .groupVisibility)
        }
        //single selection
        self.indexSelected?(indexPath)
        self.delegate?.handleSelection(index: indexPath.row, type: self.type)
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0.0
        }) { (_) in
            self.removeXib()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //        if type == .taggedList {
        //            return 60//UITableView.automaticDimension
        //        }
        return 54//UITableView.automaticDimension
    }
    
    private func isConnectedToNetwork() -> Bool {
        if !Reachability.isConnectedToNetwork() {
            AlertBar.show(.error, message: AppMessages.AlertTitles.noInternet, duration: 2.0) {
                print("alert displayed")
            }
            return false
        }
        return true
    }
}
