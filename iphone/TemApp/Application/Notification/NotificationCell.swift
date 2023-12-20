//
//  NotificationCell.swift
//  Noah
//
//  Created by Harpreet_kaur on 21/03/18.
//  Copyright © 2018 Capovela LLC. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {
    
    
    // MARK: IBOutlets.
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var outerView: UIView!
    
    // MARK: UITableView Functions.
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configureView(isRead: Bool){
        userImageView.layer.cornerRadius = 13
        userImageView.layer.borderWidth = 1
        userImageView.layer.borderColor = UIColor.white.cgColor
        if isRead{
            messageLabel.textColor = UIColor.white
            outerView.backgroundColor = UIColor(r: 120, g: 120, b: 128).withAlphaComponent(0.6)
        }else{
            messageLabel.textColor = UIColor.black
            outerView.backgroundColor = UIColor.white
        }
    }
    
    // MARK: Function to SetData.
    func setData(data:[Notifications],index:Int, challengeImageType: Int) {
        let modifiedFont = String(format:"<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: \(messageLabel.font!.pointSize)\">%@</span>", data[index].message ?? "")
        messageLabel.attributedText = modifiedFont.html2String
        messageLabel.lineBreakMode = .byTruncatingTail
        if challengeImageType == 8 || challengeImageType == 9{ // for showing the image of goal and challenge
            if let imageUrl = data[index].goalChallengeImage {
                let url = URL(string: imageUrl)
                userImageView.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "user-dummy"))
            }else{
                userImageView.image = #imageLiteral(resourceName: "user-dummy")
            }
        }else{
            if let imageUrl = data[index].userImage {
                let url = URL(string: imageUrl)
                userImageView.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "user-dummy"))
            }else{
                userImageView.image = #imageLiteral(resourceName: "user-dummy")
            }
            
        }
        
      
        if let time = data[index].createdAt {
            timeLabel.text = time.convertDateFormatFromUTCToLocal(currentformat: .preDefined, with: .displayDate)
        }
    }
}
