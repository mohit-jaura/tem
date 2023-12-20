//
//  NavigationClass.swift
//  TemApp
//
//  Created by PrabSharan on 21/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit

class NavigTO {
    var navigation:UINavigationController?
    class var  navigateTo:NavigTO? {
        struct Static {
            static let instance :NavigTO = NavigTO()
        }
        return Static.instance
    }
}
