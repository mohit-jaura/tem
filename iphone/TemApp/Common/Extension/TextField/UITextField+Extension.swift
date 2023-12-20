//
//  UITextField+Extension.swift
//  VIZU
//
//  Created by shubam on 19/09/18.
//  Copyright © 2018 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit
private var kAssociationKeyMaxLength: Int = 0
extension UITextField {
    enum Direction {
        case Left
        case Right
    }
    @IBInspectable var maxLength: Int {
        get {
            if let length = objc_getAssociatedObject(self, &kAssociationKeyMaxLength) as? Int {
                return length
            } else {
                return Int.max
            }
        }
        set {
            objc_setAssociatedObject(self, &kAssociationKeyMaxLength, newValue, .OBJC_ASSOCIATION_RETAIN)
            addTarget(self, action: #selector(checkMaxLength), for: .editingChanged)
        }
    }
    
    @objc func checkMaxLength(textField: UITextField) {
        guard let prospectiveText = self.text,
            prospectiveText.count > maxLength
            else {
                return
        }
        let selection = selectedTextRange
        let indexEndOfText = prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)
        let substring = prospectiveText[..<indexEndOfText]
        text = String(substring)
        
        selectedTextRange = selection
    }
    
    // add image to textfield
    func withImage(viewBgColor : UIColor = .white,direction: Direction, image: UIImage, colorSeparator: UIColor, colorBorder: UIColor, size: CGRect){
        let mainView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 45))
        mainView.layer.cornerRadius = 5
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 45))
        view.backgroundColor = viewBgColor
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
        view.layer.borderWidth = CGFloat(0.5)
        view.layer.borderColor = colorBorder.cgColor
        mainView.addSubview(view)
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = size
        view.addSubview(imageView)
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = colorSeparator
        mainView.addSubview(seperatorView)
        
        if(Direction.Left == direction){ // image left
            seperatorView.frame = CGRect(x: 45, y: 0, width: 5, height: 45)
            self.leftViewMode = .always
            self.leftView = mainView
        } else { // image right
            seperatorView.frame = CGRect(x: 0, y: 0, width: 5, height: 45)
            self.rightViewMode = .always
            self.rightView = mainView
        }
        self.layer.cornerRadius = 5
    }
    func setLeftImage(image:UIImage? = nil) {
        if let image = image {
            let frame = CGRect(x: 0, y: 0, width: 30, height: 16)
            let backView = UIView()
            backView.frame = frame
            let rightImageView = UIImageView()
            rightImageView.contentMode = .center//.scaleAspectFill
            rightImageView.frame = CGRect(x: 5, y: 0, width: 10, height: 10)
            rightImageView.image = image
            rightImageView.sizeToFit()
            backView.addSubview(rightImageView)
            self.leftView = backView
            self.leftViewMode = .always
            return
        }
        self.leftView = nil
    }
    
    ///add left view to the textfield
    func addleftView(image: UIImage?) {
        guard image != nil else {
            self.leftView = nil
            return
        }
        let frame = CGRect(x: 0, y: 0, width: 30, height: self.frame.height)
        let imageView = UIImageView(frame: frame)
        imageView.contentMode = .center
        imageView.image = image
        self.leftViewMode = .always
        self.leftView = imageView
    }
    
    func trim(specialCharacter: String) -> String? {
        if let trimmedText = self.text?.replacingOccurrences(of: specialCharacter, with: "") {
            return trimmedText
        }
        return nil
    }
    
    func setCustomPlaceholder(placeholder text: String?, color: UIColor = UIColor.white) {
        self.attributedPlaceholder = NSAttributedString(
            string: text ?? "",
            attributes: [NSAttributedString.Key.foregroundColor: color]
        )
    }
}
