//
//  FAQModel.swift
//  TemApp
//
//  Created by Mac Test on 27/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit

class FaqDataArray: NSObject {
    var status:Int?
    var message:String?
    var data:[FaqData] = []
    
    // MARK: Default Initializer
    override init () {
    }
    
    convenience init(_ dictionary: Parameters) {
        self.init()
        status = dictionary["status"] as? Int
        message = dictionary["message"] as? String ?? ""

        
        if let dataArray = dictionary["data"] as? [[String:Any]]{
            for dic in dataArray{
                let value = FaqData(fromDictionary: dic)
                
                data.append(value)
            }
        }

    }
}

class FaqData: NSObject {
    var id:Int?
    var name:String?
    var heading:String?
    var desc:String?
    var type:Int?
    var status:Int?
    var createdAt:String?
    var updatedAt:String?
    var restaurant_app_check:Int?
    var image : [String]!
    
    init(fromDictionary dictionary: [String:Any]){
        print(dictionary)
        id = dictionary["_id"] as? Int
        heading = dictionary["heading"] as? String ?? ""
        desc = dictionary["description"] as? String ?? ""
        image = dictionary["image"] as? [String] ?? []
//        print("======11 ",image!.count)

    }
}
