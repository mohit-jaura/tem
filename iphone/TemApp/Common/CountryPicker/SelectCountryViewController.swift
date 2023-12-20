//
//  SelectCountryViewController.swift
//  CountryPicker
//
//  Created by debut on 28/12/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import UIKit

struct Country {
    let country_code : String
    let country_name : String
    let emoji : String
    let countryPhoneCode : String
}

protocol SelectCountryViewControllerDelegate {
    func setCountryCode(code:String)
}
class SelectCountryViewController: UITableViewController {
    
    var countries = [[String: String]]()
    var countriesFiltered = [Country]()
    var countriesModel = [Country]()
    let cellIdentifier = "countryCell"
    var selectedCountryCodeList : [String] = []
    
    var selectionTintColor:UIColor = appThemeColor
    static var delegate:SelectCountryViewControllerDelegate?
    
    var navigationBarTintColor:UIColor = appThemeColor
    var navigationBarTextColor:UIColor = .textBlackColor
    var navigationTitle:String = "Select Country".localized
    var navigationBackButtonTitle = "Done".localized
    var selectedCountry:Country!
    
    let searchBar = UISearchBar()
    var searchBarPlaceholder = "Search".localized
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeftBarButton()
        configureSearchBar()
        jsonSerial()
        collectCountries()
        self.navigationItem.hidesBackButton = true
        self.title = navigationTitle
        self.navigationController?.navigationBar.barTintColor = self.navigationBarTintColor
        self.navigationController?.navigationBar.tintColor = self.navigationBarTextColor
        let textAttributes = [NSAttributedString.Key.foregroundColor:self.navigationBarTextColor]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func setupLeftBarButton(){
        let leftbarButton = UIBarButtonItem(title: navigationBackButtonTitle, style: .plain, target: self, action: #selector(self.doneSelection))
        self.navigationItem.leftBarButtonItem = leftbarButton
        self.navigationItem.leftItemsSupplementBackButton = true
    }
    
    func configureSearchBar() {
        searchBar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50)
        searchBar.barStyle = .default
        searchBar.barTintColor = appThemeGrayColor
        searchBar.isTranslucent = true
        searchBar.placeholder = searchBarPlaceholder
        searchBar.delegate = self
        self.tableView.keyboardDismissMode = .onDrag
//        self.tableView.tableHeaderView = searchBar
        self.tableView.tableFooterView = UIView()
    }
    
    @objc private func doneSelection(){
        if selectedCountry != nil {
            SelectCountryViewController.delegate?.setCountryCode(code:SelectCountryViewController.getCountryPhonceCode(selectedCountry.country_code))
        }
        self.navigationController?.popViewController(animated: false)
    }
    
    private func jsonSerial() {
        let data = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "countries", ofType: "json")!))
        do {
            let parsedObject = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
            if let countriesArray = parsedObject as? NSArray{
                for value in countriesArray{
                    if let countryDict = value as? [String:String]{
                        let code = countryDict["code"] ?? ""
                        if selectedCountryCodeList.contains(code){
                            countries.append(countryDict)
                        }
                    }
                }
            }
            
            
//            countries = parsedObject as! [[String : String]]
            
//            for (index,data) in countries.enumerated() {
//                if data["code"] == "KR" {
//                  countries.remove(at: index)
//                }
//            }
//            countries.insert(["emoji": "🇰🇷", "name": "South Korea", "title": "flag for South Korea", "code": "KR", "unicode": "U+1F1F0 U+1F1F7"], at: 0)
        }catch{
            print("not able to parse")
        }
    }
    
    func collectCountries() {
        for country in countries  {
            let code = country["code"] ?? ""
            let name = country["name"] ?? ""
            let emoji = country["emoji"] ?? ""
            let countryPhoneCode = SelectCountryViewController.getCountryPhonceCode(code)
            countriesModel.append(Country(country_code:code, country_name:name,emoji:emoji,countryPhoneCode:countryPhoneCode))
        }
        countriesModel = countriesModel.sorted { (country1, country2) -> Bool in
            return country1.country_name.compare(country2.country_name) == ComparisonResult.orderedAscending
        }
        
//        for (index,data) in countriesModel.enumerated() {
//            if data.country_code == "KR" {
//                countriesModel.remove(at: index)
//            }
//        }
//        countriesModel.insert(Country(country_code:"KR", country_name:"South Korea",emoji:"🇰🇷",countryPhoneCode:SelectCountryViewController.getCountryPhonceCode("KR")), at: 0)
        
        
    }
    
    func checkSearchBarActive() -> Bool {
        if searchBar.text != "" {
            return true
        }else {
            return false
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if checkSearchBarActive(){
            if countriesFiltered.count == 0{
                tableView.showEmptyScreen( "No Result Found".localized)
            }else{
                tableView.showEmptyScreen("")
            }
            return countriesFiltered.count
        }
        return countries.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        
        cell?.tintColor = selectionTintColor
        let contry: Country
        
        if checkSearchBarActive() {
            contry = countriesFiltered[indexPath.row]
        }else{
            contry = countriesModel[indexPath.row]
        }
        
        cell?.textLabel?.text = contry.emoji + " " + contry.country_name + " (" + contry.countryPhoneCode + ")"
        
        if selectedCountry != nil{
            cell?.accessoryType = .none
            if contry.country_name == selectedCountry.country_name{
                cell?.accessoryType = .checkmark
            }
        }
        
        return cell!
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedCountry = nil
        if checkSearchBarActive() {
            selectedCountry = countriesFiltered[indexPath.row]
        }else{
            selectedCountry = countriesModel[indexPath.row]
        }
        self.tableView.reloadData()
    }
    
}

extension SelectCountryViewController:UISearchBarDelegate{
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filtercountry(searchText)
    }
    
    func filtercountry(_ searchText: String) {
        countriesFiltered = countriesModel.filter({(country ) -> Bool in
            let value = country.country_name.lowercased().contains(searchText.lowercased()) || country.country_code.lowercased().contains(searchText.lowercased())
            return value
        })
        countriesFiltered = countriesFiltered.sorted { (country1, country2) -> Bool in
            return country1.country_name.compare(country2.country_name) == ComparisonResult.orderedAscending
        }
        tableView.reloadData()
    }
}
