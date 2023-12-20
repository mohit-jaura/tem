//
//  ActivityAddOnListVC.swift
//  TemApp
//
//  Created by PrabSharan on 21/07/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

class ActivityAddOnListVC: DIBaseController {
    
    @IBOutlet weak var heightSaveBut: NSLayoutConstraint!
    var activityAddOnsArr :[ActivityAddOns]?
    var isViewModeOn :Bool = false
    @IBOutlet weak var navBarView: NavbarCustom!
    @IBOutlet weak var tableView: UITableView!
    var isnoDataIsAdded :Bool = false
    var noDataFound:NoDataFound!
    var hour: Int = 0
    var minutes: Int = 0
    var seconds: Int = 0
    var isNewlyActivityAdded = false
    var screenFrom: Constant.ScreenFrom = .event
    var getActivityAddOnData:(([ActivityAddOns]?) -> ())?
    override func viewDidLoad() {
        super.viewDidLoad()
        initialise()
    }
    func initialise() {
        if isViewModeOn {
            heightSaveBut.constant  = 0
            navBarView.addNewButOut.isHidden =  true
        }
        self.view.backgroundColor = UIColor.newAppThemeColor
        tableView.delegate  = self
        tableView.dataSource = self
        tableView.register(ActivityOptMandCell.nib, forCellReuseIdentifier: ActivityOptMandCell.identifier)
        navBarView.createAction = {
            DispatchQueue.main.async {
                print("tapped")
                self.createNewActivityAddOn()
            }
        }
    }
    @IBAction func saveAction(_ sender:Any) {
        getActivityAddOnData?(activityAddOnsArr)
        if isNewlyActivityAdded {
            NotificationCenter.default.post(name: NSNotification.Name(Constant.NotiName.refreshEvent), object: nil)
        }
        navigationController?.popViewController(animated: true)
    }
    
    func createNewActivityAddOn() {
        let VC = loadVC(.CreateActivityAdOnsVC) as! CreateActivityAdOnsVC
        VC.saveAddOns = {[weak self](addOnAdded) in
            if let addOnAdded = addOnAdded {
                if self?.activityAddOnsArr == nil {
                    self?.activityAddOnsArr = [addOnAdded]
                    self?.isNewlyActivityAdded = true
                } else {
                    self?.activityAddOnsArr?.append(addOnAdded)
                    self?.isNewlyActivityAdded = true
                }
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
        self.navigationController?.present(VC, animated: true, completion: nil)
    }

}
extension ActivityAddOnListVC:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ActivityOptMandCell.identifier, for: indexPath) as! ActivityOptMandCell
        cell.activityModal = activityAddOnsArr?[indexPath.row]
        cell.tag = indexPath.row
        cell.selectionStyle = .none
        cell.segmentView.isUserInteractionEnabled = !isViewModeOn
        cell.segmentView.isHidden = activityAddOnsArr?[indexPath.row].isBinary == 1
        cell.deleteButtOut.isHidden = isViewModeOn
        if !isViewModeOn {
            cell.delete = {[weak self](index)in
                self?.deleteActivity(index)
            }
            cell.segmentSelected = {[weak self](index,selectedSegment)in
                self?.durationSegmentChange(index,selectedSegment)
            }
            cell.mandatrySelected = {[weak self](index)in
                self?.manadatrySelected(index)
            }

        }
        return cell
    }
    
    
    func durationSegmentChange(_ index:IndexPath,_ selectedSegment:Duration) {
        switch selectedSegment {
        case .Free:
            if let oldTime = self.activityAddOnsArr?[index.row].time , let oldVisible = self.activityAddOnsArr?[index.row].visibleTime {
                self.activityAddOnsArr?[index.row].oldTime = oldTime
                self.activityAddOnsArr?[index.row].oldVisibleTime = oldVisible
            }
          
        case .AddDuration:
            pickerShowHide(index)
        }
        
    }
    
    func manadatrySelected(_ index:IndexPath) {
        if let oldValue = activityAddOnsArr?[index.row].isManadatory{
            self.activityAddOnsArr?[index.row].isManadatory = oldValue == 0 ? 1 : 0
        }
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [index], with: .automatic)
        }
    }
     func deleteActivity(_ index:IndexPath) {
         alertOpt("Do you want to delete activity?", okayTitle: "Yes", cancelTitle: "No", okCall: {
             self.activityAddOnsArr?.remove(at: index.row)
             DispatchQueue.main.async {
                 self.tableView.reloadData()
             }
         }, cancelCall: nil)
         
    }
    func pickerShowHide(_ index:IndexPath){
        TimePicker.presentPicker(self) {[weak self] h, m, s in
            self?.hour = h
            self?.seconds = s
            self?.minutes = m
            self?.activityAddOnsArr?[index.row].time =  self?.calculatedTime()
            
            let (h,m,s) = Utility.shared.secondsToHoursMinutesSeconds(seconds: self?.activityAddOnsArr?[index.row].time ?? 0)
            
            self?.activityAddOnsArr?[index.row].visibleTime = "\(h)h \(m)m \(s)s"
            DispatchQueue.main.async {
                self?.tableView.reloadRows(at: [index], with: .automatic)
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = activityAddOnsArr?.count ?? 0
        noDataFound(count)
        return count
    }
    func noDataFound(_ count:Int) {
        if count == 0 && screenFrom != .eventInfo{
                        
            if let bgView = noDataFound(self.tableView,Constant.ErrorMsg.noActivitiesFound,{
                DispatchQueue.main.async {
                    self.createNewActivityAddOn()
                }
            }) {
                if !isnoDataIsAdded {
                    noDataFound = bgView as? NoDataFound
                    tableView.addSubview(bgView)
                    isnoDataIsAdded = true
                    return
                }
        }
        } else if screenFrom == .eventInfo && count == 0 {
            noDataFound?.removeFromSuperview()
            isnoDataIsAdded = false
                tableView.showEmptyScreen("No activities added yet !")
            }
        else {
            tableView.showEmptyScreen("")
            noDataFound?.removeFromSuperview()
            isnoDataIsAdded = false
        }
        
    }
   
    func calculatedTime() -> Int{
        
        let hoursIntoSec = hour * 3600
        let minIntoSec = minutes * 60
        return hoursIntoSec + minIntoSec + seconds
    }
    
}
