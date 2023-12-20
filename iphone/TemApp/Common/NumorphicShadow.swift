//
//  NumorphicShadow.swift
//  TemApp
//
//  Created by Shiwani Sharma on 10/01/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import Foundation
import SSNeumorphicView

class NumorphicShadow {
    
 public func addNeumorphicShadow(view: SSNeumorphicView, shadowType: ShadowLayerType, cornerRadius: CGFloat, shadowRadius: CGFloat , mainColor: CGColor, opacity: Float, darkColor: CGColor, lightColor: CGColor, offset: CGSize){
        view.viewDepthType = shadowType
        view.viewNeumorphicCornerRadius = cornerRadius
        view.viewNeumorphicShadowRadius = shadowRadius
        view.viewNeumorphicMainColor = mainColor
        view.viewNeumorphicShadowOpacity = opacity
        view.viewNeumorphicDarkShadowColor =  darkColor
        view.viewNeumorphicShadowOffset = offset
        view.viewNeumorphicLightShadowColor = lightColor
    }
    
}
 
