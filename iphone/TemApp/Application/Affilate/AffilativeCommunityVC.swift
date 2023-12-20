//
//  AffilativeCommunityVC.swift
//  TemApp
//
//  Created by Developer on 12/04/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
class AffilativeCommunityVC: DIBaseController {
    
    @IBOutlet weak var streamImage: UIImageView!
    @IBOutlet weak var liveStreamButOut: UIButton!
    @IBOutlet weak var newGoalOrChallengeButton: UIButton!
    var marketPlaceId = ""
    @IBOutlet weak var tableView:UITableView!
    private var affilativeCommunityDataModel:[AffilativeCommunityDataModel] = [AffilativeCommunityDataModel]()
   

    override func viewDidLoad() {
        super.viewDidLoad()
        getAffilativeCommunity()
        self.liveStreamButOut.isHidden = true
        self.streamImage.isHidden = true
    }
    func checkHostLive(){
        Stream.connect.toServer(marketPlaceId,false,self, {[weak self] isStreamOn,modal  in
                   DispatchQueue.main.async {
                       self?.liveStreamButOut.isHidden = !isStreamOn
                       self?.streamImage.isHidden = !isStreamOn
                   }
               })
           }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
      
        checkHostLive()
        // Do any additional setup after loading the view.
    }
    

    private func getAffilativeCommunity() {
        if self.isConnectedToNetwork() {
            self.showLoader()
            DIWebLayerReportsAPI().getAffilativeCommunity(id: self.marketPlaceId,  completion: { response in
                self.hideLoader()
                self.affilativeCommunityDataModel = response
                self.tableView.reloadData()
            }, failure: { error in
                self.hideLoader()
                print("error\(error)")
            })
        }
        else{
            self.showAlert(message: AppMessages.AlertTitles.noInternet)
        }
    }
   
    @IBAction func liveSessionTapped(_ sender: UIButton) {
        Stream.connect.toServer(marketPlaceId,true,self)
    }
    
    @IBAction func ourTemTapped(_ sender: UIButton) {
        let newVC:AffiliateTemListingViewController = UIStoryboard(storyboard: .chatListing).initVC()
        newVC.affiliateId = self.marketPlaceId
        self.navigationController?.pushViewController(newVC, animated: true)
        
    }
}
extension AffilativeCommunityVC:UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return affilativeCommunityDataModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AffilativeContentTVC.reuseIdentifier, for: indexPath) as!
        AffilativeContentTVC
        cell.affilativeCommunityVC = self
        cell.model1 = affilativeCommunityDataModel[indexPath.section].data
        if indexPath.section == 0 {
            cell.indexSelected[0] = 0
        } else if indexPath.section == 1 {
            cell.indexSelected[1] = 1
        } else if indexPath.section == 2 {
            cell.indexSelected[2] = 2
        }
        else {
            cell.indexSelected[3] = 3
        }
        
    
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 70))
            
            let label = UILabel()
            label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.text = affilativeCommunityDataModel[section].name ?? ""
        label.font = .systemFont(ofSize: 20, weight: .bold)
            label.textColor = .white
            
            headerView.addSubview(label)
            headerView.backgroundColor = .black
            
            return headerView
        }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        headerView.backgroundColor = .black
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
}
