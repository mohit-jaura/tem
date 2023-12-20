//
//  Cart.swift
//  TemApp
//
//  Created by PrabSharan on 21/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import Foundation

class Cart {
   class func addToCart(_ count:Int) {
           if getCartCount() != count {
               Defaults.shared.set(value: count, forKey: .cart)
               
               NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.NotiName.cartUpdate), object: nil, userInfo: nil)
           }
    }
    class  func getCartCount() -> Int {
        if let count = Defaults.shared.get(forKey: .cart) as? Int {
            return count
        }
        return 0
    }
    class func apiToGetCart(_ completion:CompletionDataApi? = nil, _ parent:DIBaseController? = nil) {
        
        let apiInfo = EndPoint.CheckCart
        
        DIWebLayerRetailAPI().getCart(endPoint: apiInfo.url, parent: parent) { status in
            completion?(status)
        }
    }
}
