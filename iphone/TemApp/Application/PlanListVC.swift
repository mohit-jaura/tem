//
//  PlanListVC.swift
//  TemApp
//
//  Created by Developer on 24/05/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

class PlanListVC: DIBaseController {
    @IBOutlet weak var tableView:UITableView!
   private var planList:[PlanList] = [PlanList]()
    private var planAlreadyPurchased = false
    var affiliateId = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getPlanList()
    }
    
    
    
    @IBAction func backButtonTapped(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func onClickSelect(_ sender:UIButton){
        let value = sender.tag
        let data = planList[value].id
        selectPlan(id: data, affiliateid: affiliateId)
    }
    
    private func selectPlan(id:String = "", affiliateid:String = ""){
        let isNetworkAvailable = self.isConnectedToNetwork()
        if isNetworkAvailable{
            self.showLoader()
            DIWebLayerJournalAPI().selectPlan(id: id, affiliateid:affiliateid) { (data) in
                self.hideLoader()
               
                let selectedVC:TermsAndConditions = UIStoryboard(storyboard: .main).initVC()
                selectedVC.urlString = data
                selectedVC.navigationTitle = "Payment"
                self.navigationController?.pushViewController(selectedVC, animated: true)
            } failure: { (error) in
                self.hideLoader()
                print("error\(error)")
            }
        }
        else{
            self.showAlert(message: AppMessages.AlertTitles.noInternet)
        }
    }

    private func getPlanList(){
        let isNetworkAvailable = self.isConnectedToNetwork()
        if isNetworkAvailable{
            self.showLoader()

            DIWebLayerJournalAPI().getPlanList(affiliateId: affiliateId, completion: { (data) in

                self.hideLoader()
                self.planList = self.sortPaymentData(planList: data)
                self.planAlreadyPurchased = self.hasActivePlan(planList: data)
                self.tableView.reloadData()
                if self.planList.count == 0{
                    self.showAlert(withTitle: "", message: AppMessages.ContentMarket.noPlan, okayTitle: AppMessages.AlertTitles.Ok, okCall: {
                        self.navigationController?.popViewController(animated: true)
                    })
                }
            }, failure: { (error) in
                self.hideLoader()
                print("error\(error)")
            })
        }
        else{
            self.showAlert(message: AppMessages.AlertTitles.noInternet)
        }
    }
    
    func sortPaymentData(planList:[PlanList]) -> [PlanList]{
        let sortedList = planList.sorted(by: {$0.amount < $1.amount})
        return sortedList
    }
    
    func hasActivePlan(planList:[PlanList]) -> Bool{
        let filterdList = planList.filter { plan in
            return plan.planActiveStatus == 2
        }
        
        if filterdList.count > 0{
            return true
        }else{
            return false
        }
    }
    
}

extension PlanListVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return planList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanTVC", for: indexPath) as! PlanTVC
        let data = planList[indexPath.row]
        cell.setData(planData: data, index: indexPath.row, planAlreadyPurchased:planAlreadyPurchased)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
}
   
