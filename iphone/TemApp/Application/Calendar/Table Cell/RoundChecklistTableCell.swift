//
//  RoundChecklistTableCell.swift
//  TemApp
//
//  Created by Shiwani Sharma on 18/07/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
protocol OpenMediaDelagate: AnyObject {
    func openMediaView(fileType: EventMediaType, url: String)
}
class RoundChecklistTableCell: UITableViewCell {
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var taskName: UILabel!
    weak var mediaDelegate: OpenMediaDelagate?
    var fileType : EventMediaType?
    var url = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    @IBAction func pdfVideoButtonTapped(_ sender: UIButton) {
        
        switch self.fileType {
        case .video:
            mediaDelegate?.openMediaView(fileType: .video, url: url)
        case .pdf:
            mediaDelegate?.openMediaView(fileType: .pdf, url: url)
        default:
            break
        }
    }
    func setData(round: Rounds ,index: Int) {
        if let task = round.tasks?[index] {
            taskName.text = task.task_name?.firstUppercased ?? ""
            mediaImageView.image = UIImage(named: "")
            if let fileType = EventMediaType(rawValue: round.tasks?[index].fileType ?? 0) {
                self.fileType = fileType
                self.url = task.file ?? ""
                switch fileType {
                case .video:
                    mediaImageView.image = UIImage(named: "videoWhite")
                case .pdf:
                    mediaImageView.image = UIImage(named: "pdfWhite")
                }
            }
        }
    }
}
