//
//  TagPeopleViewController+UICollectionView.swift
//  TemApp
//
//  Created by shilpa on 17/12/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation

// MARK: UICollectionViewDataSource
extension TagPeopleViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.media.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagPhotoCollectionViewCell.reuseIdentifier, for: indexPath) as? TagPhotoCollectionViewCell else {
            return UICollectionViewCell()
        }
        print("cell for item at row: \(indexPath.item)")
        cell.delegate = self
        cell.initializeAt(indexPath: indexPath, media: media[indexPath.item], hasLoaded: self.hasLoaded)
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension TagPeopleViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? TagPhotoCollectionViewCell {
            cell.removeLastCrossEnabled()
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension TagPeopleViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
}

// MARK: TagPhotoCollectionCellDelegate
extension TagPeopleViewController: TagPhotoCollectionCellDelegate {
    func updateTagPoint(newPoint: CGPoint, taggedUserId: String) {
        if let taggedPeople = self.media[currentMediaIndex].taggedPeople {
            //fetch the user tag from tagged people array and update the location
            if let index = taggedPeople.firstIndex(where: { (userTag) -> Bool in
                if let userId = userTag.taggedUser?.user_id {
                    return userId == taggedUserId
                }
                return false
            }) {
                media[currentMediaIndex].taggedPeople?[index].centerY = newPoint.y
                media[currentMediaIndex].taggedPeople?[index].centerX = newPoint.x
            }
        }
    }
    
    func updateTagListAt(index: Int) {
        if let count = self.media[currentMediaIndex].taggedPeople?.count,
            index < count {
            self.media[currentMediaIndex].taggedPeople?.remove(at: index)
            self.totalTaggedCount -= 1
        }
    }
    
    func didTapOnPhotoAtPosition(position: CGPoint, atItem item: Int) {
        /*
         If the media type "image" is tapped, then save the tapped location,
         If the media type "video" is tapped, then we need not to save the tapped location.
        */
        
        if let type = self.media[item].type {
            currentMediaIndex = item
            switch type {
            case .photo:
                //save the location
                currentTappedLocation = (position.x, position.y)
                self.presentUsersListingToTag()
            case .video:
                self.presentUsersListingToTag()
            case .pdf:
                break
                
            }
        }
    }
}
