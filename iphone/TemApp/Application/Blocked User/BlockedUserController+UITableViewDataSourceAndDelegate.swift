//
//  BlockedUserController+UITableViewDataSourceAndDelegate.swift
//  TemApp
//
//  Created by Mac Test on 27/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit

// MARK: UITableViewDelegate And UITableViewDataSource.
extension BlockedUserController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        blockedUserArray.count == 0 ? tableView.showEmptyScreen(tableMessage) : tableView.showEmptyScreen("")
        return blockedUserArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 99
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell:BlockedUserTableCell = blockedUserTableView.dequeueReusableCell(withIdentifier: BlockedUserTableCell.reuseIdentifier) as? BlockedUserTableCell else{
            return UITableViewCell()
        }
        cell.configureCell(indexPath: indexPath, data: self.blockedUserArray[indexPath.row])
        cell.delegate = self
        return cell
    }
}

//BlockedUserTableCellDelegate
extension BlockedUserController: BlockedUserTableCellDelegate {
    
    func redirectToUserProfile(indexPath: IndexPath) {
    }
    
    func unBlockUser(indexPath: IndexPath) {
        if indexPath.row >= self.blockedUserArray.count {
            return 
        }
        self.showLoader()
        let data = self.blockedUserArray[indexPath.row]
        var params: BlockUser = BlockUser()
        params.friendId = data.id ?? ""
        NetworkConnectionManager().unBlockUser(params: params.getDictionary(), success: { [weak self] (_) in
            self?.hideLoader()
           self?.blockedUserArray.remove(at: indexPath.row)
           self?.blockedUserTableView.deleteRows(at: [indexPath], with: .automatic)
        }) {[weak self] (error) in
            self?.hideLoader()
            self?.showAlert(message: error.message ?? "")
        }
    }
}
