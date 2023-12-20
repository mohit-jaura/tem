//
//  InputFieldTableViewCell.swift
//  TemApp
//
//  Created by shilpa on 23/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import SSNeumorphicView

/// View model for the input tableview cell
struct InputFieldTableCellViewModel {
    
    var title: String
    var inputIconImage: UIImage
    var value: Any?
    var errorMessage:String
    var isHighlighted: Bool
    var rightIconImage: UIImage?
    var toggleState:Bool
}

protocol InputFieldTableCellDelegate: AnyObject {
    func inputTextFieldDidEndEditing(textField: UITextField)
    func inputTextFieldDidBeginEditing(textField: UITextField)
    func didTapDoneOnInputTextField(sender: UIBarButtonItem)
    func inputTextFieldShouldBeginEditing(textField: UITextField) -> Bool
    func inputTextFieldEditingChanged(textField: UITextField)
    func inputTextFieldShouldChangeCharacters(textField: UITextField, range: NSRange, replacementString string: String) -> Bool
    func didTapOnButtonOnInputField(sender: UIButton)
    func didTapOnRightView(sender: UIButton)
}

extension InputFieldTableCellDelegate {
    func inputTextFieldShouldBeginEditing(textField: UITextField) -> Bool { return true }
    func inputTextFieldEditingChanged(textField: UITextField) {}
    func inputTextFieldShouldChangeCharacters(textField: UITextField, range: NSRange, replacementString string: String) -> Bool { return true }
    func didTapOnButtonOnInputField(sender: UIButton) {}
    func didTapOnRightView(sender: UIButton) {}
}

class InputFieldTableViewCell: UITableViewCell {
    
    // MARK: Properties
    weak var delegate: InputFieldTableCellDelegate?
    
    // MARK: IBOutlets
    @IBOutlet weak var inputTextField: CustomTextField!
    @IBOutlet weak var inputTextFieldShadowView: SSNeumorphicView!
    
    @IBOutlet weak var toggleButtonShadowView: SSNeumorphicView!{
        didSet{
            self.createShadowView(view: inputTextFieldShadowView, shadowType: .innerShadow, cornerRadius: toggleButtonShadowView.frame.width / 2, shadowRadius: 3,mainColor: UIColor.white.cgColor, lightShadowColor: UIColor.white.withAlphaComponent(0.7).cgColor, darkShadowView: UIColor.black.withAlphaComponent(0.3).cgColor)
        }
    }
    
    @IBOutlet weak var toggleButton:UIButton!
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var toggleButtonTrailingConstraint:NSLayoutConstraint!
    
    // MARK: IBActions
    @IBAction func topButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapOnButtonOnInputField(sender: sender)
    }
    
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        inputTextField.addTarget(self, action: #selector(editingChanged(textField:)), for: .editingChanged)
    }
    
    // MARK: IBACTIONS
    
    @IBAction func toggleButtonTapped(_ sender:UIButton){
        sender.isSelected.toggle()
    }

    // MARK: Initializer
    
    func showToggle(isHide:Bool){
        toggleButtonShadowView.isHidden = isHide
        toggleButton.isHidden = isHide
        if isHide{
            self.toggleButtonTrailingConstraint.constant = 0
        }else{
            self.toggleButtonTrailingConstraint.constant = 40
        }
    }
    func initializeWith(viewModel: InputFieldTableCellViewModel, indexPath: IndexPath) {
        self.inputTextField.tag = indexPath.section
        self.topButton.tag = indexPath.section
        self.toggleButton.isSelected = viewModel.toggleState
        self.inputTextField.delegate = self
        self.inputTextField.errorMessage = viewModel.errorMessage
        if viewModel.rightIconImage != nil {
            self.topButton.isHidden = false
        } else {
            self.topButton.isHidden = true
            self.inputTextField.rightView = nil
        }
        self.inputTextField.rightView = nil
        self.inputTextField.text = ""
        if let value = viewModel.value {
            self.inputTextField.text = "\(value)"
        }
        self.inputTextField.changeViewFor(selectedState: viewModel.isHighlighted)
        self.inputTextField.keyboardToolbar.doneBarButton.tag = indexPath.section
        self.inputTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneTappedOnInputTextField(sender:)))
    }
    
    // MARK: Helpers
    /// add right view to the textfield
    /// - Parameter image: image
    func addRightView(image: UIImage?) -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.frame = CGRect(x: CGFloat(self.inputTextField.frame.size.width - 30), y: CGFloat(5), width: CGFloat(30), height: CGFloat(30))
        button.tag = inputTextField.tag
        button.addTarget(self, action: #selector(self.rightViewTappedOnTextField(sender:)), for: .touchUpInside)
        return button
    }
    
    func displayErrorMessage(errorMessage: String) {
        self.inputTextField.errorMessage = errorMessage
    }
    
    @objc func doneTappedOnInputTextField(sender: UIBarButtonItem) {
        self.delegate?.didTapDoneOnInputTextField(sender: sender)
    }
    
    @objc func editingChanged(textField: UITextField) {
        self.delegate?.inputTextFieldEditingChanged(textField: textField)
    }
    
    @objc func rightViewTappedOnTextField(sender: UIButton) {
        self.beginEditing()
        self.delegate?.didTapOnRightView(sender: sender)
    }
    
    func beginEditing() {
        self.topButton.isHidden = true
        self.inputTextField.becomeFirstResponder()
    }
    
    func endEditing() {
        self.topButton.isHidden = false
    }
    
    func createShadowView(view: SSNeumorphicView, shadowType: ShadowLayerType, cornerRadius:CGFloat,shadowRadius:CGFloat, mainColor:CGColor , lightShadowColor:CGColor, darkShadowView:CGColor){
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor =  mainColor
        view.viewNeumorphicLightShadowColor = lightShadowColor
        view.viewNeumorphicDarkShadowColor = darkShadowView
        view.viewNeumorphicCornerRadius = cornerRadius
        view.viewNeumorphicShadowRadius = shadowRadius
        view.viewNeumorphicShadowOffset = CGSize(width: 2, height: 2 )
    }
    
    func customiseTextFieldShadowFromCell(cornerRadius:CGFloat, shadowType: ShadowLayerType, shadowRadius:CGFloat, mainColor:CGColor , lightShadowColor:CGColor, darkShadowView:CGColor){
        self.createShadowView(view: self.inputTextFieldShadowView, shadowType: shadowType, cornerRadius: cornerRadius, shadowRadius: shadowRadius, mainColor:mainColor , lightShadowColor:lightShadowColor, darkShadowView:darkShadowView)
    }
}

// MARK: UITextFieldDelegate
extension InputFieldTableViewCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.delegate?.inputTextFieldDidBeginEditing(textField: textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let textfield = textField as? CustomTextField {
            textfield.changeViewFor(selectedState: false)
        }
        self.delegate?.inputTextFieldDidEndEditing(textField: textField)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let textField = textField as? CustomTextField {
            textField.changeViewFor(selectedState: true)
        }
        if let value = self.delegate?.inputTextFieldShouldBeginEditing(textField: textField) {
            return value
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let value = self.delegate?.inputTextFieldShouldChangeCharacters(textField: textField, range: range, replacementString: string) {
            return value
        }
        return true
    }
}
