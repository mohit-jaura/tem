//
//  CustomSlider.swift
//  TemApp
//
//  Created by shilpa on 29/07/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit

class CustomSlider: UISlider {
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = super.trackRect(forBounds: bounds)
        newBounds.size.height = 6
        return newBounds
    }
}

extension UISlider {
    var thumbCenterX: CGFloat {
        //        let trackRect = self.trackRect(forBounds: frame)
        //        let thumbRect = self.thumbRect(forBounds: bounds, trackRect: trackRect, value: value)
        //        return thumbRect.midX
        let trackRect = self.trackRect(forBounds: frame)
        let thumbRect = self.thumbRect(forBounds: bounds, trackRect: trackRect, value: value)
        return thumbRect.midX//thumbRect.origin.x
    }
}
