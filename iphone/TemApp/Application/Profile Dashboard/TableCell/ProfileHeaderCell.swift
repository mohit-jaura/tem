//
//  ProfileHeaderCell.swift
//  TemApp
//
//  Created by Harmeet on 17/06/20.
//

import UIKit

class ProfileHeaderCell: UITableViewCell {
    // MARK: IBOutlets
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var dropDounButton: UIImageView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var gridListHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var gridButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var cellTopView: UIView!
    @IBOutlet weak var lineView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    var sectionIsExpanded: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.25) {
                if !self.sectionIsExpanded {
                    self.dropDounButton.transform = CGAffineTransform.identity
                } else {
                    self.dropDounButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2.0)
                }
            }
        }
    }
    
}
