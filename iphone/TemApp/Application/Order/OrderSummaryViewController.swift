//
//  OrderSummaryViewController.swift
//  TemApp
//
//  Created by Mohit Soni on 23/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import SSNeumorphicView
import UIKit

class OrderSummaryViewController: DIBaseController {
    var myCartSelected:[ProductInfo]?
    var selectedAddress:SavedAddresses?
    var totalAmt:Double?
    var calculatedAmt = 0.0
    // MARK: - IBOutlets
    @IBOutlet weak var tableView:UITableView!
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var payButton:UIButton!

    @IBOutlet weak var totalFeesLabel: UILabel!
    @IBOutlet weak var processingFeesLabel: UILabel!
    @IBOutlet weak var addressLbl:UILabel!
    
    @IBOutlet weak var addressShadowView:SSNeumorphicView!{
        didSet{
            addShadowView(view: addressShadowView,shadowType:.outerShadow)
        }
    }
    
    @IBOutlet weak var proceedBtnShadowView:SSNeumorphicView!{
        didSet{
            addShadowView(view: proceedBtnShadowView,shadowType:.outerShadow)
            proceedBtnShadowView.viewNeumorphicMainColor = UIColor.appThemeColor.cgColor
        }
    }
    // MARK: - Properties
    var orderLocation:OrderLocation?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialise()
    }
    func initialise() {
        self.addressLbl.text =  selectedAddress?.formattedAdress
        totalAmt = totalAmt?.rounded(toPlaces: 2)
        calculatedAmt = ((((totalAmt ?? 0) / 0.97) + 0.30) - (totalAmt ?? 0)).rounded(toPlaces: 2) // formula given by client
        amountLabel.text = "\(Constant.CUR_Sign)\(totalAmt ?? 0.rounded(toPlaces: 2))"
        processingFeesLabel.text = "\(Constant.CUR_Sign)\(calculatedAmt)"
        calculatedAmt = (calculatedAmt + (totalAmt ?? 0))
        totalFeesLabel.text = "\(Constant.CUR_Sign)\(calculatedAmt)"

        self.payButton.setTitle("Pay  \(Constant.CUR_Sign)\(calculatedAmt)", for: .normal)
        self.payButton.titleLabel?.font = UIFont(name: UIFont.avenirNextBold, size: 22)
    }
    
    // MARK: - IBAction
    
    @IBAction func backTapped(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changeBtnTapped(_ sender:UIButton){
        let addLocationVC:AddAddressViewController = UIStoryboard(storyboard: .manageaddress).initVC()
        self.navigationController?.pushViewController(addLocationVC, animated: true)
    }
    
    @IBAction func placeOrderBtnTapped(_ sender:UIButton){
        apiforOrder()
    }
    func apiforOrder() {
        guard let params = paramsGet() else {alertOpt(DIError.invalidData().message);return}
        
        DIWebLayerRetailAPI().payment(endPoint: EndPoint.PaymentApi.url, parent: self, params: params) {[weak self] status in
            DispatchQueue.main.async {
                switch status {
                    
                case .Success(let url):
                    self?.navigateToWebView(url: url)
                case .Failure(let error):
                    print(error)
                    self?.alertOpt(error)
                    
                }
            }

        }
    }
    func navigateToWebView(url:String?){
        guard let url = url else {
            return
        }
        let webView:TermsAndConditions = UIStoryboard(storyboard: .main).initVC()
        webView.urlString = url
        webView.paymentFrom = .Product
        webView.navigationTitle = "Payment"
        self.navigationController?.pushViewController(webView, animated: true)
    }
    
    func paramsGet() -> Parameters?{
        if let selectedAddress = selectedAddress,var myCartSelected = myCartSelected {
            do {
                myCartSelected = myCartSelected.map({$0
                    var temp = $0
                    temp.rating = 0
                    return temp
                })
                let encoder = JSONEncoder()
                
                let address = try encoder.encode(selectedAddress)
                let myCart = try encoder.encode(myCartSelected)
                
                let dicAdd = try  JSONSerialization.jsonObject(with: address, options: [])as? NSDictionary
                
                let dicPro =  try JSONSerialization.jsonObject(with: myCart, options: [])as? [NSDictionary]
    
                let params:Parameters =    ["totalPrice":calculatedAmt ,
                                            "address":dicAdd ?? [:],
                                            "productData":dicPro ?? [:]]
                print(params)
                return params
            }
            catch let error {
                print(error.localizedDescription)
                return nil
            }
        
            
        }
        return nil
    }
    
    // MARK: - Methods
    
    private func addShadowView(view:SSNeumorphicView,shadowType:ShadowLayerType){
        view.viewNeumorphicCornerRadius = 8
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor = #colorLiteral(red: 0.9686275125, green: 0.9686275125, blue: 0.9686275125, alpha: 1)
        view.viewNeumorphicShadowOpacity = 0.8
        view.viewNeumorphicDarkShadowColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        view.viewNeumorphicShadowOffset = CGSize(width: -2, height: -2)
        view.viewNeumorphicLightShadowColor = #colorLiteral(red: 0.8010598938, green: 0.8089911799, blue: 0.8089911799, alpha: 1)
    }
    
}

// MARK: - Extensions

extension OrderSummaryViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myCartSelected?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: OrderSummaryTableViewCell.reuseIdentifier, for: indexPath) as? OrderSummaryTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.initialise(myCartSelected?[indexPath.row])
        return cell
    }
    
    
}
