//
//  FriendSuggestionCollectionCell.swift
//  TemApp
//
//  Created by Harpreet_kaur on 25/03/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

class FriendSuggestionCollectionCell: UICollectionViewCell {
    
    // MARK: Variables.
    weak var delegate:AddFriendDelegate?
    
    // MARK: IBOutlets.
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userLocation: UILabel!
    @IBOutlet weak var sendRequestButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: Custom Function.
    // MARK: Set data to cell
    func setData(data:Friends,index:Int) {
        sendRequestButton.tag = index
        if let imageUrl = URL(string:data.profilePic ?? "") {
            self.userImageView.kf.setImage(with: imageUrl, placeholder:#imageLiteral(resourceName: "user-dummy"))
        }else{
            self.userImageView.image = #imageLiteral(resourceName: "user-dummy")
        }
        userName.text = data.fullName
        sendRequestButton.borderColor = appThemeColor
        sendRequestButton.setTitleColor(appThemeColor, for: .normal)
        if let friendStatus = data.friendStatus {
            switch friendStatus {
            case .requestSent:
                sendRequestButton.setTitle("Undo", for: .normal)
            default:
                sendRequestButton.setTitle("Send request", for: .normal)
            }
        } else {
            sendRequestButton.setTitle("Send request", for: .normal)
        }
        userLocation.text = "\(data.address?.city ?? "") \(data.address?.city ?? "")".trim
    }
    
    // MARK: Adjust the height of cell.
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        super.preferredLayoutAttributesFitting(layoutAttributes)
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var newFrame = layoutAttributes.frame
        newFrame.size.height = ceil(size.height)
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
    
    //AMRK:-IBActions.
    @IBAction func sendRequestTapped(_ sender: UIButton) {
        sender.borderColor = .gray
        sender.setTitleColor(.gray, for: .normal)
        sender.isEnabled = false
        delegate?.friendRequestSent(button: sender)
    }
    
    
}
