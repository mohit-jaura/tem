//
//  UIColor+Extensions.swift
//  YPImagePicker
//
//  Created by Nik Kov on 26.04.2018.
//  Copyright © 2018 Capovela LLC. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
}
struct StaticColors{
    var colorsArray = ["F6B205",
                       "F4AF09",
                       "F3AB0E",
                       "F1A813",
                       "F0A517",
                       "EFA31B",
                       "EE9F21",
                       "EC9D25",
                       "EB9A29",
                       " E9962E",
                       " E99433",
                       "E79137",
                       " E68D3C",
                       "E48A40",
                       "E38745",
                       " E2844A",
                       " E0814E",
                       "DF7E53",
                       "DE7B57",
                       "DD785C",
                       "DC7660",
                       "DA7264",
                       "D97069",
                       "D76C6F",
                       "D56872",
                       "D56677",
                       "D3637A",
                       "D26080",
                       " D15D84",
                       " CF5A88",
                       "CE578D",
                       "CD5492",
                       "CB5196",
                       " CA4E9C",
                       " C94BA1",
                       "C748A4",
                       "C645A9",
                       "C541AE",
                       "C43FB2",
                       "C33CB7",
                       " C139BC",
                       "C036BF",
                       "BF33C5",
                       "BD30C9",
                       "BC2DCE",
                       "BA2AD2",
                       "B926D6",
                       "B723DB",
                       "B620DF",
                       "B422E0",
                       "B126E1",
                       "AE29E1",
                       "AC2DE3",
                       "AA2FE3",
                       "A733E3",
                       "A536E5",
                       "A139E4",
                       "9F3DE6",
                       "9D40E6",
                       "9A43E6",
                       "9846E7",
                       "9549E7",
                       "934DE9",
                       "904FE9",
                       "8D53EA",
                       "8B56EA",
                       "8959EB",
                       "865CEB",
                       "8460EC",
                       "8163ED",
                       "7E65ED",
                       "7B6AEE",
                       "796CEE",
                       "7770EF",
                       "7472EF",
                       "7175F0",
                       "6F79F1",
                       "6C7DF2",
                       "6980F2",
                       "6783F3",
                       "6586F3",
                       "6288F3",
                       "608CF5",
                       "5C90F5",
                       "5A93F6",
                       "5896F7",
                       "559AF7",
                       "539CF7",
                       "50A0F8",
                       "4DA3F9",
                       "4BA6F9",
                       "49A9FA",
                       "46ACFA",
                       "43AFFB",
                       "41B3FC",
                       "3FB6FC",
                       "3CB9FD",
                       " 3ABCFE",
                       "37BFFE",
                       "33C3FE"]
    func getColor(colorValue: Int) -> UIColor{
        var colors = UIColor()
        colors = UIColor().hexStringToUIColor(hex: colorsArray[colorValue - 1])
        return colors
    }
}

extension UIColor {
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
