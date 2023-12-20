//
//  ExpandedNetworkHeader.swift
//  TemApp
//
//  Created by shilpa on 19/04/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
protocol ExpandedNetworkHeaderDelegate: AnyObject {
    func didTapOnExpandedHeader(section: Int)
    func  didTapOnSelectAll(selectedAll:Bool)
}
class ExpandedNetworkHeader: UITableViewHeaderFooterView {

    // MARK: Properties
    weak var delegate: ExpandedNetworkHeaderDelegate?
    
    // MARK: IBOutlets
    @IBOutlet weak var titleLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collapseButton: UIButton!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var backViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectAllBtn:UIButton!
    
    // MARK: IBActions
    @IBAction func headerTapped(_ sender: UIButton) {
        self.delegate?.didTapOnExpandedHeader(section: sender.tag)
    }
    
    @IBAction func selectAllTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        sender.backgroundColor = .clear
        self.delegate?.didTapOnSelectAll(selectedAll: sender.isSelected)
    }
    
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func draw(_ rect: CGRect) {
        self.backView.roundCorners([.topLeft, .topRight], radius: 10.0)
        super.draw(rect)
    }
    
    // MARK: Initializer
    /// call this method to configure the header view for Network screen
    func configureFor(section: NetworkSection) {
        self.collapseButton.tag = section.rawValue
        //set title of section
        titleLabel.text = section.getSectionTitle()
        titleLabel.textColor = #colorLiteral(red: 0.4129237235, green: 0.9907485843, blue: 0.9624536633, alpha: 1)
        titleLabel.font = UIFont(name: UIFont.avenirNextBold, size: 16)
    }
    
    /// call this method to configure the header view for Users Listing screen
    func configureFor(section: UserListingSection) {
        //set title of section
        titleLabel.text = section.title
        titleLabel.textColor = #colorLiteral(red: 0.4129237235, green: 0.9907485843, blue: 0.9624536633, alpha: 1)
        titleLabel.font = UIFont(name: UIFont.avenirNextBold, size: 16)
    }
    
    /// call this method to configure the header view for Users Listing screen
    func configureFor(section: inviteFriendsSection) {
        //set title of section
        titleLabelLeadingConstraint.constant = 35
        titleLabel.textColor = UIColor.appThemeColor
        titleLabel.text = section.title
        backViewTopConstraint.constant = 8//0
        if section == .Friends{
            selectAllBtn.isHidden = false
        }else{
            selectAllBtn.isHidden = true
        }
    }
    
}
