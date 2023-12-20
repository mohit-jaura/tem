//
//  PostView.swift
//  TemApp
//
//  Created by Harpreet_kaur on 26/03/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

class PostView: UIView {

    // MARK: IBOutlets.
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var postTimeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var firstFriendImageView: UIImageView!
    @IBOutlet weak var secondFriendImageView: UIImageView!
    @IBOutlet weak var thirdFriendImageView: UIImageView!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var loginUserImageView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    
    
    // MARK: IBActions.
    // MARK: Action for Likes, Comments and Share.
    @IBAction func postsActions(_ sender: UIButton) {
        switch sender.tag {
        case 0:  //For Like.
            break
        case 1:  //For Comments.
            break
        case 2:  //For Share.
            break
        default:
            break
        }
    }
    
    // MARK: Dots Action.
    @IBAction func dotsAction(_ sender: UIButton) {
    }
    

}
