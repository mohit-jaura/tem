//
//  LiveSessionChatTableViewCell.swift
//  TemApp
//
//  Created by Mohit Soni on 31/08/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

class LiveSessionChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userNameLbl:UILabel!
    @IBOutlet weak var userImageView:UIImageView!
    @IBOutlet weak var messageLbl:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    //    self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setMessageInfo(messageData:LiveSessionChat) {
        if messageData.message ?? "" != "" {
            userNameLbl.text = messageData.userName ?? ""
            
            userImageView.setImg(messageData.userImage)
           
            messageLbl.text = messageData.message ?? ""
        }
    }
    
}
