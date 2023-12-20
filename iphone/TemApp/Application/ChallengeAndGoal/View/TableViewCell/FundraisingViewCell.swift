//
//  FundraisingView.swift
//  TemApp
//
//  Created by Egor Shulga on 22.02.21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import Foundation

class FundraisingViewModel {
    var info: GroupActivity?
    var fundsDestinationError: String?
    var goalAmountError: String?
}

protocol FundraisingViewCellDelegate : AnyObject {
    func showFundsDestinationSelection()
    func goalAmountChanged(value: Decimal?)
}

class FundraisingViewCell : UITableViewCell {
    @IBOutlet weak var fundsDestination: CustomTextField!
    @IBOutlet weak var goalAmount: CustomTextField!
    
    var delegate: FundraisingViewCellDelegate?
    
    func initialize(_ delegate: FundraisingViewCellDelegate, _ viewModel: FundraisingViewModel, _ isEditing: Bool) {
        self.delegate = delegate
        fundsDestination.delegate = self
        goalAmount.delegate = self
        fundsDestination.text = viewModel.info?.fundraising?.destination?.description()
        goalAmount.text = "\(viewModel.info?.fundraising?.goalAmount ?? 0)"
        goalAmount.addTarget(self, action: #selector(goalAmountChanged(textField:)), for: .editingChanged)
        fundsDestination.changeViewFor(selectedState: false)
        self.fundsDestination.errorMessage = viewModel.fundsDestinationError ?? ""
        self.goalAmount.errorMessage = viewModel.goalAmountError ?? ""
        fundsDestination.setUserInteraction(shouldEnable: !isEditing)
    }
    
    @objc func goalAmountChanged(textField: UITextField) {
        let text = textField.text ?? ""
        let value = Decimal(string: text)
        delegate?.goalAmountChanged(value: value)
    }
}

extension FundraisingViewCell : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let textField = textField as? CustomTextField {
            textField.changeViewFor(selectedState: true)
        }
        if textField == fundsDestination {
            delegate?.showFundsDestinationSelection()
            return false
        } else {
            return true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField != goalAmount {
            return true
        } else {
            let inverseSet = NSCharacterSet(charactersIn:"0123456789").inverted
            let components = string.components(separatedBy: inverseSet)
            let filtered = components.joined(separator: "")
            if filtered == string {
                return true
            } else {
                if string == "." {
                    let countdots = textField.text!.components(separatedBy:".").count - 1
                    if countdots == 0 {
                        return true
                    } else {
                        if countdots > 0 && string == "." {
                            return false
                        } else {
                            return true
                        }
                    }
                } else {
                    return false
                }
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let textfield = textField as? CustomTextField {
            textfield.changeViewFor(selectedState: false)
        }
    }
}
