//
//  GradientOnText.swift
//  TemApp
//
//  Created by Shivani on 11/11/21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import Foundation

class GradientOnText{
    
    func gradientColor(bounds: CGRect, gradientLayer :CAGradientLayer) -> UIColor? {
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIColor(patternImage: image!)
    }
}
