//
//  SelectTematesViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 04/05/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Combine
import SSNeumorphicView
import UIKit

class SelectTematesViewController: DIBaseController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBarView: SSNeumorphicView!
    @IBOutlet weak var searchBarCancelBtn: UIButton!
    @IBOutlet weak var searchBar: UITextField!

    // MARK: Variables

    var friendsPageNo: Int = 1
    var shouldFriendsShowMore: Bool = false
    var arrFriends: [Friends] = .init()
    var searchedFriends: [Friends] = .init()
    let networkManager = NetworkConnectionManager()
    var hasAllFriendsDataLoaded: Bool = false
    let paginationLimit = 15
    var userIds: [String] = []
    var cancellable = [AnyCancellable]()
    var isSearchActive: Bool = false {
        didSet {
            if self.isSearchActive {
                self.searchBarCancelBtn.isEnabled = true
                self.searchBarCancelBtn.setTitleColor(.white, for: .normal)
                self.shouldFriendsShowMore = false
            } else {
                self.searchBarCancelBtn.isEnabled = false
                self.searchBarCancelBtn.setTitleColor(.gray, for: .normal)
                self.shouldFriendsShowMore = true
            }
        }
    }

    var searchedText: String = ""
    var createToDoVc: CreateTodoController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerViews()
        self.getFriendList()
        self.isSearchActive = false
        self.applyCombineSearch()
        self.searchBarView.viewNeumorphicMainColor = UIColor.black.cgColor
        self.searchBarView.viewDepthType = .innerShadow
        self.searchBarView.viewNeumorphicCornerRadius = self.searchBarView.bounds.height / 2
        self.searchBarView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
        self.searchBarView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        self.searchBar.delegate = self
        self.searchBar.attributedPlaceholder = NSAttributedString(
            string: self.searchBar.placeholder ?? "Search",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
    }

    // MARK: IBAction

    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func saveTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.createToDoVc?.memberIds = self.userIds
    }

    @IBAction func searchBarCancelTapped(_ sender: UIButton) {
        self.isSearchActive = false
        self.searchBar.text = nil
        view.endEditing(true)
        self.tableView.reloadData()
    }

    // MARK: Helper function

    private func registerViews() {
        self.tableView.registerNibs(nibNames: [NetworkFooter.reuseIdentifier, TematesTableCell.reuseIdentifier])
    }

    private func getFriendList() {
        if !self.isConnectedToNetwork() {
            return
        }
        self.networkManager.getFriendList(pageNo: self.friendsPageNo, parameters: nil, success: { data, _ in
            self.setFriendListData(data: data)
        }, failure: { _ in
            self.hasAllFriendsDataLoaded = true
            self.shouldFriendsShowMore = false
            self.tableView.reloadData()
        })
    }

    private func getSearchedFriendList() {
        if !self.isConnectedToNetwork() {
            return
        }
        self.networkManager.getFriendListFromSearch(text: self.searchedText, parameters: nil, pageNo: 1, success: { data, _ in
            self.setFriendListData(data: data)
        }, failure: { _ in
            self.hasAllFriendsDataLoaded = true
            self.shouldFriendsShowMore = false
            self.tableView.reloadData()
        })
    }

    private func setFriendListData(data: [Friends]) {
        if data.count >= self.paginationLimit {
            self.friendsPageNo = self.friendsPageNo + 1
            self.shouldFriendsShowMore = true
        }
        for value in data {
            if self.isSearchActive {
                if !self.searchedFriends.contains(where: { $0.id == value.id }) {
                    self.searchedFriends.append(value)
                }
            } else {
                if !self.arrFriends.contains(where: { $0.id == value.id }) {
                    self.arrFriends.append(value)
                }
            }
        }
        if self.isSearchActive {
            self.searchedFriends = self.searchedFriends.sorted {
                if let firstFname = $0.firstName, let secondLname = $1.firstName {
                    return firstFname.localizedCaseInsensitiveCompare(secondLname) == ComparisonResult.orderedAscending
                }
                return true
            }
        } else {
            self.arrFriends = self.arrFriends.sorted {
                if let firstFname = $0.firstName, let secondLname = $1.firstName {
                    return firstFname.localizedCaseInsensitiveCompare(secondLname) == ComparisonResult.orderedAscending
                }
                return true
            }
        }
        self.hasAllFriendsDataLoaded = true
        self.tableView.reloadData()
    }

    // Initialise the publisher and subscriber for search
    private func applyCombineSearch() {
        let publisher = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self.searchBar)
        publisher
            .map {
                ($0.object as! UITextField).text
            }
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink(receiveValue: { _ in
                DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                    // Use search text and perform the query
                    DispatchQueue.main.async {
                        // Update UI
                        self?.searchedText = ""
                        guard let filter = self?.searchBar.text else { return }
                        if !filter.isBlank {
                            self?.isSearchActive = true
                            self?.searchedText = filter
                            self?.searchedFriends.removeAll()
                            self?.getSearchedFriendList()
                        } else {
                            self?.isSearchActive = false
                            self?.tableView.reloadData()
                        }
                    }
                }
            })
            .store(in: &self.cancellable)
    }
}

// MARK: NetworkFooterDelegate

extension SelectTematesViewController: NetworkFooterDelegate {
    func showMoreTapped(section: Int) {
        if !self.isConnectedToNetwork() {
            return
        }
        let currentPage = Utility.shared.currentPageNumberFor(currentRequestsCount: self.arrFriends.count, paginationLimit: self.paginationLimit)
        self.friendsPageNo = currentPage + 1
        self.hasAllFriendsDataLoaded = false
        self.shouldFriendsShowMore = false
        self.tableView.reloadData()
        if self.isSearchActive {
            self.getSearchedFriendList()
        } else {
            self.getFriendList()
        }
    }
}

extension SelectTematesViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearchActive { return self.searchedFriends.count }
        return self.arrFriends.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: TematesTableCell = tableView.dequeueReusableCell(withIdentifier: TematesTableCell.reuseIdentifier) as? TematesTableCell else { return UITableViewCell() }
        var friend = Friends()
        if self.isSearchActive {
            friend = self.searchedFriends[indexPath.row]
        } else {
            friend = self.arrFriends[indexPath.row]
        }
        cell.userNAmeLabel.text = friend.fullName.capitalized
        cell.addButton.tag = indexPath.row
        cell.addButtonIndex = { [self] _ in
            let arrIndex = friend.user_id ?? ""
            if self.userIds.contains(arrIndex) {
                if let index = userIds.firstIndex(of: arrIndex) {
                    self.userIds.remove(at: index)
                }
            } else {
                self.userIds.append(arrIndex)
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footer = tableView.dequeueReusableCell(withIdentifier: NetworkFooter.reuseIdentifier) as? NetworkFooter else { return UIView() }
        footer.btnShowMore.tag = section
        footer.delegate = self
        footer.contentView.backgroundColor = .black
        footer.btnShowMore.isUserInteractionEnabled = true
        footer.configureSection(hasDataLoaded: self.hasAllFriendsDataLoaded, shouldShowMore: self.shouldFriendsShowMore)
        var count = 0
        if self.isSearchActive {
            count = self.searchedFriends.count
        } else {
            count = self.arrFriends.count
        }
        if self.hasAllFriendsDataLoaded {
            if count == 0 && !self.shouldFriendsShowMore {
                footer.btnShowMore.isUserInteractionEnabled = false
                footer.btnShowMore.setTitle(AppMessages.NetworkMessages.noFriendsYet, for: .normal)
                // footer.btnShowMore.layer.borderColor = UIColor.clear.cgColor
            }
        }
        return footer
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.hasAllFriendsDataLoaded == false {
            return 40
        }
        if !self.shouldFriendsShowMore && self.arrFriends.count > 0 {
            return 0.001
        }
        return 40
    }
}

extension SelectTematesViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.isSearchActive = true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.isSearchActive = false
        self.tableView.reloadData()
    }
}
