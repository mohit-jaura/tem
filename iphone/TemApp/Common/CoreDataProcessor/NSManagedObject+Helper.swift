//
//  NSManagedObject+Helper.swift
//  
//
//  Created by Dhiraj on 21/06/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import UIKit


import Foundation
import CoreData
extension NSManagedObject{
    
    @objc func saveDetailsInDB(object:Any){
        
    }
    
    func getAutoIncremenet(objectId:NSManagedObjectID) -> String   {
        
        let url = objectId.uriRepresentation()
        let urlString = url.absoluteString
        if let pN = urlString.components(separatedBy: "/").last {
            let numberPart = pN.replacingOccurrences(of: "-", with: "")
            if numberPart.length > 0{
                return numberPart
            }
        }
        return ""
    }

}
