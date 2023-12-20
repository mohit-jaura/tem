//
//  TagAnotherPersonSectionView.swift
//  TemApp
//
//  Created by shilpa on 18/12/19.
//

import UIKit
protocol TagAnotherPersonSectionDelegate: AnyObject {
    func didTapOnAdd()
}

class TagAnotherPersonSectionView: UITableViewHeaderFooterView {

    // MARK: Properties
    weak var delegate: TagAnotherPersonSectionDelegate?
    
    // MARK: IBOutlets
    @IBOutlet weak var addImageView: UIImageView!
    
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addImageView.setImageColor(color: UIColor.appThemeColor)
    }
    
    // MARK: IBActions
    @IBAction func tagAnotherPersonTapped(_ sender: UIButton) {
        self.delegate?.didTapOnAdd()
    }
}
