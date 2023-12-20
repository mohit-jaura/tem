//
//  Extension+UIBezierPath.swift
//  HexagonView
//
//  Created by Sourav on 2/25/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit

extension UIBezierPath {
    
    convenience init?(frame: CGRect, numberOfSides: UInt, cornerRadius: CGFloat) {
        
        guard frame.width == frame.height else { return nil }
        
        let squareWidth = frame.width
        
        guard numberOfSides > 0 && cornerRadius >= 0.0 && 2.0 * cornerRadius < squareWidth && !frame.isInfinite && !frame.isEmpty && !frame.isNull else {
            
            return nil
        }
        
        self.init()
        
        // how much to turn at every corner
        let theta =  2.0 * .pi / CGFloat(numberOfSides)
        let halfTheta = 0.5 * theta
        
        // offset from which to start rounding corners
        let offset: CGFloat = cornerRadius * CGFloat(tan(halfTheta))
        
        var length = squareWidth - self.lineWidth
        if numberOfSides % 4 > 0 {
            
            length = length * cos(halfTheta)
        }
        
        let sideLength = length * CGFloat(tan(halfTheta))
        
        // start drawing at 'point' in lower right corner
        let p1 = 0.5 * (squareWidth + sideLength) - offset
        let p2 = squareWidth - 0.5 * (squareWidth - length)
        var point = CGPoint(x: p1, y: p2)
        var angle = CGFloat.pi
        
        self.move(to: point)
        
        // draw the sides around rounded corners of the polygon
        for _ in 0..<numberOfSides {
            
            let x1 = CGFloat(point.x) + ((sideLength - offset * 2.0) * CGFloat(cos(angle)))
            let y1 = CGFloat(point.y) + ((sideLength - offset * 2.0) * CGFloat(sin(angle)))
            
            point = CGPoint(x: x1, y: y1)
            self.addLine(to: point)
            
            let centerX = point.x + cornerRadius * CGFloat(cos(angle + 0.5 * .pi))
            let centerY = point.y + cornerRadius * CGFloat(sin(angle + 0.5 * .pi))
            let center = CGPoint(x: centerX, y: centerY)
            let startAngle = CGFloat(angle) - 0.5 * .pi
            let endAngle = CGFloat(angle) + CGFloat(theta) - 0.5 * .pi
            
            self.addArc(withCenter: center, radius: cornerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            point = self.currentPoint
            angle += theta
            
        }
        
        self.close()
    }
    
    
    
    
    
    convenience init?(frame: CGRect, sides: UInt, cornerRadius: CGFloat) {
        self.init()
        let theta: CGFloat = CGFloat(2.0 * Double.pi) / CGFloat(6) // How much to turn at every corner
        let _: CGFloat = cornerRadius * tan(theta / 2.0)     // Offset from which to start rounding corners
        let width = min(frame.size.width, frame.size.height)        // Width of the square
        
        let center = CGPoint(x: frame.origin.x + width / 2.0, y: frame.origin.y + width / 2.0)
        
        // Radius of the circle that encircles the polygon
        // Notice that the radius is adjusted for the corners, that way the largest outer
        // dimension of the resulting shape is always exactly the width - linewidth
        let radius = (width - lineWidth + 2.0 - (cos(theta) * cornerRadius)) / 2.0
        self.lineWidth = 4.0
        // Start drawing at a point, which by default is at the right hand edge
        // but can be offset
        var angle = CGFloat(Double.pi / 2.0)
        let corner = CGPoint(x: center.x + (radius - cornerRadius) * cos(angle), y: center.y + (radius - cornerRadius) * sin(angle))
        self.move(to: CGPoint(x: corner.x + cornerRadius * cos(angle + theta), y: corner.y + cornerRadius * sin(angle + theta)))
        
        for _ in 0..<sides {
            angle += theta
            
            let corner = CGPoint(x: center.x + (radius - cornerRadius) * cos(angle), y: center.y + (radius - cornerRadius) * sin(angle))
            _ = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
            let start = CGPoint(x: corner.x + cornerRadius * cos(angle - theta), y: corner.y + cornerRadius * sin(angle - theta))
            _ = CGPoint(x: corner.x + cornerRadius * cos(angle + theta), y: corner.y + cornerRadius * sin(angle + theta))
            let end = CGPoint(x: corner.x + cornerRadius * cos(angle + theta), y: corner.y + cornerRadius * sin(angle + theta))
            let tip = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
            
            self.addLine(to: start)
            self.addQuadCurve(to: end, controlPoint: tip)
            
            
            
            
        }
        self.close()
        
    }
    
}

extension UIBezierPath {
    convenience init( rect: CGRect, sides: Int, lineWidth: CGFloat = 1, cornerRadius: CGFloat = 0) {
        self.init()

        let theta = 2 * .pi / CGFloat(sides)                 // how much to turn at every corner
        let offset = cornerRadius * tan(theta / 2)           // offset from which to start rounding corners
        let squareWidth = min(rect.width, rect.height)       // width of the square

        // calculate the length of the sides of the polygon

        var length = squareWidth - lineWidth
        if sides % 4 != 0 {                                  // if not dealing with polygon which will be square with all sides ...
            length = length * cos(theta / 2) + offset / 2    // ... offset it inside a circle inside the square
        }
        let sideLength = length * tan(theta / 2)
         var point = CGPoint(x: rect.midX - length / 2, y: rect.midY + sideLength / 2 - offset)
         var angle = -CGFloat.pi / 2.0
        move(to: point)

        // draw the sides and rounded corners of the polygon

        for _ in 0 ..< sides {
            point = CGPoint(x: point.x + (sideLength - offset * 2) * cos(angle), y: point.y + (sideLength - offset * 2) * sin(angle))
            addLine(to: point)

            let center = CGPoint(x: point.x + cornerRadius * cos(angle + .pi / 2), y: point.y + cornerRadius * sin(angle + .pi / 2))
            addArc(withCenter: center, radius: cornerRadius, startAngle: angle - .pi / 2, endAngle: angle + theta - .pi / 2, clockwise: true)

            point = currentPoint
            angle += theta
        }
        close()
        self.lineWidth = lineWidth
        lineJoinStyle = .bevel
    }

}
