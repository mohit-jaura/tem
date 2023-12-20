//
//  LocationViewController.swift
//  TemApp
//
//  Created by Sourav on 2/18/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import GooglePlaces
import Alamofire


protocol AddressDelegate {
    func selectedAddress(address: Address,isGymLocation:Bool)
}

class LocationViewController: DIBaseController {
    
    // MARK: Variables....
    var delegate:AddressDelegate?
    var currentAddress:Address?
    var recentSearchedLocations: [Address]?
    var isFromGym:Bool = false
    var latitude:Double = 0.0
    var longitude:Double = 0.0
    // MARK: IBOutlets
    
    @IBOutlet weak var heightConstraintOfCurrentLocation: NSLayoutConstraint!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchLocationTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textFieldShadowView: UIView!
    @IBOutlet weak var searchLocationBtnOutlet: UIButton!
    @IBOutlet weak var noGymLocationFoundLbl: UILabel!
    // MARK: App life Cycle....
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        tableView.tableFooterView = UIView()
        initUI()
        if (isFromGym) {
          searchLocationTextField.placeholder = "Search Gym/Club".localized
          self.getRecentGymLocationSearches()
        } else {
          self.getRecentLocationSearches()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("will appear location")
        super.viewWillAppear(animated)
        self.configureNavigationBar()
        if(isFromGym) {
            searchLocationTextField.delegate = self
            searchLocationBtnOutlet.isHidden = true
            heightConstraintOfCurrentLocation.constant = 0
            getCurrentLocationToSearchGym()
        }
    }
    
    // MARK: Custom Methods....
    private func intializer() {
        tableView.tableFooterView = UIView()
    }
    
    // MARK: For Gym.....
    func getCurrentLocationToSearchGym() {
        self.showLoader()
        LocationManager.shared.start()
        LocationManager.shared.success = { address,timestamp in
            self.hideLoader()
            self.searchLocationTextField.isUserInteractionEnabled = true
            self.latitude = address.lat ?? 0
            self.longitude = address.lng ?? 0
        }
        LocationManager.shared.failure = {
            self.searchLocationTextField.isUserInteractionEnabled = false
            self.hideLoader()
            if $0.code == .locationPermissionDenied {
                self.openSetting()
            } else {
                self.showAlert(withError: $0)
            }
        }
    }
    
    func willCheckLocationPermission() {
        
    }
    
    
    private func getAddress(gymName:String, success: @escaping (_ response: NSArray) -> (), failure: @escaping (_ error: String) -> ()){
        let key : String = Constant.ApiKeys.google
        
        let url = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=gym+\(gymName)&location=\(self.latitude),\(self.longitude)&radius=10000&key=\(key)"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON {  response in
            if let receivedResults = response.result.value as? [String:Any]{
                if let result = receivedResults["results"] as? NSArray {
                    if result.count != 0 {
                        self.noGymLocationFoundLbl.isHidden = true
                        success(result)
                    } else {
                        if (self.recentSearchedLocations != nil && (self.recentSearchedLocations?.isEmpty)!) {
                          self.noGymLocationFoundLbl.isHidden = false
                        }
                        let error = receivedResults["error_message"] as? String ?? ""
                        if error != ""{
                            failure(error)
                        } else {
                            failure("Please enter valid zipcode to get suggestion.")
                        }
                        
                    }
                }
            }
        }
    }
    
    //MARK :- Save Last Searched Gym Location....
    
    func saveLastGymSearchedLocation() {
        DIWebLayerUserAPI().saveLastGymSearchLocation(parameters: self.currentAddress.json()) { (error) in
            DILog.print(items: error.message ?? "")
        }
    }
    ///api hit to get the recent gym location searches
    func getRecentGymLocationSearches() {
        DIWebLayerUserAPI().getRecentGymLocationSearches(success: { (locations) in
            self.recentSearchedLocations = []
            self.recentSearchedLocations?.append(contentsOf: locations)
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableHeightConstraint.constant = self.tableView.contentSize.height
                print("recent searches count: \(locations.count)")
                if locations.isEmpty {
                    self.tableHeightConstraint.constant = 0
                }
            }
        }) { (error) in
            DILog.print(items: error.message ?? "There was an error fetching last searched locations")
        }
    }
    
    //Present Google PlaceVC.....
    
    private func presentGooglePlaceViewController() {
        self.view.endEditing(true)
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    private func getUserCurrentLcoation() -> Void {
        self.showLoader()
        LocationManager.shared.start()
        LocationManager.shared.success = { address,timestamp in
            self.hideLoader()
            self.delegate?.selectedAddress(address: address,isGymLocation: self.isFromGym)
            self.navigationController?.popViewController(animated: true)
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
    
   
    
    // MARK: Function to set Navigation Bar.
    private func initUI() {
        self.textFieldShadowView.addShadow()
        print("location view didload")
        self.configureNavigationBar()
    }
    
    func configureNavigationBar() {
//        self.navigationController?.setNavigationBarHidden(false, animated: true)

        let leftBarButtonItem = UIBarButtonItem(customView: getBackButton())
        let rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(rightBarButtonTapped(sender:)))
        rightBarButtonItem.tintColor = UIColor.lightGray
        self.setNavigationController(titleName: Constant.ScreenFrom.searchLocation.title, leftBarButton: [leftBarButtonItem], rightBarButtom: [rightBarButtonItem], backGroundColor: UIColor.white, translucent: true)
        self.navigationController?.setTransparentNavigationBar()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func leftBarButtonTapped(button: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func rightBarButtonTapped(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Server hit
    ///save the searched location
    func saveLastSearchedLocation() {
        DIWebLayerUserAPI().saveLastSearchLocation(parameters: self.currentAddress.json()) { (error) in
            DILog.print(items: error.message ?? "")
        }
    }
    ///api hit to get the recent location searches
    func getRecentLocationSearches() {
        DIWebLayerUserAPI().getRecentLocationSearches(success: { (locations) in
            self.recentSearchedLocations = []
            self.recentSearchedLocations?.append(contentsOf: locations)
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableHeightConstraint.constant = self.tableView.contentSize.height
                print("recent searches count: \(locations.count)")
                if locations.isEmpty {
                    self.tableHeightConstraint.constant = 0
                }
            }
        }) { (error) in
            DILog.print(items: error.message ?? "There was an error fetching last searched locations")
        }
    }
    
    
    
    // MARK: @IBActions...
    
    @IBAction func getCurrentLocation(_ sender: UIButton) {
        getUserCurrentLcoation()
    }
    
    @IBAction func searchLocationButton(_ sender: UIButton) {
        if(!isFromGym){
          presentGooglePlaceViewController()
        }
    }
    
    
}//Class....

// MARK: UItableView DataSource methods....

extension LocationViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recentSearchedLocations?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: RecentSearchesTableViewCell.reuseIdentifier, for: indexPath) as? RecentSearchesTableViewCell {
            if let address = self.recentSearchedLocations?[indexPath.row] {
                cell.initializeWith(address: address,isFromGym: isFromGym)
            }
            return cell
        }
        return UITableViewCell()
    }
    
}

// MARK: UITableViewDelegate
extension LocationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (self.recentSearchedLocations?.count ?? 0 > indexPath.row) {
            if let address = self.recentSearchedLocations?[indexPath.row] {
                if (isFromGym) {
                    currentAddress = address
                    self.saveLastGymSearchedLocation()
                }
                self.delegate?.selectedAddress(address: address,isGymLocation: isFromGym)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.tableHeightConstraint.constant = tableView.contentSize.height
    }
}

extension LocationViewController:UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newLength = ((textField.text?.count) ?? 0) + string.count - range.length
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        
        if (newLength == 0) {
            self.recentSearchedLocations = []
            self.tableView.reloadData()
            self.tableHeightConstraint.constant = 0
            self.noGymLocationFoundLbl.isHidden = true
        }
        
        if(isFromGym && !((updatedString ?? "").isBlank)){
            
            getAddress(gymName:updatedString!, success: { (data) in
                print(data)
                self.recentSearchedLocations = []
                for gymData in data {
                    let addData = gymData as! Parameters
                    let addressData = Address(gymLocationObj: addData)
                    self.recentSearchedLocations?.append(addressData)
                }
                self.tableView.reloadData()
                self.tableHeightConstraint.constant = self.tableView.contentSize.height
            }) { (error) in
                print("error:- \(error)")
            }
        }
        return true
    }
}

extension LocationViewController:GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        currentAddress = Address(gmsPlace: place)
        dismiss(animated: true, completion: nil)
        self.saveLastSearchedLocation()
        self.delegate?.selectedAddress(address: currentAddress ?? Address(),isGymLocation: isFromGym)
        self.navigationController?.popViewController(animated: false)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

