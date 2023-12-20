//
//  ManageAddressViewController.swift
//  TemApp
//
//  Created by Mohit Soni on 15/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import SSNeumorphicView
import UIKit

class ManageAddressViewController: DIBaseController {

    // MARK: - IBOutlet
    var myCartSelected:[ProductInfo]?
    var totalAmt:Double?
    
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var shadowView:SSNeumorphicView!{
        didSet{
            shadowView.viewNeumorphicCornerRadius = 8
            shadowView.viewDepthType = .outerShadow
            shadowView.viewNeumorphicMainColor = #colorLiteral(red: 0.9686275125, green: 0.9686275125, blue: 0.9686275125, alpha: 1)
            shadowView.viewNeumorphicShadowOpacity = 0.8
            shadowView.viewNeumorphicDarkShadowColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
            shadowView.viewNeumorphicShadowOffset = CGSize(width: -2, height: -2)
            shadowView.viewNeumorphicLightShadowColor = #colorLiteral(red: 0.8010598938, green: 0.8089911799, blue: 0.8089911799, alpha: 1)
        }
    }
    @IBOutlet weak var addNewAddressBtn:UIButton!
    
    @IBOutlet weak var addressCountLbl: UILabel!
    // MARK: - Properties
    var screenFrom: Constant.ScreenFrom = Constant.ScreenFrom.shippingAddress
    lazy var addressManager:AddressManager = AddressManager()
    var savedAddresses:[SavedAddresses]?
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getAllAddresses()
    }
    
    // MARK: - IBActions
    
    @IBAction func backTapped(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addNewAddressTapped(_ sender:UIButton){
        let addAddressVC:AddAddressViewController = UIStoryboard(storyboard: .manageaddress).initVC()
        addAddressVC.newAddress = true
        self.navigationController?.pushViewController(addAddressVC, animated: true)
    }
    // MARK: - Methods
    
    private func getAllAddresses(){
        self.showLoader()
        self.addressManager.getAllAddresses { addresses in
            self.hideLoader()
            self.savedAddresses = addresses
            if addresses.count == 0{
                self.tableView.showEmptyScreen("No address added yet!")
            }else{
                self.tableView.showEmptyScreen("")
            }
            self.tableView.reloadData()
        } failure: { error in
            self.hideLoader()
            print(error.message)
        }
    }
    
    private func getAddress(address:SavedAddresses) -> OrderLocation{
        var orderLocation:OrderLocation = OrderLocation()
        orderLocation.id = address.id
        orderLocation.name = address.name
        orderLocation.apartment = address.apartment
        orderLocation.street = address.street
        orderLocation.city = address.city
        orderLocation.pinCode = address.pinCode
        orderLocation.state = address.state
        orderLocation.country = address.country
        orderLocation.formattedAdress = address.formattedAdress
        orderLocation.lat = address.lat
        orderLocation.long = address.long
        return orderLocation
    }
}


// MARK: - Extensions
extension ManageAddressViewController: UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedAddresses?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell:ManageAddressTableViewCell = tableView.dequeueReusableCell(withIdentifier: ManageAddressTableViewCell.reuseIdentifier, for: indexPath) as? ManageAddressTableViewCell
        else{ return UITableViewCell()}
        if let address = savedAddresses?[indexPath.row]{
            cell.setData(address: address,index: indexPath.row)
            cell.delegate = self
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            self.editTapped(index: indexPath.row)
        }
        edit.backgroundColor = UIColor.appThemeColor
        return [edit]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if screenFrom == .checkoutCart{
            if let address = savedAddresses?[indexPath.row]{
                let orderSummaryVC:OrderSummaryViewController = UIStoryboard(storyboard: .manageaddress).initVC()
                orderSummaryVC.orderLocation = getAddress(address: address)
                orderSummaryVC.myCartSelected  = myCartSelected
                orderSummaryVC.selectedAddress = savedAddresses?[indexPath.row]
                orderSummaryVC.totalAmt = totalAmt

                self.navigationController?.pushViewController(orderSummaryVC, animated: true)
            }
        }
    }
}


extension ManageAddressViewController:ManageAddressTableViewCellDelegate{
    func editTapped(index: Int) {
        if let address = savedAddresses?[index]{
            let addAddressVC:AddAddressViewController = UIStoryboard(storyboard: .manageaddress).initVC()
            addAddressVC.orderLocation = getAddress(address: address)
            self.navigationController?.pushViewController(addAddressVC, animated: true)
        }
    }
}
