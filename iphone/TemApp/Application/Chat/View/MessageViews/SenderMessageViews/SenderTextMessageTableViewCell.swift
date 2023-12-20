//
//  SenderTextMessageTableViewCell.swift
//  TemApp
//
//  Created by shilpa on 23/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class SenderTextMessageTableViewCell: UITableViewCell {

    // MARK: Properties
    weak var delegate: TextMessageTableCellDelegate?
    var message: Message?
    // MARK: IBOutlets
    @IBOutlet weak var backShadowView: SSNeumorphicView! {
        didSet{
            backShadowView.viewDepthType = .outerShadow
            backShadowView.viewNeumorphicMainColor = UIColor(red: 227 / 255.0, green: 227 / 255.0, blue: 227 / 255.0, alpha: 1).cgColor
            backShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
            backShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.6).cgColor
            backShadowView.viewNeumorphicShadowOpacity = 0.5
            backShadowView.viewNeumorphicCornerRadius = 8
        }
    }
    @IBOutlet weak var messageLabel: ActiveLabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
        self.addDropShadow()
    }

    // MARK: Initialization
    func setJourneyNotesData(data: JourneyNote) {
        self.backgroundColor = .clear
        if data.senderId == UserManager.getCurrentUser()?.id {
            self.userNameLabel.text = "You"
        } else {
            self.userNameLabel.text = "\(data.firstName ?? "") \(data.lastName ?? "")"
        }
        self.messageLabel.text = data.message
        self.timeLabel.text = data.updatedAt?.toDate(dateFormat: .preDefined).toString(inFormat: .time) ?? ""
        if let profileUrl = data.senderImage,
           let url = URL(string: profileUrl) {
            self.userImageView.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "user-dummy"))
        } else {
            self.userImageView.image = #imageLiteral(resourceName: "user-dummy")
        }
    }
    
    func initializeWith(message: Message, chatType: ChatType) {
        self.message = message
        self.userNameLabel.isHidden = true
        self.userNameLabel.text = ""
        if chatType == .groupChat {
            self.userNameLabel.isHidden = false
            self.userNameLabel.text = ""
        }
        if chatType == .groupChat {
            self.setAndDetectMentionInMessage()
        } else {
            self.messageLabel.mentionColor = UIColor(0x000000)
            self.messageLabel.hashtagColor = UIColor(0x000000)
            self.detectUrlInMessage()
        }
        self.messageLabel.text = message.text
        self.timeLabel.text = message.time?.toDate.chatDisplayTime()
    }
    
    /// set the user information in the cell
    ///
    /// - Parameter member: user object
    func setUserInformation(member: Friends) {
        self.userNameLabel.text = member.fullName
        if let profileUrl = member.profilePic,
            let url = URL(string: profileUrl) {
            self.userImageView.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "user-dummy"))
        } else {
            self.userImageView.image = #imageLiteral(resourceName: "user-dummy")
        }
    }
    
    private func setAndDetectMentionInMessage() {
        let customType = ActiveType.custom(pattern: RegEx.mention.rawValue)
        let fontColor = UIColor(0x000000)
        messageLabel.numberOfLines = 0
        messageLabel.customColor[customType] = fontColor
        messageLabel.customSelectedColor[customType] = fontColor
        messageLabel.enabledTypes = [customType, .url]
        
        messageLabel.customize { (label) in
            label.configureLinkAttribute = { (type, attributes, isSelected) in
                var atts = attributes
                switch type {
                case customType:
                    atts[NSAttributedString.Key.font] = UIFont(name: UIFont.robotoMedium, size: self.messageLabel.font.pointSize)!
                    atts[NSAttributedString.Key.foregroundColor] = fontColor
                case .url:
                    atts[NSAttributedString.Key.font] = UIFont(name: UIFont.robotoMedium, size: self.messageLabel.font.pointSize)!
                    atts[NSAttributedString.Key.foregroundColor] = fontColor
                default: ()
                }
                
                return atts
            }
        }
        messageLabel.handleCustomTap(for: customType, handler: {[weak self] (element) in
            if let wkSelf = self {
                DispatchQueue.main.async {
                    let tagText = element.replace(Constant.taggedSymbol, replacement: "")
                    wkSelf.delegate?.didTapOnTagOnMessageAt(row: wkSelf.messageLabel.row, section: wkSelf.messageLabel.section, tagText: tagText)
                }
            }
        })
        messageLabel.handleURLTap {[weak self] (url) in
            if let wkSelf = self {
                DispatchQueue.main.async {
                    wkSelf.delegate?.didTapOnUrlOnMessageAt(row: wkSelf.messageLabel.row, section: wkSelf.messageLabel.section, url: url)
                }
            }
        }
    }
    
    func detectUrlInMessage() {
        messageLabel.numberOfLines = 0
        messageLabel.enabledTypes = [.url]
        
        messageLabel.customize { (label) in
            label.configureLinkAttribute = { (type, attributes, isSelected) in
                var atts = attributes
                switch type {
                case .url:
                    atts[NSAttributedString.Key.font] = UIFont(name: UIFont.robotoMedium, size: self.messageLabel.font.pointSize)!
                    atts[NSAttributedString.Key.foregroundColor] = UIColor(0x000000)
                default: ()
                }
                
                return atts
            }
        }
        messageLabel.handleURLTap {[weak self] (url) in
            if let wkSelf = self {
                DispatchQueue.main.async {
                    wkSelf.delegate?.didTapOnUrlOnMessageAt(row: wkSelf.messageLabel.row, section: wkSelf.messageLabel.section, url: url)
                }
            }
        }
    }
    
    func addDropShadow() {
      //  backShadowView.addDropShadowToView()
    }
}
