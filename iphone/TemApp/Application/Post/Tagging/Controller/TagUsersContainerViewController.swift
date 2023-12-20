//
//  TagUsersContainerViewController.swift
//  TemApp
//
//  Created by shilpa on 26/12/19.
//

import UIKit
protocol TagUsersContainerViewDelegate: AnyObject {
    func didAddNewTaggedUser(user: Friends)
}
class TagUsersContainerViewController: UIViewController, UISearchBarDelegate {

    // MARK: Properties
    private var usersListingController: TagUsersListViewController?
    weak var delegate: TagUsersContainerViewDelegate?
    var screenFrom: Constant.ScreenFrom = .createGoal
    // MARK: IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: IBActions
    @IBAction func cancelTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTagUsersListingScreen" {
            self.usersListingController = segue.destination as? TagUsersListViewController
            usersListingController?.delegate = self
            usersListingController?.screenFrom = self.screenFrom
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.isLoading = true
        self.usersListingController?.tagging(searchUser: searchText)
    }
}

// MARK: TagUsersListViewDelegate
extension TagUsersContainerViewController: TagUsersListViewDelegate {
    func didSelectUserToTag(user: Friends) {
        self.delegate?.didAddNewTaggedUser(user: user)
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadedSearchResultsForPictureTagging() {
        self.searchBar.isLoading = false
    }
}
