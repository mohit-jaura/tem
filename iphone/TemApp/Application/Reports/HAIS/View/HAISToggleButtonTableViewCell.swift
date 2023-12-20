//
//  HAISToggleButtonTableViewCell.swift
//  TemApp
//
//  Created by shilpa on 25/02/20.
//

import UIKit
protocol HAISToggleTableCellDelegate: AnyObject {
    func didChangeToggleFor(section: HAISFormSections, isSelected: Bool)
}
class HAISToggleButtonTableViewCell: UITableViewCell {

    // MARK: Properties
    weak var delegate: HAISToggleTableCellDelegate?
    
    // MARK: IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var toggleButton: UIButton!
    
    // MARK: IBActions
    @IBAction func toggleTapped(_ sender: UIButton) {
        self.toggleButton.isSelected.toggle()
        guard let section = HAISFormSections(rawValue: sender.tag) else {
            return
        }
        self.delegate?.didChangeToggleFor(section: section, isSelected: sender.isSelected)
    }
    
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: Helpers
    private func setToggleStatus(value: CustomBool?) {
        if let value = value {
            switch value {
            case .yes:
                self.toggleButton.isSelected = true
            case .no:
                self.toggleButton.isSelected = false
            }
        } else {
            self.toggleButton.isSelected = false
        }
    }
    
    func setUpViewForHappiness(value: CustomBool?) {
        self.toggleButton.tag = HAISFormSections.general.rawValue
        self.titleLabel.text = HAISFormSections.general.fieldInfo.title
        self.setToggleStatus(value: value)
    }
    
    func setUpViewForSelfAssessment(value: CustomBool?) {
        self.toggleButton.tag = HAISFormSections.selfAssessment.rawValue
        self.titleLabel.text = HAISFormSections.selfAssessment.fieldInfo.title
        self.setToggleStatus(value: value)
    }
    
    func setUpViewForNutrition(value: CustomBool?) {
        self.toggleButton.tag = HAISFormSections.comprehensive.rawValue
        self.titleLabel.text = HAISFormSections.comprehensive.fieldInfo.title
        self.setToggleStatus(value: value)
    }
    
    func setUpViewForPanel(value: CustomBool?) {
        self.toggleButton.tag = HAISFormSections.general.rawValue
        self.titleLabel.text = HAISFormSections.general.fieldInfo.title
        self.setToggleStatus(value: value)
    }
}
