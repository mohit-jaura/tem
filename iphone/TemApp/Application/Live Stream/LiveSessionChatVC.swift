//
//  LiveSessionChatVC.swift
//  TemApp
//
//  Created by Mohit Soni on 29/08/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import IQKeyboardManagerSwift
import UIKit

class LiveSessionChatVC: DIBaseController {
    
    // MARK: IBOutlets
    @IBOutlet weak var chatView:UIView!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var sendButton:UIButton!
    @IBOutlet weak var messageTextView:IQTextView!
    @IBOutlet weak var messageViewBottomConstraint:NSLayoutConstraint!
    @IBOutlet weak var messageTextViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: Properties
    let chatManager = ChatManager()
    var sessionId:String?
    var sessionMessages:[LiveSessionChat]?
    var RestHeight :CGFloat {
        return messageTextViewHeightConstraint.constant
    }
    var dynamicHeight:HeightChanged?
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeDelegates()
        fetchLiveSessionChat(sessionId: sessionId)
        setSendButtonState(message: false)
        self.setIQKeyboardManager(toEnable: false)
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
        self.addKeyboardNotificationObservers()
        callingStreamAudCallBacks()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("view will appear of chat screen")
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        print("view will DISappear of chat screen")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if self.tableView.layer.mask == nil {

            //If you are using auto layout
            //self.view.layoutIfNeeded()

            let maskLayer: CAGradientLayer = CAGradientLayer()

            maskLayer.locations = [0.0, 0.2, 0.8, 1.0]
            let width = self.tableView.frame.size.width
            let height = self.tableView.frame.size.height
            maskLayer.bounds = CGRect(x: 0.0, y: 0.0, width: width, height: height)
            maskLayer.anchorPoint = CGPoint.zero

            self.tableView.layer.mask = maskLayer
        }

        scrollViewDidScroll(self.tableView)
    }

    // MARK: IBActions
    @IBAction func sendTapped(_ sender:UIButton) {
        sendMessageToLiveSession(message: "")
    }
    // MARK: Methods
    private func callingStreamAudCallBacks() {
        if let parent = self.parent as? StreamAudienceVC {
            parent.voidCallBack = {
                self.scrollToBottom()
            }
            parent.sendMessage = { message in
                self.sendMessageToLiveSession(message: message.trim)
            }
        }
    }
    private func initializeDelegates() {
        tableView.registerNibs(nibNames: [SenderTextMessageTableViewCell.reuseIdentifier])
        tableView.delegate = self
        tableView.dataSource = self
        messageTextView.delegate = self
        self.messageTextView.returnKeyType = .done
        self.messageTextView.text = nil
    }
    private func callBackForHeight() {
        //Total height for chat container 270 so it should not be call back if height is more then 270
        
        let tableHeight = tableView.contentSize.height
        let totalHeight = tableHeight + RestHeight
        if totalHeight <= 550{
            dynamicHeight?(totalHeight)
        }

    }
    
    private func fetchLiveSessionChat(sessionId:String?) {
        guard let sessionId = sessionId else {
            debugPrint("No session id found")
            return
        }

        if isConnectedToNetwork() {
            self.showLoader()
            chatManager.getLiveSessionChats(sessionId: sessionId) { [weak self] messages, error in
                self?.hideLoader()
                if error != nil {
                    DILog.print(items: error?.localizedDescription as Any)
                    return
                }
                self?.sessionMessages = messages
                self?.showNoMessagesLabel(messages?.count ?? 0)
                self?.tableView.reloadData()
                self?.callBackForHeight()
                self?.scrollToBottom()
                
            }
        } else {
            self.hideLoader()
            showAlert(withTitle: "", message: AppMessages.AlertTitles.noInternet, okayTitle: AppMessages.AlertTitles.Ok, cancelTitle: "", okStyle: .cancel, okCall: {
                // Ok Call
            }, cancelCall: {
                // Cancel Call
            })
        }
    }
    
    private func sendMessageToLiveSession(message:String) {
        let userName = "\(UserManager.getCurrentUser()?.firstName ?? "") \(UserManager.getCurrentUser()?.lastName ?? "")".trim

        let messageData = LiveSessionChat(chat_room_id: sessionId, id: UUID().uuidString, createdAt: Date().timeIntervalSince1970, userName: userName, userImage: UserManager.getCurrentUser()?.profilePicUrl, message: message)
        chatManager.addMessageToLiveSessionChat(sessionId: sessionId ?? "", messageData: messageData.getDict()) {[weak self] error in
            if error != nil {
                DILog.print(items: error?.localizedDescription as Any)
                self?.messageTextView.text = nil
                self?.setSendButtonState(message: false)
                self?.showAlert(withTitle: "", message: AppMessages.Chat.cannotMessageInLiveChat, okayTitle: AppMessages.AlertTitles.Ok, cancelTitle: "", okStyle: .cancel, okCall: {
                    // Ok Call
                }, cancelCall: {
                    // Cancel Call
                })
                
            } else {
                self?.messageTextView.text = nil
                self?.setSendButtonState(message: false)
                self?.messageTextViewHeightConstraint.constant = 35
            }
        }
    }
    
    func scrollToBottom() {
        if sessionMessages?.count ?? 0 > 0 {
            DispatchQueue.main.async {
                let indexPath = IndexPath(
                    row: self.tableView.numberOfRows(inSection:  self.tableView.numberOfSections - 1) - 1,
                    section: self.tableView.numberOfSections - 1)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    private func setSendButtonState(message:Bool) {
        sendButton.isEnabled = message
        sendButton.backgroundColor = message ? UIColor.appThemeColor : UIColor.gray
    }
    
    private func showNoMessagesLabel(_ messagesCount:Int) {
        if messagesCount <= 1 {
            tableView.showEmptyScreen("")
            return
        }
        tableView.showEmptyScreen("")
    }
    
    // MARK: Methods to handle keyboard height
    override func keyboardDisplayedWithHeight(value: CGRect) {
        var verticalSafeAreaInset : CGFloat = 0.0
        if #available(iOS 11.0, *) {
            verticalSafeAreaInset = self.view.safeAreaInsets.bottom
        } else {
            verticalSafeAreaInset = 0.0
        }
        UIView.animate(withDuration: 0.3, animations: {
      //      self.messageViewBottomConstraint.constant = (value.height+verticalSafeAreaInset)
            self.view.layoutIfNeeded()
        })
    }
    
    override func keyboardHide(height: CGFloat) {
     //   self.messageViewBottomConstraint.constant = -1
    }
    
}
// MARK: TableView Extension
extension LiveSessionChatVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let messagesCount = sessionMessages?.count else { return 0 }
        return messagesCount
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LiveSessionChatTableViewCell = tableView.dequeueReusableCell(withIdentifier: LiveSessionChatTableViewCell.reuseIdentifier, for: indexPath) as! LiveSessionChatTableViewCell
        if let messageData = sessionMessages?[indexPath.row] {
            cell.setMessageInfo(messageData: messageData)
        }
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
      //  tableView.fadeEdges(with: 1.8)
        let outerColor = UIColor(white: 1.0, alpha: 0.0).cgColor
        let innerColor = UIColor(white: 1.0, alpha: 1.0).cgColor

        var colors = [CGColor]()

        if scrollView.contentOffset.y + scrollView.contentInset.top <= 0 {
            colors = [innerColor, innerColor, innerColor, outerColor]
        } else if scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height {
            colors = [outerColor, innerColor, innerColor, innerColor]
        } else {
            colors = [outerColor, innerColor, innerColor, outerColor]
        }
        if let mask = scrollView.layer.mask as? CAGradientLayer {
            mask.colors = colors

            CATransaction.begin()
            CATransaction.setDisableActions(true)
            mask.position = CGPoint(x: 0.0, y: scrollView.contentOffset.y)
            CATransaction.commit()
        }


    }
    
}

// MARK: TextView Extension
extension LiveSessionChatVC :UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        scrollToBottom()
    }
    func textViewDidChange(_ textView: UITextView) {
        setSendButtonState(message: !textView.text.isBlank)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        self.messageTextViewHeightConstraint.constant = textView.contentSize.height

        if self.messageTextViewHeightConstraint.constant > 70 {
            self.messageTextViewHeightConstraint.constant = 70
        }

//        var hidebutton = false
//        if (textView.text.count == 1 && text.count == 0) {
//            hidebutton = true
//        }
//        if (textView.text.count + text.count) >= 1 && (hidebutton == false){
//            //enable send button
//            setSendButtonState(message: true)
//        }else{
//            //disable send button
//            setSendButtonState(message: false)
//        }
        if text == "\n" {
            textView.resignFirstResponder()
        }
//            if (textView.text.count + text.count) >= 1 && (hidebutton == false){
//                //enable send button
//                setSendButtonState(message: true)
//            }else{
//                //disable send button
//                setSendButtonState(message: false)
//            }
//            return false
//        }
        return true
    }
}
