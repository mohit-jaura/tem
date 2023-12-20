//
//  ChatListTableViewCell.swift
//  TemApp
//
//  Created by shilpa on 10/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class ChatListTableViewCell: UITableViewCell {
    
    private var chatRoomId: String?
    let neumorphicShadow = NumorphicShadow()
    var chatImageURL:URL?
    let grayishColor = #colorLiteral(red: 0.2431372702, green: 0.2431372702, blue: 0.2431372702, alpha: 1)
    // MARK: IBOutlets
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var chatNameLabel: UILabel!
    @IBOutlet weak var chatMessageLabel: UILabel!
    @IBOutlet weak var messageTimeLabel: UILabel!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var badgeCountLabel: UILabel!
    
    @IBOutlet weak var msgBackgroundView: SSNeumorphicView! {
        didSet{
            setShadow(view: msgBackgroundView, mainColor: grayishColor, lightShadow: .white, darkShadow: .black)
        }
    }

    var joinHandler: OnlySuccess?
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        content.addGestureRecognizer(tap)
    }
    
    // MARK: Helper Function
    private func setShadow(view: SSNeumorphicView, mainColor: UIColor,lightShadow:UIColor,darkShadow:UIColor){
        view.viewDepthType = .innerShadow
        view.viewNeumorphicMainColor = mainColor.cgColor
        view.viewNeumorphicLightShadowColor = lightShadow.withAlphaComponent(0.2).cgColor
        view.viewNeumorphicDarkShadowColor = darkShadow.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = 0
    }
    
    func setActiveTemsUI() {
        neumorphicShadow.addNeumorphicShadow(view: msgBackgroundView, shadowType: .innerShadow, cornerRadius: 8, shadowRadius: 0.8, mainColor: UIColor.newAppThemeColor.cgColor, opacity:  0.5, darkColor: UIColor.black.withAlphaComponent(0.3).cgColor, lightColor: UIColor.newAppThemeColor.withAlphaComponent(0.8).cgColor, offset: CGSize(width: 2, height: 2))
        chatNameLabel.textColor = .white
        chatMessageLabel.textColor = .white
        messageTimeLabel.textColor = .white
        badgeCountLabel.textColor = .white
    }
    
    func setData(chatInfo: ChatRoom, atIndexPath indexPath: IndexPath) {
        self.chatMessageLabel.text = ""
        if let message = chatInfo.lastMessage?.text, !message.isEmpty {
            let time = chatInfo.lastMessage?.time?.toDate.chatDisplayTime()
            self.messageTimeLabel.text = time
        } else {
            self.messageTimeLabel.text = ""
        }
        if let messageType = chatInfo.lastMessage?.type {
            switch messageType {
            case .text:
                self.chatMessageLabel.text = chatInfo.lastMessage?.text
            case .image:
                self.chatMessageLabel.text = "Photo"
                self.messageTimeLabel.text = chatInfo.lastMessage?.updatedAt?.toDate.chatDisplayTime()
            case .video:
                self.chatMessageLabel.text = "Video"
                self.messageTimeLabel.text = chatInfo.lastMessage?.updatedAt?.toDate.chatDisplayTime()
            case .pdf:
                self.chatMessageLabel.text = "Pdf"
                self.messageTimeLabel.text = chatInfo.lastMessage?.updatedAt?.toDate.chatDisplayTime()
            }
        }
        if let chatType = chatInfo.chatType {
            switch chatType {
            case .singleChat:
                if let profileUrlStr = chatInfo.members?.first?.profilePic,
                    let url = URL(string: profileUrlStr) {
                    self.chatImageURL = url
                    self.profileImageView.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "user-dummy"))
                } else {
                    self.chatImageURL = nil
                    self.profileImageView.image = #imageLiteral(resourceName: "user-dummy")
                }
                self.chatNameLabel.text = chatInfo.members?.first?.fullName
            case .groupChat:
                self.chatNameLabel.text = chatInfo.name
                if let icon = chatInfo.icon,
                    let url = URL(string: icon) {
                    self.chatImageURL = url
                    self.profileImageView.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "grp-image"))
                } else {
                    self.chatImageURL = nil
                    self.profileImageView.image = #imageLiteral(resourceName: "grp-image")
                }
            }
        }
        chatRoomId = chatInfo.chatRoomId
        self.badgeView.isHidden = true
        self.badgeCountLabel.text = ""
        if let unreadCount = chatInfo.unreadCount,
            unreadCount > 0 {
            updateUnreadCount(count: unreadCount)
        }
    }
    
    func updateUnreadCount(count: Int) {
        if count != 0 {
            self.badgeView.isHidden = false
            self.badgeCountLabel.text = "\(count)"
        } else {
            self.badgeView.isHidden = true
            self.badgeCountLabel.text = ""
        }
    }
    
    func setData(_ group: Friends) {
        if let icon = group.groupIcon, let url = URL(string: icon) {
            self.profileImageView.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "grp-image"))
        } else {
            self.profileImageView.image = #imageLiteral(resourceName: "grp-image")
        }
        chatRoomId = group.id
        chatNameLabel.text = group.groupTitle
    }
    
    @objc func onTap(_ sender: Any) {
        let vc: ChatViewController = UIStoryboard(storyboard: .chatListing).initVC()
        vc.chatRoomId = chatRoomId
        vc.chatName = chatNameLabel.text
        vc.chatImageURL = chatImageURL
        vc.activeTemsJoinHandler = { [weak self] in
            if let joinHandler = self?.joinHandler {
                joinHandler()
            }
        }
        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
}
