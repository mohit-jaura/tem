//
//  FullOrderDetailViewController.swift
//  TemApp
//
//  Created by Mohit Soni on 24/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
class FullOrderDetailViewController: DIBaseController {

    @IBOutlet weak var tableView:UITableView!

    @IBOutlet weak var navBar: ProductNavbarView!
    
    var orders:[ProductInfo]?
    var orderId:String = String()
    var orderNumber:Int = Int()
    var totalPrice:Int = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialise()
        getOrderDetail(orderId: orderId)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getOrderDetail(orderId: orderId)
    }
    func initialise() {
        navBar.actionDelegate  = self
        navBar.cartMenuStackView.isHidden = true
        navBar.numberLabel.isHidden = true
        tableView.registerCell(OrderCell.self)
        tableView.delegate = self
        tableView.dataSource = self
   //     Defaults.shared.set(value: orderId, forKey: .orderId)
    }
    
    func getOrderDetail(orderId:String){
        var order_Id = orderId
        if orderId == ""{
          //  order_Id = Defaults.shared.get(forKey: .orderId) as? String ?? ""
        }
        DIWebLayerRetailAPI().getFullOrderDetail(orderId: order_Id) { orders,price in
            self.orders = orders
            self.totalPrice = price
            self.tableView.reloadData()
        } failure: { error in
            print(error)
        }
    }
    
}
// MARK: UITABLEVIEW Method
extension FullOrderDetailViewController:UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OrderCell.identifier, for: indexPath ) as! OrderCell
        if let order = orders?[indexPath.row]{
            cell.setData(product: order, orderId: orderNumber, price: totalPrice)
        }
        cell.redirectReviewDelegate = self
        return cell
    }
    
}
extension FullOrderDetailViewController: RedirectReviewDelegate{
    func showReviewPage() {
        let reviewVC: ReviewProductViewController = UIStoryboard(storyboard: .managecards).initVC()
        self.navigationController?.pushViewController(reviewVC, animated: true)
    }
    
    
}

extension FullOrderDetailViewController: ActionsDelegate{
    func navBarButtonsTapped(actionType: ActionType) {
        switch actionType {
        case .backAction:
            self.navigationController?.popViewController(animated: true)
        case .cartAction:
            let cartVC: CartManagementViewController = UIStoryboard(storyboard: .shopping).initVC()
            self.navigationController?.pushViewController(cartVC, animated: true)
        case .menuAction:
            let retailVC: RetailSettingsViewController = UIStoryboard(storyboard: .managecards).initVC()
            self.navigationController?.pushViewController(retailVC, animated: true)
        }
    }
    
    
}
