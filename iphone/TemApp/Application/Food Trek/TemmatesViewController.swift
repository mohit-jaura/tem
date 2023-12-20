//
//  TemmatesViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 07/03/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class TemmatesViewController: DIBaseController {
    
    // MARK: Outlets
    @IBOutlet weak var searchShadowView: SSNeumorphicView!{
        didSet{
            searchShadowView.viewDepthType = .innerShadow
            searchShadowView.viewNeumorphicCornerRadius = searchShadowView.frame.height / 2
            searchShadowView.viewNeumorphicMainColor = #colorLiteral(red: 0.2431372702, green: 0.2431372702, blue: 0.2431372702, alpha: 1).cgColor
            searchShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
            searchShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        }
    }

    @IBOutlet weak var lineShadowView:  SSNeumorphicView! {
        didSet{
            lineShadowView.viewDepthType = .outerShadow
            lineShadowView.viewNeumorphicCornerRadius = 12
            lineShadowView.viewNeumorphicMainColor = #colorLiteral(red: 0.2431372702, green: 0.2431372702, blue: 0.2431372702, alpha: 1).cgColor
            lineShadowView.viewNeumorphicLightShadowColor = UIColor.clear.cgColor
            lineShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        }
    }
    @IBOutlet weak var selectedContactLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: Variables
    var friends:[Friends] = [Friends]()
    var addedFriends = [[String: Any]]()
    var FriendsStorageArray: [Int] = []
    var isFriendSearched = false
    var isAllSelected: Int?
    var screenFrom: Constant.ScreenFrom = .foodTrek

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    // MARK: Helper Function
    
    func initialize(){
        self.showLoader()
        searchBar.delegate = self
        getFriends(searchText: nil)
        searchBar.setImage(UIImage(named: "searchGray"), for: .search, state: .normal)
    }
    
    func getFriends(searchText: String?){
        if searchText == nil {
            self.getFriendList()
        } else {
            self.getFriendListWithSearch(text: searchText ?? "")
        }
        
    }
    func getFriendListWithSearch(text: String?){
        let type = screenFrom == .foodTrek ? 1 : 2
        DIWebLayerFoodTrek().getFriendList(type: type, parameters: nil, searchString: text) { response, count, isAllFriendSelected in
            self.friends = response
            self.isAllSelected = isAllFriendSelected
            print(response)
            self.tableView.reloadData()
        } failure: { error in
            print(error)
        }
    }
    func getFriendList(){
        isFriendSearched = false
        let type = screenFrom == .foodTrek ? 1 : 2
        DIWebLayerFoodTrek().getFriendList(type: type, parameters: nil) { response, count , isAllFriendSelected in
            self.hideLoader()
            self.isAllSelected = isAllFriendSelected
            self.friends = response
            self.tableView.reloadData()
            self.tableView.hideSkeleton()
        } failure: { error in
            self.hideLoader()
            self.showAlert( message: error.message, okayTitle: "ok")
            self.tableView.hideSkeleton()
        }
    }
    func addFriendsServerCall(){
        let type = screenFrom == .foodTrek ? 1 : 2
        DIWebLayerFoodTrek().addFriend(params:["foodtrekIds": addedFriends, "isAllSelected": isAllSelected ?? 0, "type": type], success: { (response) in
            self.hideLoader()
            print(response)
                self.getFriendList()
                self.tableView.reloadData()
        }) { (error) in
            print(error)
            self.hideLoader()
            self.showAlert(message: "\(error.message)", okayTitle: "ok")
        }
    }
    private func generateCurrentDayTimeStamp() -> Int{
        let date = Date()
        return date.timeStamp
    }
    
    // MARK: IBAction
    @IBAction func allSelectedTapped(_ sender: UIButton) {
        self.showLoader()
        let dateTimeStamp = self.generateCurrentDayTimeStamp()
        addedFriends.removeAll()
        for friend in friends {
            let addedTemates = Temmates(userId: friend.user_id ?? "", isUserAdded: 1, todaysDate: dateTimeStamp).getDictionary()
            if let selectedFriends = isAllSelected{
                if selectedFriends == 0 {
                    if let temmates = addedTemates{
                        addedFriends.append(temmates)
                    }
                }
            }else{
                addedFriends.removeAll()
            }
        }
        if addedFriends.count == friends.count{
            isAllSelected = 1
        }else{
            isAllSelected = 0
        }
        addFriendsServerCall()
    }
    
    @IBAction func backTapped(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true)
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        self.showLoader()
        let dateTimeStamp = self.generateCurrentDayTimeStamp()
        addedFriends.removeAll()
        
        for friend in FriendsStorageArray{
            let addedTemates = Temmates(userId: friends[friend].user_id ?? "", isUserAdded: 1, todaysDate: dateTimeStamp).getDictionary()
            if let temmates = addedTemates{
                addedFriends.append(temmates)
            }
        }
        isAllSelected = 0
        if addedFriends.count > 0 {
            addFriendsServerCall()
        }
        self.dismiss(animated: true)
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate
extension TemmatesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        getFriends(searchText: searchText)
        isFriendSearched = true
        tableView.reloadData()
    }
}


// MARK: UITableViewDataSource, UITableViewDelegate
extension TemmatesViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell:TemmatesTableViewCell = tableView.dequeueReusableCell(withIdentifier: TemmatesTableViewCell.reuseIdentifier, for: indexPath) as? TemmatesTableViewCell else {
            return UITableViewCell()
        }
        
        if isFriendSearched{
            cell.isSearchedFriendSelected = true
        }else{
            cell.isSearchedFriendSelected = false
        }
        cell.addTematesDelegate = self
        cell.addButton.tag = indexPath.row
        cell.setData(friends: self.friends[indexPath.row], indexRow: indexPath.row)
        return cell
        
    }
}

// MARK: AddTematesDelegate
extension TemmatesViewController: AddTematesDelegate{
    func addTemates(userId: Int, isAlreadyAdded: Bool) {// Here we are storing the data in a dummy array instead of storing in actual array (addedFriends) for the ease of removing an element before hitting the api
        var isDeleted = false
        for values in FriendsStorageArray {
            if FriendsStorageArray.contains(userId) && isAlreadyAdded == false && userId == values{
                if let index = FriendsStorageArray.index(of: values) {
                    FriendsStorageArray.remove(at: index)
                }
                isDeleted = true
                break
            }
        }
        if !isDeleted && isAlreadyAdded{
            FriendsStorageArray.append(userId)
        }
         FriendsStorageArray = Array(Set(FriendsStorageArray))
        selectedContactLabel.text = "\(FriendsStorageArray.count) CONTACTS SELECTED"
    }
    
}

