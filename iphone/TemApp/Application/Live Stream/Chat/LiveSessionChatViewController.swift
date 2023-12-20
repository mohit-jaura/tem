//
//  LiveSessionChatViewController.swift
//  TemApp
//
//  Created by Mohit Soni on 29/08/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

class LiveSessionChatVC: DIBaseController {
    
    //MARK: IBOutlets
    @IBOutlet weak var chatView:UIView!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var messageField:UITextField!
    @IBOutlet weak var sendButton:UIButton!
    
    //MARK: Properties
    let chatManager = ChatManager()
    var sessionId:String?
    var sessionMessages:[LiveSessionChat]?
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeDelegates()
        fetchLiveSessionChat(sessionId: sessionId)
        setSendButtonState(message: nil)
        self.messageField.text = nil
    }
    
    
    //MARK: IBActions
    @IBAction func sendTapped(_ sender:UIButton){
        sendMessageToLiveSession()
    }
    
    
    //MARK: Methods
    private func initializeDelegates(){
        tableView.registerNibs(nibNames: [SenderTextMessageTableViewCell.reuseIdentifier])
        tableView.delegate = self
        tableView.dataSource = self
        messageField.delegate = self
    }
    
    private func fetchLiveSessionChat(sessionId:String?){
        guard let sessionId = sessionId else {
            debugPrint("No session id found")
            return
        }

        if isConnectedToNetwork() {
            self.showLoader()
            chatManager.getLiveSessionChats(sessionId: sessionId) { [weak self] messages, error in
                self?.hideLoader()
                if error != nil{
                    DILog.print(items: error?.localizedDescription as Any)
                    return
                }
                self?.sessionMessages = messages
                self?.showNoMessagesLabel(messages?.count ?? 0)
                self?.tableView.reloadData()
                self?.scrollToBottom()
                
            }
        }else{
            self.hideLoader()
            showAlert(withTitle: "", message: AppMessages.AlertTitles.noInternet, okayTitle: AppMessages.AlertTitles.Ok, cancelTitle: "", okStyle: .cancel, okCall: {
                // Ok Call
            }, cancelCall: {
                // Cancel Call
            })
        }
    }
    
    private func sendMessageToLiveSession(){
        let userName = "\(UserManager.getCurrentUser()?.firstName ?? "") \(UserManager.getCurrentUser()?.lastName ?? "")".trim
        let messageData = LiveSessionChat(chat_room_id: sessionId, id: UUID().uuidString, createdAt: Date().timeIntervalSince1970, userName: userName, userImage: UserManager.getCurrentUser()?.profilePicUrl, message: messageField.text ?? "")
        chatManager.addMessageToLiveSessionChat(sessionId: sessionId ?? "", messageData: messageData.getDict()) {[weak self] error in
            if error != nil{
                DILog.print(items: error?.localizedDescription as Any)
                self?.messageField.text = nil
                self?.setSendButtonState(message: nil)
                self?.showAlert(withTitle: "", message: "AppMessages.Chat.cannotMessageInLiveChat", okayTitle: AppMessages.AlertTitles.Ok, cancelTitle: "", okStyle: .cancel, okCall: {
                    // Ok Call
                }, cancelCall: {
                    // Cancel Call
                })
                
            }else{
                self?.messageField.text = nil
                self?.setSendButtonState(message: nil)
                self?.fetchLiveSessionChat(sessionId: self?.sessionId ?? "")
            }
        }
    }
        
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.tableView.numberOfRows(inSection:  self.tableView.numberOfSections - 1) - 1,
                section: self.tableView.numberOfSections - 1)
            if indexPath.row >= 4 {
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    private func setSendButtonState(message:String?){
        if let message = message {
            if message.isBlank || message.hasPrefix(" "){
                sendButton.isEnabled = false
                sendButton.tintColor = UIColor.gray
                return
            }
            else{
                sendButton.isEnabled = true
                sendButton.tintColor = UIColor.appThemeColor
                return
            }
        }
        sendButton.tintColor = UIColor.gray
    }
    
    private func showNoMessagesLabel(_ messagesCount:Int){
        if messagesCount <= 1 {
            tableView.showEmptyScreen("")
            return
        }
        tableView.showEmptyScreen("")
    }
    
}

 
//MARK: TableView Extension
extension LiveSessionChatVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessionMessages?.count ?? 0
    }
   
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
       tableView.fadeEdges(with: 1.0)
    }

   
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LiveSessionChatTableViewCell = tableView.dequeueReusableCell(withIdentifier: LiveSessionChatTableViewCell.reuseIdentifier, for: indexPath) as! LiveSessionChatTableViewCell
        if let messageData = sessionMessages?[indexPath.row]{
            cell.setMessageInfo(messageData: messageData)
        }
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

//MARK: TextField Extension
extension LiveSessionChatVC: UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var message:String?
        if string == ""{
            if let text = textField.text{
                message = text
                message?.removeLast()
            }
        }else{
            message = string
        }
        setSendButtonState(message: message)
        return true
    }
}
