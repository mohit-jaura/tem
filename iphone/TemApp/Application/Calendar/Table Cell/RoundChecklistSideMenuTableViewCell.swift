//
//  RoundChecklistSideMenuTableViewCell.swift
//  TemApp
//
//  Created by Mohit Soni on 02/08/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import SSNeumorphicView
import UIKit

protocol RoundChecklistSideMenuTableViewCellDelegate: AnyObject {
    func tasksSelection(sender: UIButton)
    func openVideoPdf(sender: UIButton)
}
class RoundChecklistSideMenuTableViewCell: UITableViewCell {
    @IBOutlet weak var taskNameLbl: UILabel!
    @IBOutlet weak var backShadowView: SSNeumorphicView! {
        didSet {
            setShadow(view: backShadowView, shadowType: .outerShadow)
        }
    }
    @IBOutlet weak var checkShadowView: SSNeumorphicView! {
        didSet {
            setShadow(view: checkShadowView, shadowType: .innerShadow)
            checkShadowView.viewNeumorphicCornerRadius = checkShadowView.frame.height / 2
        }
    }
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var mediaNameLbl: UILabel!
    @IBOutlet weak var mediaButton: UIButton!
    @IBOutlet weak var mediaViewHeight: NSLayoutConstraint!
    weak var delegate: RoundChecklistSideMenuTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func videoOrPdfTapped(_ sender: UIButton) {
        delegate?.openVideoPdf(sender: sender)
    }
    @IBAction func checkTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        self.delegate?.tasksSelection(sender: sender)
    }
    func setData(tasks: [ChecklistTasks], index: Int) {
        checkButton.tag = index
        mediaButton.tag = index
        taskNameLbl.text = tasks[index].task?.taskName?.uppercased() ?? ""
        mediaImageView.image = UIImage(named: "")
        if let fileType = EventMediaType(rawValue: tasks[index].task?.fileType ?? 0) {
            switch fileType {
            case .video:
                mediaViewHeight.constant = 30
                mediaImageView.image = UIImage(named: "video2")
                mediaNameLbl.text = "Video"
            case .pdf:
                mediaViewHeight.constant = 30
                mediaImageView.image = UIImage(named: "pdf")
                mediaNameLbl.text = "Pdf"
            }
        } else {
            mediaViewHeight.constant = 0
            mediaNameLbl.text = "No media"
        }
        if let customBool = CustomBool(rawValue: tasks[index].isDone ?? 0) {
            switch customBool {
            case .no:
                checkButton.isSelected = false
            case .yes:
                checkButton.isSelected = true
            }
        }
    }
    func setShadow(view: SSNeumorphicView, shadowType: ShadowLayerType) {
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor =  #colorLiteral(red: 0.2431066334, green: 0.2431549132, blue: 0.2431036532, alpha: 1)
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = 8
        view.viewNeumorphicShadowRadius = 3
    }
}
