//
//  PostLikesController+TableViewDelegate&DataSource.swift
//  TemApp
//
//  Created by Harpreet_kaur on 26/04/19.
//  Copyright © 2019 Saurav. All rights reserved.
//

import Foundation
import UIKit


//MARK:-UITableViewDataSource&UITableViewDelegate
extension PostLikesController : UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if !(Reachability.isConnectedToNetwork()) {
            tableView.showEmptyScreen(AppMessages.AlertTitles.noInternet)
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return likedByFriends.count
        }else{
            return likedByOthers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell:UserListTableViewCell = tableView.dequeueReusableCell(withIdentifier: UserListTableViewCell.reuseIdentifier, for: indexPath) as? UserListTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        if indexPath.section == 0 {
            if indexPath.row == self.likedByFriends.count - 1 {
                cell.underLineView.isHidden = true
            }else{
                cell.underLineView.isHidden = false
            }
            cell.configureViewAt(indexPath: indexPath, user: self.likedByFriends[indexPath.row],likesScreen: true)
        }else{
            if indexPath.row == self.likedByOthers.count - 1 {
                cell.underLineView.isHidden = true
            }else{
                cell.underLineView.isHidden = false
            }
            cell.configureViewAt(indexPath: indexPath, user: self.likedByOthers[indexPath.row],likesScreen: true)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let nibView = Bundle.main.loadNibNamed(Constant.Xib.likesHeaderView , owner: self, options: nil)?.first as? LikesHeaderView
        if section == 0 {
            nibView?.headingLabel.text = "My Tēmate"
        }else{
            nibView?.headingLabel.text = "Others"
        }
        return nibView
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20))
        view.backgroundColor = .clear
        return view
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if self.likedByFriends.count == 0 {
                return 0
            }
        }else{
            if self.likedByOthers.count == 0 {
                return 0
            }
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let cornerRadius = 10
        var corners: UIRectCorner = []
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        {
            corners.update(with: .bottomLeft)
            corners.update(with: .bottomRight)
        }
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: cell.bounds,
                                      byRoundingCorners: corners,
                                      cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        cell.layer.mask = maskLayer
    }
    
}
