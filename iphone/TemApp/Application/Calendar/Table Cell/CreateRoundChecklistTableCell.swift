//
//  RoundChecklistTableCell.swift
//  TemApp
//
//  Created by Shiwani Sharma on 18/07/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class CreateRoundChecklistTableCell: UITableViewCell {

    @IBOutlet weak var shadowView: SSNeumorphicView! {
        didSet {
            setShadow(view: shadowView, shadowType: .outerShadow)
        }
    }
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var rankLbl: UILabel!
    @IBOutlet weak var blueImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func setData(task: Tasks, index: Int) {
        titleLbl.text = task.task_name
        rankLbl.text = "\(index + 1)"
        if let fileType = EventMediaType(rawValue: task.fileType ?? 0) {
            switch fileType {
            case .video:
                mediaImageView.image = UIImage(named: "videoWhite")
            case .pdf:
                mediaImageView.image = UIImage(named: "pdf")
            }
        } else {
            mediaImageView.image = UIImage(named: "")
        }
    }
    func setShadow(view: SSNeumorphicView, shadowType: ShadowLayerType, isType: Bool = false) {
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor = UIColor.newAppThemeColor.cgColor
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = 8
        view.viewNeumorphicShadowRadius = 3
    }
}
