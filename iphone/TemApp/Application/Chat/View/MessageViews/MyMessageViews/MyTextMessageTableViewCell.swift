//
//  MyTextMessageTableViewCell.swift
//  TemApp
//
//  Created by shilpa on 23/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

protocol TextMessageTableCellDelegate: AnyObject {
    func didTapOnTagOnMessageAt(row: Int, section: Int, tagText: String)
    func didTapOnUrlOnMessageAt(row: Int, section: Int, url: URL)
}

class MyTextMessageTableViewCell: UITableViewCell {

    // MARK: Properties
    weak var delegate: TextMessageTableCellDelegate?
    
    // MARK: IBOutlets
    @IBOutlet weak var backShadowView: SSNeumorphicView! {
        didSet{
            backShadowView.viewDepthType = .outerShadow
            backShadowView.viewNeumorphicMainColor = UIColor.appThemeColor.cgColor
            backShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
            backShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.6).cgColor
            backShadowView.viewNeumorphicShadowOpacity = 0.3
            backShadowView.viewNeumorphicCornerRadius = 8
        }
    }
    @IBOutlet weak var messageLabel: ActiveLabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
//        self.addDropShadow()
    }
    
    // MARK: Initialization
    func initializeWith(message: Message, chatType: ChatType) {
        self.timeLabel.text = message.time?.toDate.chatDisplayTime()
        if chatType == .groupChat {
            self.setAndDetectMentionInMessage()
        } else {
            messageLabel.mentionColor = UIColor.black
            self.messageLabel.hashtagColor = UIColor.black
            self.detectUrlInMessage()
        }
        messageLabel.text = message.text
    }
    // MARK: Helper Function
    
    private func setAndDetectMentionInMessage() {
        let customType = ActiveType.custom(pattern: RegEx.mention.rawValue)
        
        messageLabel.numberOfLines = 0
        messageLabel.customColor[customType] = UIColor.black
        messageLabel.customSelectedColor[customType] = UIColor.black
        messageLabel.enabledTypes = [customType, .url]
        
        messageLabel.customize { (label) in
            label.configureLinkAttribute = { (type, attributes, isSelected) in
                var atts = attributes
                switch type {
                case customType:
                    atts[NSAttributedString.Key.font] = UIFont(name: UIFont.robotoMedium, size: self.messageLabel.font.pointSize)!
                    atts[NSAttributedString.Key.foregroundColor] = UIColor.black
                case .url:
                    atts[NSAttributedString.Key.font] = UIFont(name: UIFont.robotoMedium, size: self.messageLabel.font.pointSize)!
                    atts[NSAttributedString.Key.foregroundColor] = UIColor.blue
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
                    atts[NSAttributedString.Key.foregroundColor] = UIColor.blue
                    
                default: ()
                }
                
                return atts
            }
        }
        messageLabel.handleURLTap {[weak self] (url) in
            if let wkSelf = self {
                DispatchQueue.main.async {
                    print("url tapped is \(url)")
                    wkSelf.delegate?.didTapOnUrlOnMessageAt(row: wkSelf.messageLabel.row, section: wkSelf.messageLabel.section, url: url)
                }
            }
        }
    }
    
    func addDropShadow() {
//      backShadowView.addDropShadowToView()
    }
}

