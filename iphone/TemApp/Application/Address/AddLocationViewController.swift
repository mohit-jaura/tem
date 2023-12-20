//
//  AddLocationViewController.swift
//  TemApp
//
//  Created by Mohit Soni on 15/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import Contacts
import CoreLocation
import GooglePlaces
import MapKit
import SSNeumorphicView
import UIKit

protocol AddLocationDelegate{
    func saveCurrentLocation(orderLocation :OrderLocation)
}

class AddLocationViewController: DIBaseController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var shadowView:SSNeumorphicView!{
        didSet{
            addShadowView(view: shadowView)
        }
    }
    @IBOutlet weak var currentLocationShadowView:SSNeumorphicView!{
        didSet{
            addShadowView(view: currentLocationShadowView)
        }
    }
    @IBOutlet weak var useMycurrentLocationShadowView:SSNeumorphicView!{
        didSet{
            addShadowView(view: useMycurrentLocationShadowView)
        }
    }
    
    @IBOutlet weak var currentLocationBtn:UIButton!
    @IBOutlet weak var mapView:MKMapView!{
        didSet{
            self.mapView.delegate = self
            self.mapView.isUserInteractionEnabled = false
        }
    }
    @IBOutlet weak var currentLocationLbl:UILabel!{
        didSet{
            currentLocationLbl.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openGooglePlaces(recognizer:)))
            tapGesture.numberOfTapsRequired = 1
            currentLocationLbl.addGestureRecognizer(tapGesture)
        }
    }
    // MARK: - Properties
    
    let addressManager:AddressManager = AddressManager()
    
    var delegate:AddLocationDelegate?
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentLocation()
    }
    
    
    // MARK: - IBActions
    @IBAction func backTapped(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveLocationTapped(_ sender:UIButton){
        self.delegate?.saveCurrentLocation(orderLocation: self.addressManager.locationSaved)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func useMycurrentLocationTapped(_ sender:UIButton){
        self.currentLocation()
    }
    
    // MARK: - Methods
    func currentLocation() {
        self.showLoader()
        LocationManager.shared.start()
        LocationManager.shared.success = { _,_ in
            self.hideLoader()
            if let location = LocationManager.shared.locationManager.location{
                self.addressManager.addPlacemarkTextField(location, mapView: self.mapView){
                    orderLocation in
                    self.currentLocationLbl.text = orderLocation.formattedAdress
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
    
    private func addShadowView(view:SSNeumorphicView){
        view.viewNeumorphicCornerRadius = 8
        view.viewDepthType = .outerShadow
        view.viewNeumorphicMainColor = #colorLiteral(red: 0.9686275125, green: 0.9686275125, blue: 0.9686275125, alpha: 1)
        view.viewNeumorphicShadowOpacity = 0.8
        view.viewNeumorphicDarkShadowColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        view.viewNeumorphicShadowOffset = CGSize(width: -2, height: -2)
        view.viewNeumorphicLightShadowColor = #colorLiteral(red: 0.8010598938, green: 0.8089911799, blue: 0.8089911799, alpha: 1)
    }
    
    
    
    @objc func openGooglePlaces(recognizer: UITapGestureRecognizer) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                                                  UInt(GMSPlaceField.formattedAddress.rawValue) |
                                                  UInt(GMSPlaceField.coordinate.rawValue) |
                                                  UInt(GMSPlaceField.addressComponents.rawValue) |
                                                  UInt(GMSPlaceField.placeID.rawValue))
        autocompleteController.placeFields = fields
        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .noFilter
        autocompleteController.autocompleteFilter = filter
        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
    }
}

extension AddLocationViewController: MKMapViewDelegate{
    
    // map drag functionality
    //    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    //        let centre = mapView.centerCoordinate
    //       self.mapView.setCenter(centre, animated: true)
    //        var destinationLocation = CLLocation()
    //        destinationLocation = CLLocation(latitude: centre.latitude, longitude: centre.longitude)
    //        self.addPlacemarkTextField(destinationLocation)
    //        self.updateLocationOnMap(to: destinationLocation.coordinate)
    //    }
}

extension AddLocationViewController:  GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        currentLocationLbl.text = place.formattedAddress
        addressManager.locationSaved.street = place.name
        addressManager.locationSaved.lat = place.coordinate.latitude
        addressManager.locationSaved.long = place.coordinate.longitude
        addressManager.locationSaved.formattedAdress = place.formattedAddress
        self.addressManager.addPlacemarkTextField(CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude), mapView: self.mapView){
            orderLocation in
            self.currentLocationLbl.text = orderLocation.formattedAdress
            self.addressManager.locationSaved.formattedAdress = place.formattedAddress
        }
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
