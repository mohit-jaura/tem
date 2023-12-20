//
//  DailyRecordNoteTableViewCell.swift
//  TemApp
//
//  Created by Mohit Soni on 29/03/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import UIKit

class DailyRecordNoteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setJourneyNotesData(data: JourneyNote) {
        self.messageLabel.text = data.message
        self.timeLabel.text = data.updatedAt?.toDate(dateFormat: .preDefined).toString(inFormat: .time) ?? ""
        if let profileUrl = data.senderImage,
           let url = URL(string: profileUrl) {
            self.userImageView.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "user-dummy"))
        } else {
            self.userImageView.image = #imageLiteral(resourceName: "user-dummy")
        }
    }
}
