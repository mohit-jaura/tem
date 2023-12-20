//
//  OrderListVC.swift
//  TemApp
//
//  Created by PrabSharan on 16/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

//{
//                "_id": "62b5844b056d256009ffb072",
//                "order_number": 43517547659,
//                "totalPrice": 100,
//                "created_at": "2022-06-24T09:30:51.373Z"
//            },
struct OrderHistory: Codable{
    let id: String?
    let orderNumber:Int?
    let totalPrice:Int?
    let date:String?
    let status: Int?
    
    enum CodingKeys: String, CodingKey{
        case id = "_id"
        case orderNumber = "order_number"
        case totalPrice = "totalPrice"
        case date = "created_at"
        case status
    }
}
class OrderListVC: UIViewController {
    @IBOutlet weak var tableView:UITableView!

    @IBOutlet weak var navBar: ProductNavbarView!
    
    var orders:[OrderHistory]?
    override func viewDidLoad() {
        super.viewDidLoad()
        initialise()
        getOrderHistory()
        
    }
    func initialise() {
        navBar.actionDelegate = self
        navBar.cartMenuStackView.isHidden = true
        navBar.numberLabel.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCell(FullOrderCell.self)
    }
    
    func getOrderHistory(){
        DIWebLayerRetailAPI().getOrderHistory { order in
            self.orders = order
            if order.count < 1{
                self.tableView.showEmptyScreen("No Orders yet!")
            }
            self.tableView.reloadData()
        } failure: { error in
            print(error)
        }
    }
}

// MARK: UICollection Method
extension OrderListVC:UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FullOrderCell.identifier, for: indexPath ) as! FullOrderCell
        cell.selectionStyle = .none
        if let order = orders?[indexPath.row]{
            cell.setData(order: order)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let order = orders?[indexPath.row]{
            let detailVC:FullOrderDetailViewController = UIStoryboard(storyboard: .shopping).initVC()
            detailVC.orderId = order.id ?? ""
            detailVC.orderNumber = order.orderNumber ?? 0
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

extension OrderListVC: ActionsDelegate{
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
