//
//  Extension+UIlabel.swift
//  TemApp
//
//  Created by Sourav on 4/17/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func blink() {
        self.alpha = 0.0 
        UIView.animate(withDuration: 0.5, //Time duration you want,
            delay: 0.0,
            options: [.curveEaseInOut, .autoreverse, .repeat],
            animations: { [weak self] in self?.alpha = 1.0 },
            completion: { [weak self] _ in self?.alpha = 0.0 })
    }
}
extension UILabel {
    
    
    //THis Fucntion will return number of lines...
    
    func calculateMaxLines(label: UILabel) -> Int {
            layoutIfNeeded()
            let textSize = CGSize(width: label.frame.size.width, height: CGFloat(Float.infinity))
            let rHeight = lroundf(Float(label.sizeThatFits(textSize).height))
            let charSize = lroundf(Float(label.font.lineHeight))
            let lineCount = rHeight/charSize
            return lineCount
        
//        let count = self.text?.count ?? 0
//        return count > 130 ? 3 : 1
    }
    
}


