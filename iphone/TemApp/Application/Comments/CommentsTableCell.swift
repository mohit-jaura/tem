//
//  CommentsTableCell.swift
//  TemApp
//
//  Created by Harpreet_kaur on 22/04/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
//import ActiveLabel

protocol CommentTableCellDelegate: AnyObject {
    func didTapOnTagInCommentAt(row: Int, section: Int, tagText: String)
    func didTapOnUrlInCommentAt(row: Int, section: Int, url: URL)
}

class CommentsTableCell: UITableViewCell {
    
    // MARK: Variables.
    weak var delegate: CommentTableCellDelegate?
    var userId:String = ""
    var isCompanyUser = 0
    // MARK: IBOulets.
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var commentLabel: ActiveLabel!
    
    // MARK: TableCellFunction.
    override func awakeFromNib() {
        super.awakeFromNib()
        addGesture()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: Function to add gesture to redirect on user profile screen.
    func addGesture() {
        let viewProfileGesture = UITapGestureRecognizer(target: self, action: #selector(navigateToUserProfile))
        let viewProfileGesture2 = UITapGestureRecognizer(target: self, action: #selector(navigateToUserProfile))
        viewProfileGesture.numberOfTapsRequired = 1
        self.userImageView.addGestureRecognizer(viewProfileGesture2)
        self.userNameLabel.addGestureRecognizer(viewProfileGesture)
    }
    
    @objc func navigateToUserProfile(recognizer: UITapGestureRecognizer) {
        if isCompanyUser == 0 {
            let profileVC : ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
            if userId != User.sharedInstance.id {
                profileVC.otherUserId = userId
            }
            UIApplication.topViewController()?.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    // MARK: Function to set data of comments.
    func setData(data:Comments) {
        userId = data.userId?.id ?? ""
        isCompanyUser = data.userId?.isCompanyAccount ?? 0
        userImageView.contentMode = .scaleAspectFill
        if let imageUrl = URL(string:data.userId?.picture ?? "") {
            self.userImageView.kf.setImage(with: imageUrl, placeholder:#imageLiteral(resourceName: "user-dummy"))
        }else{
            self.userImageView.image = #imageLiteral(resourceName: "user-dummy")
        }
        userNameLabel.text = Utility.getUserName(firstName: data.userId?.firstName ?? "", lastName: data.userId?.lastName ?? "", userName: data.userId?.userName ?? "")
        timeLabel.text = data.createdAt?.toDate().postCreatedTime()
        self.setAndDetectTagsInComment(comment: data.comment)
        commentLabel.text = data.comment

    }
    
    private func setAndDetectTagsInComment(comment: String?) {
        commentLabel.isUserInteractionEnabled = true
        let customType = ActiveType.custom(pattern: RegEx.mention.rawValue)
        commentLabel.singleLineLength = 18
        commentLabel.numberOfLines = 0
        commentLabel.customColor[customType] = UIColor.textBlackColor
        commentLabel.customSelectedColor[customType] = UIColor.textBlackColor
        commentLabel.enabledTypes = [customType, .url]
        commentLabel.customize { (label) in
            label.configureLinkAttribute = { (type, attributes, _) in
                var atts = attributes
                switch type {
                case customType:
                    atts[NSAttributedString.Key.font] = UIFont(name: UIFont.robotoMedium, size: self.commentLabel.font.pointSize)!
                    atts[NSAttributedString.Key.foregroundColor] = UIColor.textBlackColor
                case .url:
                    atts[NSAttributedString.Key.font] = UIFont(name: UIFont.robotoMedium, size: self.commentLabel.font.pointSize)!
                    atts[NSAttributedString.Key.foregroundColor] = UIColor.appThemeColor
                default: ()
                }

                return atts
            }
        }
        commentLabel.handleCustomTap(for: customType, handler: {[weak self] (element) in
            DispatchQueue.main.async {
                let tagText = element.replace(Constant.taggedSymbol, replacement: "")
                self?.delegate?.didTapOnTagInCommentAt(row: self!.commentLabel.row, section: self!.commentLabel.section, tagText: tagText)
            }
        })
        commentLabel.handleURLTap {[weak self] (url) in
            if let wkSelf = self {
                DispatchQueue.main.async {
                    wkSelf.delegate?.didTapOnUrlInCommentAt(row: wkSelf.commentLabel.row, section: wkSelf.commentLabel.section, url: url)
                }
            }
        }
    }
}
