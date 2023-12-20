//
//  ChatSearchHeaderTableCell.swift
//  TemApp
//
//  Created by Harpreet Gill on 02/09/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import SSNeumorphicView
import UIKit

protocol ChatSearchHeaderDelegate: AnyObject {
    func didClickOnAddButton()
    func didEnterTextInSearchBar(text: String)
    func searchBarCleared()
    func didStartSearch()
    func didEndEditingSearchBar()
}

class ChatSearchHeaderTableCell: UITableViewHeaderFooterView, UISearchBarDelegate {
    
    // MARK: Variables.
    weak var delegate:ChatSearchHeaderDelegate?
    
    // MARK: IBOutlets.
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var shadowView: SSNeumorphicView!
    @IBOutlet weak var navigationView: SSNeumorphicView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var upperView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.searchBar.backgroundColor = UIColor.white
        self.searchBar.barTintColor = UIColor.white
        if #available(iOS 13, *) {
            self.searchBar.searchTextField.backgroundColor = UIColor.white
        }
        // Initialization code
    }

    // MARK: IBActions.
    @IBAction func addFriendTapped(_ sender: UIButton) {
        self.delegate?.didClickOnAddButton()
    }
    
    func initialize(groupInfo: ChatRoom?) {
        addFriendButton.isHidden = false
        if groupInfo?.groupChatStatus == .notPartOfGroup {
            addFriendButton.isHidden = true
        } else {
            //check if the group is closed or open, if it is closed, only admin can add/remove participants. If it is open any of the member can add remove
            if groupInfo?.editableByMembers == false {
                if UserManager.getCurrentUser()?.id != groupInfo?.admin?.userId {
                    addFriendButton.isHidden = true
                }
            }
        }
    }
    
    func initUIForLeaderBoard() {
        self.searchBar.backgroundColor = UIColor.appThemeDarkGrayColor
        self.searchBar.barTintColor = UIColor.appThemeDarkGrayColor
        searchBar.searchTextField.tintColor = UIColor.white
        if let url = URL(string: "") {
            searchBar.setImage(url: url, placeholder: UIImage(named: "AddWhite"))
        }
        if #available(iOS 13, *) {
            self.searchBar.searchTextField.backgroundColor = UIColor.appThemeDarkGrayColor
        }
        shadowView.setOuterDarkShadow()
        shadowView.viewDepthType = .innerShadow
        shadowView.viewNeumorphicCornerRadius = shadowView.frame.height / 2
        mainView.backgroundColor = UIColor.appThemeDarkGrayColor
        upperView.backgroundColor = UIColor.appThemeDarkGrayColor
        addFriendButton.setImage(UIImage(named: "AddWhite"), for: .normal)
        navigationView.isHidden = false
        navigationView.viewDepthType = .innerShadow
        navigationView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
        navigationView.viewNeumorphicLightShadowColor = UIColor.appThemeDarkGrayColor.withAlphaComponent(1).cgColor
        navigationView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        navigationView.viewNeumorphicCornerRadius = 0
        searchImageView.isHidden = false
    }
    // MARK: UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let currentText = searchBar.text {
            if !currentText.isEmpty {
                self.delegate?.didEnterTextInSearchBar(text: searchText)
            } else {
                self.delegate?.searchBarCleared()
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.delegate?.didStartSearch()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.delegate?.didEndEditingSearchBar()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.delegate?.didEndEditingSearchBar()
    }
}
