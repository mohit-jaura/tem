//
//  FaqsVM.swift
//  TemApp
//
//  Created by Shiwani Sharma on 06/03/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation

class FaqsViewModel{
    var faqsList: [FaqList]?
    var error: DIError?
    var isOpened: Bool{
       return false
    }
    
    func getFaqsList(affID: String,completion: @escaping OnlySuccess){
        DIWebLayerCoachingToolsAPI().getFaqsList( affiliateId: affID, success: { list in
            self.faqsList = list
            completion()
        }, failure: { error in
            self.error = error
        })
    }
}
