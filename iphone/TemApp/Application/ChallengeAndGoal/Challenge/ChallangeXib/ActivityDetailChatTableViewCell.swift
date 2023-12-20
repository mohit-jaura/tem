//
//  ActivityDetailChatTableViewCell.swift
//  TemApp
//
//  Created by shilpa on 27/05/20.
//

import UIKit
import SSNeumorphicView

class ActivityDetailChatTableViewCell: UITableViewCell {

    // MARK: Properties
    private var messages: [Message]?
    var userInfo: [String: Any]?
    
    // MARK: IBOutlets
    @IBOutlet weak var backgroundMessageLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var tableBackView: SSNeumorphicView!{
        didSet{
            tableBackView.setOuterDarkShadow()
            tableBackView.viewDepthType = .innerShadow
            tableBackView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
        }
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chatBubbleButton: UIButton!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatBubbleButtonView: UIView!
    @IBOutlet weak var emptyviewHeightConstraint: NSLayoutConstraint!

    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.tableView.registerNibs(nibNames: [SenderTextMessageTableViewCell.reuseIdentifier, MyTextMessageTableViewCell.reuseIdentifier, MyMediaMessageTableViewCell.reuseIdentifier, SenderMediaMessageTableViewCell.reuseIdentifier])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: Initialization
    func initializeWith(messages: [Message]) {
        self.messages = messages
        if messages.isEmpty {
            self.backgroundMessageLabel.isHidden = false
            self.tableView.isHidden = true
        } else {
            self.backgroundMessageLabel.isHidden = true
            self.tableView.isHidden = false
        }
        self.tableView.reloadData()
        DispatchQueue.main.async {
            self.scrollTableToBottom()
        }
    }
    
    func setUserInformation(userInfo: [String: Any]) {
        self.userInfo = userInfo
    }
    
    //add shadow to the chat bubble view
    private func addShadowToChatBubble() {
        chatBubbleButtonView.layer.shadowColor = UIColor.gray.cgColor
        chatBubbleButtonView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        chatBubbleButtonView.layer.masksToBounds = false
        chatBubbleButtonView.layer.shadowRadius = 2.0
        chatBubbleButtonView.layer.shadowOpacity = 0.5
        chatBubbleButtonView.layer.cornerRadius = 20//pressButton.frame.width / 2
    }
    
    private func scrollTableToBottom() {
        guard let messagesArray = messages else { return }
        if messagesArray.count > 0 {
            let indexPath = IndexPath(row: messagesArray.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
}

// MARK: UITableViewDataSource
extension ActivityDetailChatTableViewCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if messages == nil {
            return 2
        }
        return self.messages?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.backgroundColor = .clear
        if self.messages == nil {
            return tableView.PlacholderCell()
        }
        if let senderId = self.messages?[indexPath.row].senderId,
            let currentUserId = UserManager.getCurrentUser()?.id {
            if senderId == currentUserId {
                //this is the message from the current user
                return self.tableViewCellForMyMessage(indexPath: indexPath)
            } else {
                //this is the message from the other user
                return self.tableViewCellForOtherUserMessage(indexPath: indexPath)
            }
        }
        return UITableViewCell()
    }
    
    /// will return the table cell of the message of current user according to the message type i.e text, video or image
    func tableViewCellForMyMessage(indexPath: IndexPath) -> UITableViewCell {
        if let type = self.messages?[indexPath.row].type {
            switch type {
            case .text:
                let cell: MyTextMessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: MyTextMessageTableViewCell.reuseIdentifier, for: indexPath) as! MyTextMessageTableViewCell
                cell.messageLabel.row = indexPath.row
                cell.messageLabel.section = indexPath.section
                cell.initializeWith(message: self.messages?[indexPath.row] ?? Message(), chatType: .groupChat)
                return cell
            default:
                let cell: MyMediaMessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: MyMediaMessageTableViewCell.reuseIdentifier, for: indexPath) as! MyMediaMessageTableViewCell
                cell.setViewForSmallerDisplay()
                cell.initializeWith(message: self.messages?[indexPath.row] ?? Message(), indexPath: indexPath)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    /// will return the table cell of the message of other user according to the message type i.e text, video or image
    func tableViewCellForOtherUserMessage(indexPath: IndexPath) -> UITableViewCell {
        if let type = self.messages?[indexPath.row].type {
            switch type {
            case .text:
                let cell: SenderTextMessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: SenderTextMessageTableViewCell.reuseIdentifier, for: indexPath) as! SenderTextMessageTableViewCell
                cell.messageLabel.row = indexPath.row
                cell.messageLabel.section = indexPath.section
                cell.initializeWith(message: self.messages?[indexPath.row] ?? Message(), chatType: .groupChat)
                if let senderId = self.messages?[indexPath.row].senderId,
                    let filtered = userInfo?[senderId] as? Friends {
                    cell.setUserInformation(member: filtered)
                }
                return cell
            default:
                let cell: SenderMediaMessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: SenderMediaMessageTableViewCell.reuseIdentifier, for: indexPath) as! SenderMediaMessageTableViewCell
                cell.setViewForSmallerDisplay()
                cell.initializeWith(message: self.messages?[indexPath.row] ?? Message(), indexPath: indexPath)
                if let senderId = self.messages?[indexPath.row].senderId,
                    let filtered = userInfo?[senderId] as? Friends {
                    cell.setUserInformation(member: filtered)
                }
                return cell
            }
        }
        return UITableViewCell()
    }
}
