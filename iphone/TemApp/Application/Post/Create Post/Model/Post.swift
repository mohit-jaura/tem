//
//  Post.swift
//  TemApp
//
//  Created by shilpa on 11/02/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit

enum PostType: Int, Codable {
    case normal, activity, goal, challenge
}

enum PostShareType:Int,Codable{
    case postedByUser = 1, likedByFriend, commentByFriend
}


/// The model class for the Post type
class Post: NSObject, Codable, NSCopying {
    
    // MARK: Properties
    var id: String?
    //  var profilePic: String?
    ///  var firstName: String?
    /// var lastName: String?
    // var userName:String?
    var user:Friends?
    //var userId: String?
    var caption: String?
    var tem_post_type: Int?
    var coordinates: [Double]?
    var likesCount: Int?
    var likes: [Likes]?
    var commentText:String?
    var commentsCount: Int?
    var address:Address?
    var createdAt: String?
    var updatedAt: String?
    var isDeleted: CustomBool?
    var media: [Media]?
    var isLikeByMe:Int?
    var hashtags: [String]?
    var shortLink:String?
    var activityId: String?
    var type: PostType?
    
    var tempId: String? //temporary id of the post that is generated from the timestamp
    var comments: [Comments]?
    
    var captionTags: [UserTag]?
    
    var tempCommentTaggedIds: [UserTag]?
    
    var friendsCommentCount: Int?
    var friendsLikeCount: Int?
    var postType:Int?
    
    // MARK: Coding Keys
    enum CodingKeys: String, CodingKey {
        
        //        case firstName = "first_name"
        //        case lastName = "last_name"
        //    case profilePic = "profile_pic"
        case likes
        case isLikeByMe = "like_status"
        //  case userName = "username"
        case address = "address"
        case id             = "_id"
        //   case userId         = "user_id"
        case user
        case shortLink
        case caption
        case tem_post_type
        case coordinates    = "location"
        case likesCount     = "likes_count"
        case commentsCount  = "comment_count"
        case createdAt      = "created_at"
        case updatedAt      = "updated_at"
        case isDeleted      = "is_deleted"
        case media
        case hashtags
        case tempId
        case activityId
        case type
        case comments       = "comments"
        case captionTags    = "captionTagIds"
        case friendsCommentCount
        case friendsLikeCount
        case postType
    }
    
    // MARK: JSON
    ///this will provide the Parameters to upload post
    var json: JSON? {
        self.hashtags = [String]()
        self.hashtags = self.caption?.hashtags()
        return self.json()
    }
    
    private struct JSONMappingKeys {
        static let caption = "caption"
        static let tem_post_type = "tem_post_type"
        static let location = "location"
        static let media = "media"
        static let address = "address"
    }
    
    ///return a new post that is copy of the receiver
    func copy(with zone: NSZone? = nil) -> Any {
        let data = try? JSONEncoder().encode(self)
        if let data = data {
            let copy = try? JSONDecoder().decode(Post.self, from: data)
            return copy ?? self
        }
        return Post()
    }
    
    /// call this function to increase or decrease the likes count on a post
    ///
    /// - Parameter value: true, if likes are increased else, false
    func updateLikes(withStatus value: Bool) {
        //true
        if !value {
            self.likesCount =  (self.likesCount ?? 0) + 1
            self.isLikeByMe = 1
        } else {
            self.likesCount =  (self.likesCount ?? 0) - 1
            self.isLikeByMe = 2
        }
    }
    
    func updateCommentsCount(forStatus value: Bool) {
        if value {
            self.commentsCount = (self.commentsCount ?? 0) - 1
        } else {
            self.commentsCount = (self.commentsCount ?? 0) + 1
        }
    }
    
    //updates the comment to the top of comment array
    func updateLatestComment(info: Comments, value: Bool) {
        if value == false {
            if self.comments != nil {
                if let commentsArray = self.comments {
                    if commentsArray.count == 1 {
                        self.comments?.insert(info, at: 0)
                    } else if commentsArray.count == 2 {
                        // at [0] : the latest comment
                        self.comments?.removeLast()
                        self.comments?.insert(info, at: 0)
                    } else {
                        //for zero count
                        self.comments?.append(info)
                    }
                }
            } else {
                self.comments = []
                self.comments?.append(info)
            }
        }
    }
    
    /// update the latest comments array in post model when any of the comment is deleted
    func updateLatestCommentsArray(data: [Comments], value: Bool) {
        if value == true {
            if self.comments == nil {
                self.comments = []
            }
            self.comments = data
        }
    }
    
    public class func modelsFromDictionaryArray(array:[Parameters]) -> [Post]
    {
        var postsArray:[Post] = []
        for item in array
        {
            postsArray.append(Post(dictionary: item)!)
        }
        return postsArray
    }
    
    public init?(dictionary: Parameters) {
        id = dictionary["_id"] as? String
        address = Address(json: dictionary["address"] as? Parameters ?? [:])
        if let data = dictionary["likes"] as? [Parameters] {
            likes = Likes.modelsFromDictionaryArray(array: data)
        }
        isLikeByMe = dictionary["like_status"] as? Int
        if let userData = dictionary["user"] as? Parameters {
            user = Friends(dictionary:userData)
        }
        shortLink = dictionary["shortLink"] as? String
        caption = dictionary["caption"] as? String
        tem_post_type = dictionary["tem_post_type"] as? Int
        coordinates = dictionary["coordinates"] as? [Double]
        likesCount = dictionary["likes_count"] as? Int
        commentsCount = dictionary["comment_count"] as? Int
        createdAt = dictionary["created_at"] as? String
        updatedAt = dictionary["updated_at"] as? String
        tempId = dictionary["tempId"] as? String
        activityId = dictionary["activityId"] as? String
        type = PostType(rawValue: dictionary["type"] as? Int ?? 0)
        hashtags = dictionary["hashtags"] as? [String]
        if let mediaData = dictionary["media"] as? [Parameters] {
            media = Media.modelsFromDictionaryArray(array:mediaData)
        }
        isDeleted = CustomBool(rawValue: dictionary["is_deleted"] as? Int ?? 0)
        if let comments = dictionary["comments"] as? [Parameters] {
            self.comments = Comments.modelsFromDictionaryArray(array: comments)
        }
        if let captionTags = dictionary["captionTagIds"] as? [Parameters] {
            self.captionTags = []
            self.captionTags = captionTags.toModelArray()
        }
        
        friendsCommentCount = dictionary["friendsCommentCount"] as? Int
        friendsLikeCount = dictionary["friendsLikeCount"] as? Int
        postType = dictionary["postType"] as? Int
    }
    
    override init() {
    }
}

class Likes : NSObject, Codable {
    var id: String?
    var profilePic: String?
    
    enum CodingKeys: String, CodingKey {
        case profilePic = "profile_pic"
        case id
    }
    
    override init() {
        
    }
    
    public class func modelsFromDictionaryArray(array:[Parameters]) -> [Likes] {
        var likesArray:[Likes] = []
        for item in array
        {
            likesArray.append(Likes(dictionary: item)!)
        }
        return likesArray
    }
    
    public init?(dictionary: Parameters) {
        id = dictionary["id"] as? String
        profilePic = dictionary["profile_pic"] as? String
    }
}

