//
//  CustomTextField.swift
//  TemApp
//
//  Created by dhiraj on 12/02/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit

protocol CustomTextFieldDelegate: AnyObject {
    func didUpdateErrorLabelOn(textfield: CustomTextField, errorHeight: CGFloat)
}

@IBDesignable
open class CustomTextField: UITextField, UITextFieldDelegate, ViewTaggable {
    var row: Int = 0
    
    var section: Int = 0
    
    var errorLabel:UILabel!
    let myLabel = UILabel()
    weak var customFieldDelegate: CustomTextFieldDelegate?
    lazy var padding = UIEdgeInsets(top: 0, left:leftPadding, bottom: 0, right: 30)
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
        self.setAttributes()
        addShadow()
    }
    func addShadow(){
        self.layer.shadowOpacity = 0.3
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 5
        self.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.layer.shadowOffset = CGSize(width: 2, height: 3)
    }
    @IBInspectable
    public var labelTitle: String = "" {
        didSet {
 //      setTitleLable()  //- Comment This
        }
    }
    
    @IBInspectable
    public var errorMessage: String = "" {
        didSet {
            addErrorLabel()
        }
    }
    
//    @IBInspectable var leftImage: UIImage? {
//        didSet {
//            updateView()
//        }
//    }
    
    @IBInspectable var leftImagewithUrl : String? {
        didSet {
//            updateView(isUrl:true)
        }
    }
    
    @IBInspectable
    public var leftPadding: CGFloat = 10
    
    @IBInspectable
    public var color: UIColor = UIColor.lightGray {
        didSet {
//            updateView()
        }
    }

    @IBInspectable var placeHolderColor: UIColor? {
            get {
                return self.placeHolderColor
            }
            set {
                self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
            }
        }
    func setAttributes() {
        self.superview?.addSubview(myLabel)
        addErrorLabel()
       // self.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.rightViewMode = .always
        self.leftViewMode = .always
   //     self.layer.borderWidth = 1 //- Comment this
     //   self.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1) //- Comment this
    }
    
    func addErrorLabel() {
        if self.errorLabel != nil {
            self.errorLabel.removeFromSuperview()
        }
//        let heightOfString = labelTitle.heightOfString(usingFont: font!)
        let errorFont = UIFont(name: UIFont.avenirNextMedium, size: 11)
        errorLabel = UILabel(frame: CGRect(x: self.frame.origin.x+2, y: self.frame.maxY+2, width: self.frame.size.width, height: 12))
        errorLabel.text = errorMessage
        errorLabel.backgroundColor = .clear
        errorLabel.numberOfLines = 0
        errorLabel.textColor = .red
        errorLabel.font = errorFont
        errorLabel.textAlignment = .left
        errorLabel.sizeToFit()
        self.superview?.addSubview(errorLabel)
        self.customFieldDelegate?.didUpdateErrorLabelOn(textfield: self, errorHeight: self.errorLabel.frame.height)
    }
    
    // Provides left padding for images
  /*  override open func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += leftPadding
        return textRect
    }*/
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
          return bounds.inset(by: padding)
    }
    open override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.width - 25, y: 13, width: 15, height: 15)
    }
    
    func updateView(isUrl:Bool = false) {
 /*       if let image = leftImage {
            leftViewMode = UITextField.ViewMode.always
            var view = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 20))
            var imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            if self.tag == 100 {
                imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 20))
                view = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 20))
            }
            imageView.contentMode = .scaleAspectFit
            // Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
            if isUrl {
                if let imageString = leftImagewithUrl {
                    if let imageUrl = URL(string:imageString) {
                        imageView.kf.setImage(with: imageUrl, placeholder:#imageLiteral(resourceName: "activityWhite"))
                    }else{
                        imageView.image = #imageLiteral(resourceName: "activityWhite")
                    }
                }else{
                    imageView.image = #imageLiteral(resourceName: "activityWhite")
                }
            }else{
                imageView.image = image
            }
            imageView.tintColor = color
            imageView.clipsToBounds = true
            view.addSubview(imageView)
            leftView = view//imageView
        } else {
            leftViewMode = UITextField.ViewMode.always
            leftView = nil
        }
        // Placeholder text color
        attributedPlaceholder = NSAttributedString(string: placeholder != nil ?  placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: color])*/
    }
    
    //returns the left added image view inside left view of textfield
    func leftImageView() -> UIImageView? {
        if let leftView = self.leftView,
            let addedImageView = leftView.subviews.last as? UIImageView {
            return addedImageView
        }
        return nil
    }
    
 private func setTitleLable() {
        myLabel.text = "    " + labelTitle + "    "
        let font = UIFont(name: "Roboto-Medium", size: 12)
        let heightOfString = labelTitle.heightOfString(usingFont: font!)
        let x_cord = self.frame.origin.x + 10
        let y_cord = self.frame.origin.y - (heightOfString/2)
        let widthofString = labelTitle.widthOfString(usingFont: font!)
        var widthOfLabel:CGFloat = widthofString - 20
        if widthofString > self.frame.width {
            widthOfLabel = widthofString
        }
        myLabel.frame = CGRect(x: x_cord, y: y_cord, width: widthOfLabel, height: heightOfString)
        myLabel.backgroundColor = .white
        myLabel.font = font
        myLabel.textAlignment = .left
        myLabel.sizeToFit()
     }

    
    func changeViewFor(selectedState isSelected: Bool) {
        let color: UIColor
        if isSelected {
            color = #colorLiteral(red: 0, green: 0.5882352941, blue: 0.8980392157, alpha: 1)
        } else {
            color = #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1)
        }
        self.layer.borderColor = color.cgColor
        myLabel.textColor = UIColor.textBlackColor
        if let imageView = self.leftImageView() {
            imageView.image = imageView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            imageView.tintColor = color
        }
    }
    
    func setUserInteraction(shouldEnable: Bool) {
        let color = shouldEnable ? #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1) : UIColor(red: 169/255, green: 169/255, blue: 169/255, alpha: 0.6)
        let labelTextColor = shouldEnable ? UIColor.textBlackColor : UIColor(red: 169/255, green: 169/255, blue: 169/255, alpha: 0.6)
        self.isUserInteractionEnabled = shouldEnable
        self.textColor = labelTextColor
        myLabel.textColor = labelTextColor
        self.layer.borderColor = color.cgColor
        if let imageView = self.leftImageView() {
            imageView.image = imageView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            imageView.tintColor = color
        }
    }
    
    private func formatDate(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            return true
        }
        if let text = textField.trim(specialCharacter: "-"), text.count == 8 {
            return false
        }
        if range.location == 0 {
            let cs = NSCharacterSet(charactersIn: "01").inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            return (filtered == string)
        }
        //months validation
        if range.location == 1 {
            
            let allowableCharacterSetPrefixingZero = "0123456789"
            let allowableCharacterSetPrefixingOne = "012"
            let currentText = textField.text ?? ""
            if currentText == "0" {
                let characterSet = NSCharacterSet(charactersIn: allowableCharacterSetPrefixingZero).inverted
                let filtered = string.components(separatedBy: characterSet).joined(separator: "")
                return (filtered == string)
            }
            if currentText == "1" {
                let characterSet = NSCharacterSet(charactersIn: allowableCharacterSetPrefixingOne).inverted
                let filtered = string.components(separatedBy: characterSet).joined(separator: "")
                return (filtered == string)
            }
        }
        //days validation
        if range.location == 3 {
//            if let dayEntered = textField.text?.components(separatedBy: "-").last {
//
//            }
        }
        if range.location == 2 || range.location == 5 {
            textField.text?.append("-")
            return true
        }
        return true
    }
}

