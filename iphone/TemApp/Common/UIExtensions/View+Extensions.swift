//
//  View+Extensions.swift
//  TemApp
//
//  Created by Egor Shulga on 18.12.20.
//  Copyright © 2020 Capovela LLC. All rights reserved.
//

import UIKit

extension UIView {
    func elevation() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 0.18
        self.layer.shadowRadius = 1
    }
    
    func cornerRadius(r: CGFloat) {
        self.layer.cornerRadius = self.frame.height / 2 * r
    }
}
extension UIView {
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    static var identifier: String {
        return String(describing: self)
    }
}
