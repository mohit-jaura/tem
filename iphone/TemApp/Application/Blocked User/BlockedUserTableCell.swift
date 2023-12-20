//
//  BlockedUserTableCell.swift
//  TemApp
//
//  Created by Mac Test on 27/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
protocol BlockedUserTableCellDelegate: AnyObject {
    func redirectToUserProfile(indexPath:IndexPath)
    func unBlockUser(indexPath:IndexPath)
}

class BlockedUserTableCell: UITableViewCell {
    
    // MARK: Variables.
    weak var delegate:BlockedUserTableCellDelegate?
    let neumorphicShadow = NumorphicShadow()
    // MARK: IBOutlets.
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var unblockButton: UIButton!
    @IBOutlet weak var backView: SSNeumorphicView! {
        didSet{
            neumorphicShadow.addNeumorphicShadow(view: backView, shadowType: .outerShadow, cornerRadius: 8, shadowRadius: 0.8, mainColor: UIColor(red: 247.0 / 255.0, green: 247.0 / 255.0, blue: 247.0 / 255.0, alpha: 1).cgColor, opacity:  0.8, darkColor:UIColor(red: 163.0 / 255.0, green: 177.0 / 255.0, blue: 198.0 / 255.0, alpha: 0.5).cgColor, lightColor:UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.3).cgColor, offset: CGSize(width: 2, height: 3))
        }
    }
    // MARK: UITableViewCell
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //This function will add gesture to UserImageView and UserNameLabel.
    ///After clicking on it user will redirect to other user profile.
    func addGestures() {
        let tapLabel = UITapGestureRecognizer(target: self, action: #selector(redirectToUserProfile))
        userNameLabel.isUserInteractionEnabled = true
        userNameLabel.addGestureRecognizer(tapLabel)
        let tapImageView = UITapGestureRecognizer(target: self, action: #selector(redirectToUserProfile))
        userImageView.isUserInteractionEnabled = true
        userImageView.addGestureRecognizer(tapImageView)
    }
    // MARK: Function to setData.
    func configureCell(indexPath:IndexPath,data:Friends) {
        self.addGestures()
        unblockButton.tag = indexPath.row
        userNameLabel.tag = indexPath.row
        userImageView.tag = indexPath.row
        userNameLabel.text = data.fullName
        if let imageUrl = URL(string:data.profilePic ?? "") {
            self.userImageView.kf.setImage(with: imageUrl, placeholder:#imageLiteral(resourceName: "user-dummy"))
        }else{
            self.userImageView.image = #imageLiteral(resourceName: "user-dummy")
        }
    }
    
    // MARK: Function for redirection.
    @objc func redirectToUserProfile(recognizer: UITapGestureRecognizer) {
        guard let view = recognizer.view  else {
            return
        }
        let indexPath = IndexPath(row: view.tag, section: 0)
        self.delegate?.redirectToUserProfile(indexPath:indexPath)
    }
    @IBAction func unblockAction(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        self.delegate?.unBlockUser(indexPath:indexPath)
    }
}
