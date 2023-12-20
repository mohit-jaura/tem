//
//  ContactsController.swift
//  TemApp
//
//  Created by Harpreet_kaur on 21/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
enum  ContactsSections: Int, CaseIterable {
    case facebook = 0
    case phone = 1
    
    var title: String {
        switch self {
        case .facebook:
            return "CONNECT FACEBOOK "
        case .phone:
            return "SYNC PHONE CONTACTS"
        }
    }
    var color: UIColor{
        switch self {
        case .facebook:
            return  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        case .phone:
            return #colorLiteral(red: 0.9686275125, green: 0.9686275125, blue: 0.9686275125, alpha: 1)
            
            }
        }
    var text: String{
        switch self {
        case .facebook:
            return "COMPLETE"
            
        case .phone:
            return "SYNC"
        }
    }
    var icon: UIImage {
        switch self {
        case .facebook:
            return #imageLiteral(resourceName: "complete")
        case .phone:
            return #imageLiteral(resourceName: "honeySelected")
        }
    }
}
class ContactsController: DIBaseController ,PhoneContactProtocol{
    
    // MARK: Variables.
    var selectedIndex:ContactsSections?
    var arrFbFriends:[FBFriendModal] = [FBFriendModal]()
    
    // MARK: IBOutlets.
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.clipsToBounds = false
        tableView.layer.masksToBounds = false
        tableView.layer.shadowColor = UIColor.black.cgColor
        tableView.layer.shadowOffset = CGSize(width: 2, height: 0)
        tableView.layer.shadowRadius = 5.0
        tableView.layer.shadowOpacity = 0.7
    }
    
    // MARK: ViewWillAppear.
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: Set Navigation
    func configureNavigation(){
        self.tableView.tableFooterView = UIView()
        let leftBarButtonItem = UIBarButtonItem(customView: getBackButton())
        self.setNavigationController(titleName: Constant.ScreenFrom.contacts.title, leftBarButton: [leftBarButtonItem], rightBarButtom: nil, backGroundColor: UIColor.white, translucent: true)
        self.navigationController?.setDefaultNavigationBar()
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: Function to get facebook friends.
    func getFbFriends(){
        if !self.isConnectedToNetwork() {
            return
        }
        self.showLoader()
        FacebookManager.shared.getFriendList(sucess: { (friendList) in
            self.arrFbFriends = friendList
            self.syncFacebookFriends()
        }, failure: { (error) in
            self.hideLoader()
            self.showAlert(message: error?.localizedDescription)
        })
    }
    
    //Sync facebook friend with our server.
    func syncFacebookFriends() {
        if !self.isConnectedToNetwork() {
            return
        }
        var arrFriends:[String] = [String]()
        for value in arrFbFriends {
            if let id = value.id {
                arrFriends.append(id)
            }
        }
        var param = PhoneContactsKey()
        param.valuesArray = arrFriends
        param.snsType = SyncContactsType.facebook
        DIWebLayerNetworkAPI().syncContacts(parameters: param.getDictionary(), success: { (response) in
            self.hideLoader()
            self.showAlert(message:response["message"] as? String ?? "")
        }) { (_) in
            self.hideLoader()
        }
    }
    
    // MARK: Sync friends with phone contacts.
    private func syncPhoneNumberContacts() {
        guard isConnectedToNetwork() else {
            return
        }
        self.showLoader()
        let contactsArr = self.fetchContacts(filter: .phoneNumber, shouldShowAlertForPermission: false)
        var phoneNumberArr:[String] = []
        if (contactsArr.count > 0) {
            for contacts in contactsArr {
                phoneNumberArr.append(contacts.phoneNumber.first?.removeSpecialCharacters ?? "")
            }
            var param = PhoneContactsKey()
            param.valuesArray = phoneNumberArr
            DIWebLayerNetworkAPI().syncContacts(parameters: param.getDictionary(), success: { (_) in
                self.hideLoader()
                self.showAlert(message: "Your contacts have been synced successfully.")
            }) { (error) in
                self.hideLoader()
                self.showAlert(message:error.message)
            }
        }
    }
}//Class.....



extension ContactsController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ContactsSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let currentSection = ContactsSections(rawValue: indexPath.row) {
            guard let cell:ContactsTableCell = tableView.dequeueReusableCell(withIdentifier: ContactsTableCell.reuseIdentifier, for: indexPath) as? ContactsTableCell else {
                return UITableViewCell()
            }
            cell.setData(section:currentSection,selectedSection: self.selectedIndex)
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let section = ContactsSections(rawValue: indexPath.row) {
            selectedIndex = section
            switch section {
            case .facebook:
                if !self.isConnectedToNetwork() {
                    return
                }
                FacebookManager.shared.login([.email, .publicProfile, .birthday, .friends], success: { (_) in
                    self.getFbFriends()
                    self.hideLoader()
                }, failure: { (_) in
                    self.hideLoader()
                }, onController: self)
            case .phone:
                self.syncPhoneNumberContacts()
            }
        }
        self.tableView.reloadData()
    }
}
