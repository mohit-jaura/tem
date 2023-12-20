//
//  FilterSideMenuTableViewCell.swift
//  TemApp
//
//  Created by shilpa on 25/07/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

class FilterSideMenuTableViewCell: UITableViewCell {

    // MARK: IBOutlets
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // MARK: Initializer
    func initializeWith(viewModel: FilterSideMenuTableCellViewModel) {
        if let urlString = viewModel.icon,
            let url = URL(string: urlString) {
            self.iconImageView.isHidden = false
            self.iconImageView.kf.setImage(with: url, placeholder: nil)
        } else {
            self.iconImageView.isHidden = true
        }
        self.titleLabel.text = viewModel.title
        if let isSelected = viewModel.isSelected {
            self.accessoryType = isSelected ? .checkmark : .none
        } else {
            self.accessoryType = .none
        }
    }
}

struct FilterSideMenuTableCellViewModel {
    var icon: String?
    var title: String?
    var isSelected: Bool?
}
