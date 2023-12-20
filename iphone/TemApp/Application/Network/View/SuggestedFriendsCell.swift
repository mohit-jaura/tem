//
//  SuggestedFriendsCell.swift
//  VIZU
//
//  Created by shubam on 08/10/18.
//  Copyright © 2018 Capovela LLC. All rights reserved.
//

import UIKit
class SuggestedFriendHeader:UITableViewCell{
    
    @IBOutlet weak var noFbLoginView: UIView!
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    
    var hasMore:Bool = false
    var hasErrorOccured:Bool = false
    var arrSuggstedFriends:[Friends]?
    var controller:NetworkViewController?
    
    func setVisibilty() {
        if FacebookManager.shared.getToken() == nil {
            self.noFbLoginView.isHidden = false
            self.collectionView.isHidden = true
        } else {
            self.noFbLoginView.isHidden = true
        }
    }

}
extension SuggestedFriendHeader:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        setVisibilty()
        
        if let friends = self.arrSuggstedFriends {
            if friends.count == 0  {
                if !hasErrorOccured {
                    self.collectionView.setEmptyMessage(AppMessages.NetworkMessages.noFbFriends)
                } else {
                    self.collectionView.setEmptyMessage(AppMessages.NetworkMessages.retryErrorMessage)
                }
            } else {
                self.collectionView.restore()
            }
            return friends.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
       guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SuggestedFriendsCell.reuseIdentifier, for: indexPath) as? SuggestedFriendsCell else {return UICollectionViewCell()}
       if let friends = self.arrSuggstedFriends {
            if friends.count > indexPath.item {
                cell.setData(friendData: friends[indexPath.item])
            }
       }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 33.0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var footerView:CollectionViewLoadMore!
        
        if (kind == UICollectionView.elementKindSectionFooter) {
            footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionViewLoadMore.reuseIdentifier, for: indexPath as IndexPath) as? CollectionViewLoadMore
            footerView.activityIndicaorView.startAnimating()
        }
        return footerView
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        return (!hasMore) ? .zero : CGSize(width: self.collectionView.frame.width/4, height: 150)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if(indexPath.row == (arrSuggstedFriends?.count)!-1){
            if hasMore {
                if let networkVc = controller {
                    networkVc.getSuggestedFriends()
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let count = self.arrSuggstedFriends?.count,let vc = self.controller {
            if count > indexPath.item {
                if let id:String = self.arrSuggstedFriends?[indexPath.item].id {
                    vc.redirectToUserProfileController(id: id)
                }
            }
        }
    }
}

class SuggestedFriendsCell: UICollectionViewCell {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var frndImgVw: UIImageView!
    
    func setData(friendData:Friends) {
        if let fname = friendData.firstName , let lname = friendData.lastName {
            self.nameLbl.text = fname + " " + lname
            if let strUrl = friendData.profilePic,let url = URL(string: strUrl) {
                self.frndImgVw.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "dummy"))
            }
        }
     
    }
}
