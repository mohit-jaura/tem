//
//  AddAddressViewController.swift
//  TemApp
//
//  Created by Mohit Soni on 16/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import CoreLocation
import SSNeumorphicView
import UIKit

class AddAddressViewController: DIBaseController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var addressLbl:UILabel!
    
    @IBOutlet weak var addressShadowView:SSNeumorphicView!{
        didSet{
            addShadowView(view: addressShadowView,shadowType:.outerShadow)
        }
    }
    
    @IBOutlet weak var nameShadowView:SSNeumorphicView!{
        didSet{
            addShadowView(view: nameShadowView,shadowType:.innerShadow)
        }
    }
    
    @IBOutlet weak var flatShadowView:SSNeumorphicView!{
        didSet{
            addShadowView(view: flatShadowView,shadowType:.innerShadow)
        }
    }
    
    @IBOutlet weak var streetShadowView:SSNeumorphicView!{
        didSet{
            addShadowView(view: streetShadowView,shadowType:.innerShadow)
        }
    }
    
    @IBOutlet weak var cityShadowView:SSNeumorphicView!{
        didSet{
            addShadowView(view: cityShadowView,shadowType:.innerShadow)
        }
    }
    
    @IBOutlet weak var stateShadowView:SSNeumorphicView!{
        didSet{
            addShadowView(view: stateShadowView,shadowType:.innerShadow)
        }
    }
    @IBOutlet weak var proceedBtnShadowView:SSNeumorphicView!{
        didSet{
            addShadowView(view: proceedBtnShadowView,shadowType:.outerShadow)
        }
    }
    
    @IBOutlet weak var nameField:UITextField!
    @IBOutlet weak var streetNumberField:UITextField!
    @IBOutlet weak var streetNameField:UITextField!
    @IBOutlet weak var cityField:UITextField!
    @IBOutlet weak var stateField:UITextField!
    
    // MARK: - Properties
    
    let addressManager:AddressManager = AddressManager()
    var orderLocation:OrderLocation?
    var newAddress:Bool = false
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //  addLocationController.delegate = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let orderLocation = orderLocation {
            DispatchQueue.main.async {
                self.setFieldsValue(orderLocation: orderLocation)
            }
        }else{
            currentLocation()
        }
    }
    
    // MARK: - IBActions
    @IBAction func backTapped(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changeBtnTapped(_ sender:UIButton){
        let addLocationVC:AddLocationViewController = UIStoryboard(storyboard: .manageaddress).initVC()
        addLocationVC.delegate = self
        self.navigationController?.pushViewController(addLocationVC, animated: true)
    }
    
    @IBAction func proceedBtnTapped(_ sender:UIButton){
        if formValidate(){
            newAddress ? saveAddress() : updateAddress()
        }
        else{
            self.showAlert(withTitle: "", message: "Please enter Address", okayTitle: "Ok") {
                // ok call
            } cancelCall: {
                // cancel call
            }

        }
    }
    // MARK: - Methods
    
    func currentLocation() {
  
        self.showLoader()
        LocationManager.shared.start()
        LocationManager.shared.success = { _,_ in
            self.hideLoader()
            if let location = LocationManager.shared.locationManager.location{
                self.addressManager.addPlacemarkTextField(location){
                    orderLocation in
                    self.addressManager.locationSaved = orderLocation
                }
            }
        }
        LocationManager.shared.failure = {
            self.hideLoader()
            if $0.code == .locationPermissionDenied {
                self.openSetting()
            } else {
                self.showAlert(withError: $0)
            }
        }
    }
    
    
    private func setFieldsValue(orderLocation:OrderLocation){
        self.addressLbl.text = orderLocation.formattedAdress
        self.nameField.text = orderLocation.name
        self.streetNumberField.text = orderLocation.apartment
        self.streetNameField.text = orderLocation.street
        self.cityField.text = orderLocation.city
        self.stateField.text = orderLocation.state
    }
    
    private func addShadowView(view:SSNeumorphicView,shadowType:ShadowLayerType){
        view.viewNeumorphicCornerRadius = 8
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor = #colorLiteral(red: 0.9686275125, green: 0.9686275125, blue: 0.9686275125, alpha: 1)
        view.viewNeumorphicShadowOpacity = 0.8
        view.viewNeumorphicDarkShadowColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        view.viewNeumorphicShadowOffset = CGSize(width: -2, height: -2)
        view.viewNeumorphicLightShadowColor = #colorLiteral(red: 0.8010598938, green: 0.8089911799, blue: 0.8089911799, alpha: 1)
    }
    
    private func formValidate() -> Bool{
        if nameField.text?.isEmpty == true || streetNumberField.text?.isEmpty == true || streetNameField.text?.isEmpty == true || cityField.text?.isEmpty == true || stateField.text?.isEmpty == true {
            return false
        }
            return true
    }
    
    private func saveAddress(){
        self.addressManager.locationSaved.name = nameField.text ?? ""
        self.addressManager.locationSaved.apartment = streetNumberField.text ?? ""
        self.addressManager.locationSaved.street = streetNameField.text ?? ""
        self.addressManager.locationSaved.city = cityField.text ?? ""
        self.addressManager.locationSaved.state = stateField.text ?? ""
        
        self.addressManager.addNewAddress(address: self.addressManager.locationSaved) { message in
            self.showAlert(withTitle: "", message: message, okayTitle: "OK", okStyle: .default) {
                // ok call
                self.navigationController?.popViewController(animated: true)
            } cancelCall: {
                // cancel call
            }
        }
    }
    
    private func updateAddress(){
        self.addressManager.locationSaved.name = nameField.text ?? ""
        self.addressManager.locationSaved.apartment = streetNumberField.text ?? ""
        self.addressManager.locationSaved.street = streetNameField.text ?? ""
        self.addressManager.locationSaved.city = cityField.text ?? ""
        self.addressManager.locationSaved.state = stateField.text ?? ""
        self.addressManager.locationSaved.lat = self.orderLocation?.lat ?? 0
        self.addressManager.locationSaved.long = self.orderLocation?.long ?? 0
        self.addressManager.locationSaved.pinCode = self.orderLocation?.pinCode ?? ""
        self.addressManager.locationSaved.id = self.orderLocation?.id ?? ""
        
        self.addressManager.updateAddress(address: self.addressManager.locationSaved) { message in
            self.showAlert(withTitle: "", message: message, okayTitle: "OK", okStyle: .default) {
                // ok call
                self.navigationController?.popViewController(animated: true)
            } cancelCall: {
                // cancel call
            }
        }
    }
    
}

extension AddAddressViewController:AddLocationDelegate{
    func saveCurrentLocation(orderLocation: OrderLocation) {
        self.addressManager.locationSaved = orderLocation
        self.orderLocation = orderLocation
//        self.setFieldsValue(orderLocation: orderLocation)
    }
}
