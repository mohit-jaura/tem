//
//  ProfileTableCell.swift
//  TemApp
//
//  Created by Harpreet_kaur on 26/03/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

protocol ViewPostDetailDelegate {
    func redirectToPostDetail(indexPath:IndexPath)
}

class ProfileTableCell: UITableViewCell {
    
    
    // MARK: Variables.
    private var arrStaticHeight = [210.0,140.0,]
    private var lastUsedLayout = 10
    var delegate:ViewPostDetailDelegate?
    var userPosts:[Post] = [Post]()
    // var isResponse:Bool = false
    
    // MARK: IBOutlets.
    @IBOutlet weak var profileCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initializeCell()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initializeCell() {
        profileCollectionView.delegate = self
        profileCollectionView.dataSource = self
        if let layout = profileCollectionView?.collectionViewLayout as? CustomFlowLayout {
            layout.delegate = self
        }
        self.profileCollectionView.register(UINib(nibName: GridCollectionCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: GridCollectionCell.reuseIdentifier)
    }
    
}


// MARK: UICollectionViewDelegate&UICollectionViewDataSource.
extension ProfileTableCell : UICollectionViewDelegate , UICollectionViewDataSource,CustomFlowLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.userPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell:GridCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: GridCollectionCell.reuseIdentifier, for: indexPath) as? GridCollectionCell else {
            return UICollectionViewCell()
        }
        if indexPath.row < self.userPosts.count {
            cell.setData(data: self.userPosts[indexPath.item].media?[0] ?? Media(), postType: self.userPosts[indexPath.item].type ?? PostType.normal)
            cell.soundButton.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
        var randomNumber = getRandomNumber()
        while lastUsedLayout == randomNumber {
            randomNumber =  getRandomNumber()
            continue
        }
        var height:CGFloat = 0
        let (_,remainder) = indexPath.row.quotientAndRemainder(dividingBy: 2)
        if (remainder == 1) {
            height = CGFloat(arrStaticHeight[remainder])
            arrStaticHeight = arrStaticHeight.reversed()
        } else {
            height = CGFloat(arrStaticHeight[remainder])
        }
        return height
    }
    
    
    func getRandomNumber() -> Int{
        let lower : UInt32 = 0
        let upper : UInt32 = UInt32(arrStaticHeight.count)
        let randomNumber = Int(arc4random_uniform(upper - lower) + lower)
        return randomNumber
        
    }
    
    // MARK: View Post Detail.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.redirectToPostDetail(indexPath: indexPath)
    }
    
    
}


extension ProfileTableCell : SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return GridCollectionCell.reuseIdentifier
    }
}

