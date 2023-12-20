//
//  RetailSettingsViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 17/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

struct SettingsData{
    var icon: String
    var title: String
}
enum Settings: Int,CaseIterable{
    case orders = 0, cart,  wishlist, address, reviewPurchase, notification
    var icon:String {
        switch self {
        case .orders:
            return "order"
        case .cart:
            return "Cart"
        case .wishlist:
            return "Wishlist"
        case .address:
            return "Address"
        case .reviewPurchase:
            return "review"
        case .notification:
            return "Notification"
        }
    }
    
    var title:String {
        switch self {
        case .orders:
            return "My Orders"
        case .cart:
            return "My Cart"
        case .wishlist:
            return "My Wishlist"
        case .address:
            return "My Address"
        case .reviewPurchase:
            return "Review Your Purchase"
        case .notification:
            return "Notifications"
        }
    }
}

class RetailSettingsViewController: DIBaseController {
    
    // MARK: IBOutlet
    @IBOutlet var tableView: UITableView!
    @IBOutlet var lineShadowView: SSNeumorphicView! {
        didSet {
            ver1(lineShadowView)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerCell(ProductSettingsTableViewCell.self)
    }
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension RetailSettingsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Settings.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: ProductSettingsTableViewCell = tableView.dequeueReusableCell(withIdentifier: ProductSettingsTableViewCell.reuseIdentifier) as? ProductSettingsTableViewCell else{
            return UITableViewCell()
            
        }
        let modal = Settings(rawValue: indexPath.row) ?? .address
        cell.iconImageView.image = UIImage(named: modal.icon)
        cell.nameLabel.text = modal.title
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Settings(rawValue: indexPath.row){
        case .orders:
            let orderVC:OrderListVC = UIStoryboard(storyboard: .shopping).initVC()
            self.navigationController?.pushViewController(orderVC, animated: true)
        case .cart:
            let cartVC:CartManagementViewController = UIStoryboard(storyboard: .shopping).initVC()
            self.navigationController?.pushViewController(cartVC, animated: true)
        case .wishlist:
            let wishListVC:ProductWishlistViewController = UIStoryboard(storyboard: .managecards).initVC()
            self.navigationController?.pushViewController(wishListVC, animated: true)
        case .address:
            let manageAddressVC:ManageAddressViewController = UIStoryboard(storyboard: .manageaddress).initVC()
            self.navigationController?.pushViewController(manageAddressVC, animated: true)
        case .reviewPurchase:
            
            let reviewProductVC:ReviewProductViewController = UIStoryboard(storyboard: .managecards).initVC()
            self.navigationController?.pushViewController(reviewProductVC, animated: true)
            
        case .notification:
            let notificationsVC:RetailNotificationsViewController = UIStoryboard(storyboard: .manageaddress).initVC()
            self.navigationController?.pushViewController(notificationsVC, animated: true)
        case .none:
            break
        }
    }
}
