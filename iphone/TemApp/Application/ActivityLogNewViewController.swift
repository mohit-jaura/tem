//
//  ActivityLogNewViewController.swift
//  TemApp
//
//  Created by Mohit Soni on 27/01/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class ActivityLogNewViewController: DIBaseController {
    
    // MARK:  Properties

    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var totalOuterShadowView:SSNeumorphicView! {
        didSet {
            self.createShadowViewNew(view: totalOuterShadowView, shadowType: .outerShadow, cornerRadius: totalOuterShadowView.frame.width / 2, shadowRadius: 0.4)
            totalOuterShadowView.viewNeumorphicMainColor = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1).cgColor
            totalOuterShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.4).cgColor
            totalOuterShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        }
    }
    
    @IBOutlet weak var totalInnerShadowView:SSNeumorphicView! {
        didSet {
            self.createShadowViewNew(view: totalInnerShadowView, shadowType: .innerShadow, cornerRadius: totalInnerShadowView.frame.width / 2, shadowRadius: 0.2)
            totalInnerShadowView.viewNeumorphicMainColor = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1).cgColor
            totalInnerShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
            totalInnerShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        }
    }
    
    @IBOutlet weak var totalActivitiesLbl:UILabel!
    // MARK: Properties
    var activityLog:[ActivitiesLog] = [ActivitiesLog]()
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //  self.addShadowToAddButton()
        self.getActivityLog()
        
        tableView.allowsSelectionDuringEditing = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getActivityLog()
    }
    // MARK: IBActions
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addTapped(_ sender: UIButton) {
        let addActivityVC:AddActivityViewController = UIStoryboard(storyboard: .activity).initVC()
        self.navigationController?.pushViewController(addActivityVC, animated: true)
    }
    
    // MARK: Methods

    func addShadowToAddButton() {
        addButton.addDoubleShadowToButton(cornerRadius: addButton.frame.height / 2, shadowRadius: addButton.frame.height / 2, lightShadowColor:  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3), darkShadowColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3), shadowBackgroundColor: UIColor.black)
    }
    
    func createShadowViewNew(view: SSNeumorphicView, shadowType: ShadowLayerType, cornerRadius:CGFloat,shadowRadius:CGFloat) {
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor =  UIColor(red: 11.0 / 255.0, green: 130.0 / 255.0, blue: 220.0 / 255.0, alpha: 1).cgColor
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.4).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = cornerRadius
        view.viewNeumorphicShadowRadius = shadowRadius
        view.viewNeumorphicShadowOffset = CGSize(width: 2, height: 2 )
    }
    
    private func getActivityLog() {
        if self.isConnectedToNetwork() {
            self.showLoader()
            DIWebLayerReportsAPI().getActivitiesLog { response in
                self.hideLoader()
                self.activityLog = response
                self.totalActivitiesLbl.text = "\(self.activityLog.count)"
                self.tableView.reloadData()
            } failure: { error in
                self.hideLoader()
                print("error\(error)")
            }
        } else {
            self.showAlert(message: AppMessages.AlertTitles.noInternet)
        }
    }
    private func deleteActivityApiCall(id: String, index: Int) {
        if isConnectedToNetwork() {
            self.showLoader()
            DIWebLayerReportsAPI().deleteActivity(activityId: id, completion: { (_) in
                self.getActivityLog()
                self.hideLoader()
                
                print("-------------->>>>>>> success")
                
                //     self.completionAfterDeleteActivity(index: index)
            },failure: { (error) in
                self.hideLoader()
                if let message = error.message {
                    self.showAlert(message: message)
                }
            })
        }
    }
}
// MARK: - Extensions
extension ActivityLogNewViewController:UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if activityLog.count > 0 {
            return activityLog.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: ActivityLogTableViewCell.reuseIdentifier, for: indexPath) as! ActivityLogTableViewCell
        if activityLog.count > 0 {
            cell.configureCell(activityLog: self.activityLog[indexPath.row])
        //    cell.activityImage.isHidden = false
            cell.activityDateAndTimeLabel.isHidden = false
            cell.activityNameLabel.isHidden = false
            cell.activityDetailLabel.textAlignment = .left
        } else {
         // cell.activityImage.isHidden = true
            cell.activityDateAndTimeLabel.isHidden = true
            cell.activityNameLabel.isHidden = true
            cell.activityDetailLabel.text = "No activity added yet !"
            cell.activityDetailLabel.textAlignment = .center
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if activityLog.count > 0 {
            let selectedVC:ActivityLogDetailsViewController = UIStoryboard(storyboard: .reports).initVC()
            selectedVC.activityLog = self.activityLog[indexPath.row]
            selectedVC.index = indexPath.row
            self.navigationController?.pushViewController(selectedVC, animated: true)
        }
    }
    
    //    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    //        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
    //            // delete item at indexPath
    //            print("Delete at index : \(indexPath.row)")
    //        }
    //
    //        delete.backgroundColor = UIColor(red: 210.0/255, green: 30.0/255, blue: 75.0/255, alpha: 1.0)
    //        if let activityId = activityLog[indexPath.row].id{
    //            deleteActivityApiCall(id: "\(activityId)", index: indexPath.row)
    //        }
    //
    //        return [delete]
    //    }
    
    //        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    //          if editingStyle == .delete {
    //            print("Deleted")
    //
    //           // self.catNames.remove(at: indexPath.row)
    //              if let activityId = activityLog[indexPath.row].id{
    //                  deleteActivityApiCall(id: "\(activityId)", index: indexPath.row)
    //              }
    //              self.tableView.deleteRows(at: [indexPath], with: .automatic)
    //          }
    //        }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let activityId = activityLog[indexPath.row].id {
                deleteActivityApiCall(id: "\(activityId)", index: indexPath.row)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    //        func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    //            return UITableViewCell.EditingStyle.delete
    //            }
    
}
