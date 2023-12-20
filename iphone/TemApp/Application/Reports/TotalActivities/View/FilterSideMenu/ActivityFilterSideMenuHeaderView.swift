//
//  ActivityFilterSideMenuHeaderView.swift
//  TemApp
//
//  Created by shilpa on 25/07/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

struct ActivityFilterSideMenuHeaderViewModel {
    var title: String?
}

class ActivityFilterSideMenuHeaderView: UITableViewHeaderFooterView {

    // MARK: IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: Initializer
    func initializeWith(viewModel: ActivityFilterSideMenuHeaderViewModel) {
        self.titleLabel.text = viewModel.title
    }
}
