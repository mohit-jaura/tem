//
//  SearchCategoryFooter.swift
//  TemApp
//
//  Created by Egor Shulga on 9.04.21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import Foundation

class SearchCategoryFooter : UITableViewCell {
    private var search: CategorySearch?
    private var selectSearchMode: SelectSearchModeProtocol?
    
    @IBOutlet weak var content: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func initialize(_ search: CategorySearch, _ selectSearchMode: SelectSearchModeProtocol) {
        self.search = search
        self.selectSearchMode = selectSearchMode
    }
    
    @IBAction func onTap(_ sender: Any) {
        guard let search = search, let selectSearchMode = selectSearchMode else {
            return
        }
        selectSearchMode.switchToCategorySearch(search: search)
    }
}
