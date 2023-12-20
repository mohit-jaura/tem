//
//  FBFriendModal.swift
//  FriendSpire
//
//  Created by abhishek on 24/07/18.
//  Copyright © 2018 Capovela LLC. All rights reserved.
//


//Note *  This class modal used for repsponse come from Facebook 
import UIKit

class FBFriendModal: Codable {
    
    var firstName : String?
    var id : String?
    var lastName : String?
    var name : String?
    var picture : Picture?
    
    enum CodingKeys: String, CodingKey {
        case firstName =  "first_name"
        case id =  "id"
        case lastName =  "last_name"
        case name =  "name"
        case picture =  "picture"
    }
}


class Picture :Codable{
    
    var data : DataFB?
    enum CodingKeys: String, CodingKey {
        case data =  "data"
    }
}

class DataFB: Codable {
    var url : String?
    enum CodingKeys: String, CodingKey {
        case url =  "url"
    }
}
