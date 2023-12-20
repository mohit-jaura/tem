//
//  ViewDecorator.swift
//  TemApp
//
//  Created by shilpa on 22/07/20.
//  Copyright © 2020 Capovela LLC. All rights reserved.
//

import Foundation

/// This struct will manage the values of the view decoartion properties like border color, border width, shadow radius
struct ViewDecorator {
    static let viewBorderWidth: CGFloat = 1.0
    static let viewBorderColor: UIColor = UIColor.gray
    static let viewShadowRadius: Double = 5.0
    static let viewShadowColor: CGColor = UIColor.black.cgColor
    static let viewShadowOpacity: Float = 0.2
}
