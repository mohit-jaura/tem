//
//  SuggestionTableCell.swift
//  TemApp
//
//  Created by Harpreet_kaur on 30/03/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

protocol SuggestedFriendPaginationProtocol {
    func callLoadMoreData()
}

class SuggestionTableCell: UITableViewCell {
    
    // MARK: Variables.
    var suggestionList:[Friends] = [Friends]()
    var isResponse:Bool = false
    var delegate:SuggestedFriendPaginationProtocol?
    // MARK: IBOutlets.
    @IBOutlet weak var suggestionCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initializeCell()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    // MARK: Custom Function
    // MARK: Intialize Cell
    func initializeCell() {
        let heightOfItem = suggestionCollectionView.frame.height - 5
        if let layout = suggestionCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = CGSize(width: suggestionCollectionView.frame.width/3, height: heightOfItem)
            layout.itemSize = UICollectionViewFlowLayout.automaticSize
        }
        suggestionCollectionView.delegate = self
        suggestionCollectionView.dataSource = self
        self.suggestionCollectionView.register(UINib(nibName: FriendSuggestionCollectionCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: FriendSuggestionCollectionCell.reuseIdentifier)
    }
}




// MARK: UICollectionViewDelegate&UICollectionViewDataSource.
extension SuggestionTableCell : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.suggestionList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell:FriendSuggestionCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: FriendSuggestionCollectionCell.reuseIdentifier, for: indexPath) as? FriendSuggestionCollectionCell else {
            return UICollectionViewCell()
        }
        cell.delegate = self
        if indexPath.item < self.suggestionList.count {
            cell.setData(data: self.suggestionList[indexPath.item],index:indexPath.item)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let heightOfItem = suggestionCollectionView.frame.height - 5
        return CGSize(width: suggestionCollectionView.frame.width/3, height: heightOfItem)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == suggestionCollectionView {
            if ((scrollView.contentOffset.x + scrollView.frame.size.width) >=
                scrollView.contentSize.width) {
                delegate?.callLoadMoreData()
            }
        }
    }
    
}



extension SuggestionTableCell: SkeletonCollectionViewDataSource {
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return FriendSuggestionCollectionCell.reuseIdentifier
    }
}

// MARK: Send or Cancel Request.
extension SuggestionTableCell:AddFriendDelegate {
    func friendRequestSent(button: UIButton) {
        let networkConnectionManager = NetworkConnectionManager()
        let index = button.tag
        let indexPath = IndexPath(item: index, section: 0)
        let friend:Friends = self.suggestionList[index]
        
        if let id = friend.id {
            guard User.sharedInstance.id != id else {return}
            let params:FriendRequest = FriendRequest(friendId:id)
            if let friendStatus = friend.friendStatus , friendStatus == FriendStatus.requestSent {
                networkConnectionManager.deleteRequest(params: params.getDictionary(), success: { (response)  in
                    button.isEnabled = true
                    if index < self.suggestionList.count {
                        self.suggestionList[index].friendStatus = FriendStatus.other
                        self.reloadCollectionCell(indexPath: indexPath)
                    }
                }) { (error) in
                    button.isEnabled = true
                    self.reloadCollectionCell(indexPath: indexPath)
                    Utility.showPopupOnTopViewController(message: error.message)
                }
            }else {
                networkConnectionManager.sendRequest(params: params.getDictionary(), success: { (response)  in
                    if index < self.suggestionList.count {
                        self.suggestionList[index].friendStatus = FriendStatus.requestSent
                        self.reloadCollectionCell(indexPath: indexPath)
                    }
                    button.isEnabled = true
                }) { (error) in
                    button.isEnabled = true
                    self.reloadCollectionCell(indexPath: indexPath)
                    Utility.showPopupOnTopViewController(message: error.message)
                }
            }
            
        }
    }
    
    func cancelButtonPressed(index: Int) {
    }
    
    func reloadCollectionCell(indexPath:IndexPath) {
        if let cell = self.suggestionCollectionView.cellForItem(at: indexPath) as? FriendSuggestionCollectionCell {
            cell.setData(data: self.suggestionList[indexPath.item], index: indexPath.item)
        }
    }
    
}//Extension.....
