//
//  Media.swift
//
//  Created by Aj Mehra on 03/07/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit
enum MediaType: Int, Codable {
	case photo = 1
	case video = 2
    case pdf = 3
    
    var mediaExt: String {
        switch self {
        case .photo:
            return ".jpg"
        case .video:
            return ".mp4"
        case .pdf:
            return ".pdf"
        }
    }
}

class Media: Codable {
	
	var id: String?                     //not decodable
    var name: String?                   //not decodable
	var url: String?
	var type: MediaType?
	var data: Data?                     //not decodable
	var image: UIImage?                 //not decodable
	var duration: Double?//String?
	var mimeType: String?
	var ext: String?
	var postId: String?                 //not decodable
	var previewImageUrl: String?
    var height: Double?
    var imageRatio: CGFloat?
    var taggedPeople: [UserTag]?

    enum CodingKeys: String, CodingKey {
        case url
        case type
        case duration
        case mimeType
        case ext                = "extension"
        case previewImageUrl    = "preview_url"
        case height
        case imageRatio         = "imageRatio"
        case taggedPeople       = "postTagIds"
    }
    init() {
        
    }
    init(url: String, type: MediaType, previewImageUrl: String? = nil, name: String? = "") {
        self.type = type
        self.url = url
        if let previewUrl = previewImageUrl {
            self.previewImageUrl = previewUrl
        }
        self.name = name
    }
    
    public class func modelsFromDictionaryArray(array:[Parameters]) -> [Media] {
        var mediaArray:[Media] = []
        for item in array
        {
            mediaArray.append(Media(dictionary: item)!)
        }
        return mediaArray
    }
    
    public init?(dictionary: Parameters) {
        id = dictionary["_id"] as? String
        url = dictionary["url"] as? String
        name = dictionary["name"] as? String
        mimeType = dictionary["mimeType"] as? String
        ext = dictionary["ext"] as? String
        duration = dictionary["duration"] as? Double
        height = dictionary["height"] as? Double
        type = MediaType(rawValue: dictionary["type"] as? Int ?? 0)
        previewImageUrl = dictionary["preview_url"] as? String
        if let taggedUsers = dictionary["postTagIds"] as? [Parameters] {
            self.taggedPeople = []
            self.taggedPeople = taggedUsers.toModelArray()
        }
    }
    
    ///return a new media object that is copy of the receiver
//    func copy(with zone: NSZone? = nil) -> Any {
//        let mediaCopy = Media(dictionary: <#Parameters#>)
//        mediaCopy.id = self.id
//        mediaCopy.name = self.name
//        mediaCopy.url = self.url
//        mediaCopy.type = self.type
//        mediaCopy.data = self.data
//        mediaCopy.image = self.image
//        mediaCopy.duration = self.duration
//        mediaCopy.mimeType = self.mimeType
//        mediaCopy.ext = self.ext
//        mediaCopy.postId = self.postId
//        mediaCopy.previewImageUrl = self.previewImageUrl
//        mediaCopy.height = self.height
//        mediaCopy.imageRatio = self.imageRatio
//        mediaCopy.taggedPeople = self.taggedPeople
//        return mediaCopy
//    }
}
