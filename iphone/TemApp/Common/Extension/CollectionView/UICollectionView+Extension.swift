//
//  UICollectionView+Extension.swift
//  TemApp
//
//  Created by dhiraj on 18/02/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit
extension UICollectionView {
    
    func setEmptyMessage(_ message: String, textColor: UIColor = #colorLiteral(red: 0.1803921569, green: 0.1803921569, blue: 0.1803921569, alpha: 1)) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = textColor
        messageLabel.numberOfLines = 0 
        messageLabel.textAlignment = .center 
        messageLabel.font = UIFont(name: UIFont.avenirNextRegular, size: 15)
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel 
    }
    
    func restore() {
        self.backgroundView = nil
    }
    
    func registerNibsForCollectionView(nibNames: [String]) {
        for nibName in nibNames {
            let nib = UINib(nibName: nibName, bundle: nil)
            self.register(nib, forCellWithReuseIdentifier: nibName)
        }
    }
}
