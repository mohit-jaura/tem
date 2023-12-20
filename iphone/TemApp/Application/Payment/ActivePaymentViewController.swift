//
//  ActivePaymentViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 25/05/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

class ActivePaymentViewController: DIBaseController {
    
    // MARK: Variables
    private var planList:[PlanList] = [PlanList]()
    var affiliateID = ""
    
    // MARK: IBOutlets
    @IBOutlet weak var tableView:UITableView!
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getPlanList()
        self.tableView.reloadData()
    }
    
    // MARK: Methods
    private func getPlanList(){
        let isNetworkAvailable = self.isConnectedToNetwork()
        if isNetworkAvailable{
            self.showLoader()
            DIWebLayerJournalAPI().getPlanList(affiliateId: self.affiliateID, completion: {(data) in
                self.hideLoader()
                self.planList = self.sortPaymentData(planList: data)
                self.tableView.reloadData()
            }, failure: { (error) in
                self.hideLoader()
                self.showAlert(withTitle: "", message: "\(error)", okayTitle: "Ok")
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
    
    func updateUI(message: String) {
        self.showAlert(withTitle: "", message: message, okayTitle: "OK", okCall: {
            self.tableView.reloadData()
        })
    }
    
    func navigateToWebView(url:String){
        let webView:TermsAndConditions = UIStoryboard(storyboard: .main).initVC()
        webView.urlString = url
        webView.navigationTitle = "Payment"
        self.navigationController?.pushViewController(webView, animated: true)
    }
    
    private func getActivePlanId() -> String{
        let filteredPlanList = self.planList.filter { plan in
            return plan.planActiveStatus == PlanActiveStatus.active.rawValue || plan.planActiveStatus == PlanActiveStatus.cancel.rawValue
        }
        
        if !filteredPlanList.isEmpty{
            return filteredPlanList[0].id
        }
        return ""
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension ActivePaymentViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return planList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: ActivePaymentTableViewCell = tableView.dequeueReusableCell(withIdentifier: ActivePaymentTableViewCell.reuseIdentifier) as? ActivePaymentTableViewCell else{
            return UITableViewCell()
        }
        cell.updateSubscriptionDelegate = self
        cell.affiliateId = affiliateID
        cell.setData(planData: planList[indexPath.row],index:indexPath.row)
        return cell
    }
    
}

// MARK: UpdateSubscriptionDelegate
extension ActivePaymentViewController: UpdateSubscriptionDelegate{
    func didTappedCancelOrUpgradeButton(index: Int) {
        self.showLoader()
        switch PlanActiveStatus(rawValue: self.planList[index].planActiveStatus){
        case .active:
            let params = SubscriptionPlan(affiliateId: affiliateID, id: planList[index].id).getDictionary()
            DIWebLAyerPaymentAPI().cancelSubscription(params: params) { url in
                print("success\(url)")
                // open web view
                self.hideLoader()
                self.getPlanList()
                //     self.updateUI(message: url)
            }failure: { (error) in
                self.hideLoader()
                self.getPlanList()
                print("error\(error)")
            }
        case .notActive:
            DIWebLayerJournalAPI().selectPlan(id: planList[index].id, affiliateid:affiliateID) { (url) in
                self.hideLoader()
                self.navigateToWebView(url: url)
            } failure: { (error) in
                self.hideLoader()
                print("error\(error)")
            }
        case .upgrade:
            let params = [
                "affiliateid" : affiliateID,
                "userid" : UserManager.getCurrentUser()?.id ?? "",
                "upgradeid" : planList[index].id,
                "activeid" : getActivePlanId()
            ]
            DIWebLAyerPaymentAPI().upgradePlan(parameters:params, success: { url in
                print("success\(url)")
                // open web view
                self.hideLoader()
                self.navigateToWebView(url: url)
                //   self.updateUI(message: url)
            }, failure: { message in
                self.hideLoader()
                print(message)
            })
        case .downgrade:
            DIWebLAyerPaymentAPI().downgradePlan(planId: planList[index].id, affiliateId: affiliateID,activeId: getActivePlanId(), success: { url in
                self.hideLoader()
                self.getPlanList()
            }, failure: { message in
                self.hideLoader()
                print(message)
            })
        default:
            break
        }
        
    }
}
