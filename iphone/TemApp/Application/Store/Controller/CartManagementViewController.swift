//
//  CartManagementViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 20/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

struct CertData{
    var productName: String
    var quanity: Int
    var amount: Int
}

class CartManagementViewController: DIBaseController {
    @IBOutlet weak var subTotal:UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backView: SSNeumorphicView! {
        didSet{
           ver2(backView)
        }
    }
    
    @IBOutlet weak var containerView: UIView!
    var cartListArr :[ProductInfo]? {
        didSet {
            self.containerView.layoutIfNeeded()
            self.heightCart.constant = (self.cartListArr?.count ?? 0 == 0) ? 0 : 165
        }
    }
    
    @IBOutlet weak var heightCart: NSLayoutConstraint!
    @IBOutlet var lineShadowView: SSNeumorphicView! {
        didSet {
          ver1(lineShadowView)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNibs(nibNames: [CartMangementCell.reuseIdentifier])
        subTotal.textColor = .black
        self.backView.clipsToBounds = true
        getCart()
    }
    

    @IBAction func checkoutTapped(_ sender: Any) {
        let manageAddressVC: ManageAddressViewController = UIStoryboard(storyboard: .manageaddress).initVC()

        manageAddressVC.screenFrom = .checkoutCart
        manageAddressVC.myCartSelected = cartListArr
        manageAddressVC.totalAmt = subTotalMethod()
        self.navigationController?.pushViewController(manageAddressVC, animated: true)
    }
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
// MARK: UITableViewDelegate, UITableViewDataSource
extension CartManagementViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartListArr?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: CartMangementCell = tableView.dequeueReusableCell(withIdentifier: CartMangementCell.reuseIdentifier) as? CartMangementCell else{
            return UITableViewCell()
        }
        cell.tag = indexPath.row
        cell.stepperTapped = {[weak self] value,indexSelected in
            // call cart update quantity api
            debugPrint("-----------\(value)")
            self?.updateCart(indexSelected, value)
        }
        cell.setData(self.cartListArr?[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteCart(indexPath)
        }
    }
    
    func deleteCart(_ indexPath:IndexPath) {
        let urlInfo = EndPoint.DeleteCart(id: cartListArr?[indexPath.row].id ?? "")
        
        DIWebLayerRetailAPI().deleteProduct(endPoint: urlInfo.url, parent: self) {[weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .Success(let msg):
                    self?.cartListArr?.remove(at: indexPath.row)
                  
                    self?.tableView.reloadData()
                    self?.getCart()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self?.alertOpt(msg)
                    }
                case .Failure(let err):
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self?.alertOpt(err)
                    }
                   
                }
            }
        }
    }
    
    func noDataFound() {
        self.heightCart.constant = (self.cartListArr?.count ?? 0 == 0) ? 0 : 165

        debugPrint("No data found")
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func subTotalMethod() ->Double {
        var subTotalGet:Double = 0.0
        for i in 0..<(cartListArr?.count ?? 0) {
            subTotalGet += Double(cartListArr?[i].quantity ?? 0) *  (Double(cartListArr?[i].variants?.first?.price ?? "0") ?? 0.0)
        }
        return subTotalGet
        print(subTotal)
       
    }
    
}
extension CartManagementViewController {
    func updateCart(_ indexPath:IndexPath,_ qnty:Int) {
        
        guard let id = cartListArr?[indexPath.item].product_id  else {return}
        
        let oldQnty = cartListArr?[indexPath.row].quantity ?? 0
        
        let isAddedToCart = oldQnty < qnty
        
        let apiInfo = EndPoint.AddCart(id: "\(id)" , isAddedNew: isAddedToCart, variantID:"\(cartListArr?[indexPath.row].variant_id ?? 0)")
        
        DIWebLayerRetailAPI().addtoCart(endPoint: apiInfo.url,parent:self, params: apiInfo.params) {[weak self] status, optionalMsg in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                
                if status{
                    self.cartListArr?[indexPath.row].quantity = qnty
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    self.subTotal.text = "\(Constant.CUR_Sign)\(self.subTotalMethod())"
                    self.alertOpt(optionalMsg)

                   // self.tableView.reloadData()
                }else {
                    self.tableView.reloadData()
                    self.alertOpt( optionalMsg)
                }
            }
        }
    }
    func getCart() {
        Cart.apiToGetCart({[weak self] status in
            guard let self = self else {return}
            DispatchQueue.main.async {
            
                switch status {
                case .Success(let data, _):
                    if let data = data as? [ProductInfo] {
                        self.cartListArr = data
                        self.subTotal.text = "\(Constant.CUR_Sign)\(self.subTotalMethod())"

                        self.tableView.reloadData()
                    }
                case .NoDataFound:
                    self.noDataFound()
                    self.tableView.reloadData()
                    self.tableView.showEmptyScreen("No products added !")
                case .Failure(let error): self.alertOpt(error)
                    

                }
            }

        }, self)
    }
}
