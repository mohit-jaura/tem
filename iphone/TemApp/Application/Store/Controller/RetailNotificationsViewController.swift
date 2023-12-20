//
//  RetailNotificationsViewController.swift
//  TemApp
//
//  Created by Mohit Soni on 22/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import SSNeumorphicView
import UIKit

class RetailNotificationsViewController: DIBaseController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet var lineShadowView: SSNeumorphicView! {
        didSet {
            ver1(lineShadowView)
        }
    }
    
    // MARK: - Properties
    var notifications:[RetailNotifications]?
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.getNotifications()
    }
    
    // MARK: - IBActions
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    private func getNotifications(){
        let isNetworkAvailable = self.isConnectedToNetwork()
        if isNetworkAvailable{
            self.showLoader()
            DIWebLayerRetailAPI().getRetailNotifications { notifications in
                self.hideLoader()
                self.notifications = notifications
                if notifications.count < 1{
                    self.tableView.showEmptyScreen("No notifications found!")
                }
                self.tableView.reloadData()
            } failure: { error in
                self.hideLoader()
                print(error)
            }
        }
        else{
            self.showAlert(message: AppMessages.AlertTitles.noInternet)
        }
    }
}

// MARK: - TableView Extensions
extension RetailNotificationsViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: RetailNotificationsTableViewCell.reuseIdentifier, for: indexPath) as? RetailNotificationsTableViewCell else{ return UITableViewCell() }
        
        if let notification = self.notifications?[indexPath.row] {
            cell.setData(notification: notification)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let products = self.notifications?[indexPath.row].orderData?.productData{
            let wishListVC:ProductWishlistViewController = UIStoryboard(storyboard: .managecards).initVC()
            wishListVC.productList = products
            wishListVC.screenFrom = .retailNotification
            self.navigationController?.pushViewController(wishListVC, animated: true)
        }
    }
    
}
