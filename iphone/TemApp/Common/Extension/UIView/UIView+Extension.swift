//
//  UIView+Extension.swift
//  TemApp
//
//  Created by shilpa on 19/02/19.
//  Copyright © 2019 Saurav. All rights reserved.
//

import Foundation
import UIKit
extension UIView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
