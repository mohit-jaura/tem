//
//  RecentSearchesTableViewCell.swift
//  TemApp
//
//  Created by shilpa on 25/03/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

class RecentSearchesTableViewCell: UITableViewCell {

    // MARK: IBOutlets
    @IBOutlet weak var recentSearchLabel: UILabel!

    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: Helpers
    func initializeWith(address: Address?,isFromGym:Bool = false) {
        //self.recentSearchLabel.text = address ?? ""
        if let formatted = address?.formatted,
            !formatted.isEmpty {
            if (isFromGym) {
                self.recentSearchLabel.text = (address?.name ?? "") + ", " + formatted
            } else {
                self.recentSearchLabel.text = formatted
            }
            
        } else {
            if(isFromGym) {
                self.recentSearchLabel.text = (address?.name ?? "") + ", " + ((address?.city ?? "") )
            } else {
                self.recentSearchLabel.text = address?.city ?? "NA"
            }
            
        }
    }
}
