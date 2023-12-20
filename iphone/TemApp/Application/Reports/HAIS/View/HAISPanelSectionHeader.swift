//
//  HAISPanelSectionHeader.swift
//  TemApp
//
//  Created by shilpa on 08/11/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
protocol HAISPanelSectionHeaderDelegate: AnyObject {
    func didSelectPanelHeader(isSelected: Bool)
}

class HAISPanelSectionHeader: UITableViewHeaderFooterView {

    // MARK: Properties
    weak var delegate: HAISPanelSectionHeaderDelegate?
    private var isSelected = false
    
    // MARK: IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: IBActions
    @IBAction func actionTapped(_ sender: UIButton) {
        self.delegate?.didSelectPanelHeader(isSelected: isSelected)
    }
    
    
//    func setLayout(isSelected: Bool) {
//        if isSelected {
//            self.isSelected = true
//            rightIconImageView.image = UIImage(named: "arrowDown")
//        } else {
//            self.isSelected = false
//            rightIconImageView.image = UIImage(named: "right-arrow")
//        }
//    }
}
