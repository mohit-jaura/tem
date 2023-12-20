//
//  Postinfo+CoreDataProperties.swift
//  TemApp
//
//  Created by shilpa on 13/02/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import CoreData

extension Postinfo {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Postinfo> {
        return NSFetchRequest<Postinfo>(entityName: "Postinfo")
    }
    
    @NSManaged public var hasmedia: Bool
    @NSManaged public var id: String? // this will initially store the local id and once the post is uploaded to the server, this key will contain the server post id
    @NSManaged public var isuploaded: Bool
    @NSManaged public var title: String?
    @NSManaged public var tem_post_type: NSNumber?
    @NSManaged public var address_rel: PostAddress?
    @NSManaged public var files_rel: NSOrderedSet?
    @NSManaged public var uploadingInProgress: Bool
    @NSManaged public var likesCount: String?
    @NSManaged public var commentsCount: String?
    @NSManaged public var likedByMe: Bool
    @NSManaged public var dateTime: String?
    @NSManaged public var user_rel: UserDetail?
    @NSManaged public var localId: String? //this will store the local post id that we are generating
    @NSManaged public var likes_rel: NSOrderedSet?
    @NSManaged public var tag_rel: NSOrderedSet?
    
    override func saveDetailsInDB(object: Any) {
        let post: Post = object as! Post
        title  = post.caption ?? ""
        if let value = post.tem_post_type as? NSNumber{
            tem_post_type = value
        } else {
            print("could not save media height in core data")
        }
        
        if let id = post.id {
            self.id = id
        } else {
            id = "Post_" + String(Utility.shared.currentTimeStamp())
        }
        if let id = post.tempId {
            self.localId = id
        } else {
            self.localId = self.id//"Post_" + String(Utility.shared.currentTimeStamp())
        }
        isuploaded = false
        uploadingInProgress = false
        self.dateTime = post.createdAt
        if let likesCount = post.likesCount {
            self.likesCount = "\(likesCount)"
        }
        if let commentsCount = post.commentsCount {
            self.commentsCount = "\(commentsCount)"
        }
        self.likedByMe = false
        if let myLikeStatus = post.isLikeByMe {
            if myLikeStatus == 1 {
                self.likedByMe = true
            } else {
                self.likedByMe = false
            }
        }
    }
}

// MARK: Generated accessors for files_rel
extension Postinfo {
    
    @objc(addFiles_relObject:)
    @NSManaged public func addToFiles_rel(_ value: FilesInfo)
    
    @objc(removeFiles_relObject:)
    @NSManaged public func removeFromFiles_rel(_ value: FilesInfo)
    
    @objc(addFiles_rel:)
    @NSManaged public func addToFiles_rel(_ values: NSOrderedSet)
    
    @objc(removeFiles_rel:)
    @NSManaged public func removeFromFiles_rel(_ values: NSOrderedSet)
    
    @objc(addLikes_relObject:)
    @NSManaged public func addToLikes_rel(_ value: LikesInfo)
    
    @objc(removeLikes_relObject:)
    @NSManaged public func removeFromLikes_rel(_ value: LikesInfo)
    
    @objc(addLikes_rel:)
    @NSManaged public func addToLikes_rel(_ values: NSOrderedSet)
    
    @objc(removeLikes_rel:)
    @NSManaged public func removeFromLikes_rel(_ values: NSOrderedSet)
    
    @objc(addTag_relObject:)
    @NSManaged public func addToTag_rel(_ value: Tag)
    
    @objc(removeTag_relObject:)
    @NSManaged public func removeFromTag_rel(_ value: Tag)
    
    @objc(addTag_rel:)
    @NSManaged public func addToTag_rel(_ values: NSOrderedSet)
    
    @objc(removeTag_rel:)
    @NSManaged public func removeFromTag_rel(_ values: NSOrderedSet)
}

extension Postinfo {
    
    func getPostData() -> Post {
        
        var mediaArray: [Media] = []
        var likesArray: [Likes] = []
        var captionTagsArray: [UserTag] = []
        
        let post = Post()
        post.caption = self.title ?? ""
        if let value = self.tem_post_type as? Int {
            post.tem_post_type = value
        } else {
            print("could not tem_post_type in core data")
        }
         
        post.id  = self.id ?? "0"
        
        if let likesCount = self.likesCount {
            post.likesCount = likesCount.toInt()
        }
        if let commentsCount = self.commentsCount {
            post.commentsCount = commentsCount.toInt()
        }
        if self.likedByMe {
            post.isLikeByMe = 1
        } else {
            post.isLikeByMe = 0
        }
        post.tempId = self.localId
        post.createdAt = self.dateTime
        
        //spot media information
        if let spotFiles = self.files_rel {
            
            for files in spotFiles {
                var mediaTagsArray: [UserTag] = []
                let filesObj = files as! FilesInfo
                let mediaObj = Media()
                mediaObj.postId = filesObj.postId
                if ((filesObj.type?.caseInsensitiveCompare("photo")) == .orderedSame) {
                    mediaObj.type = .photo
                    mediaObj.mimeType  = Constant.MimeType.image
                    mediaObj.ext = ".jpg"
                } else if ((filesObj.type?.caseInsensitiveCompare("video")) == .orderedSame) {
                    mediaObj.type = .video
                    mediaObj.mimeType  = Constant.MimeType.video
                    mediaObj.ext = ".mp4"
                }
                mediaObj.id = filesObj.id
                mediaObj.url = filesObj.firebaseurl
                mediaObj.previewImageUrl = filesObj.previewurl
                
                if let height = filesObj.height as? Double {
                    mediaObj.height = height
                }
                
                if let docUrl = DocumentManager.shared.getDocumentDirectory() {
                    DILog.print(items: "Path is \(docUrl)")
                    
                    if let url = filesObj.name {
                        let path = docUrl.appendingPathComponent(url)
                        do {
                            mediaObj.data  = try Data(contentsOf: path)
                            mediaObj.image = path.getVideoThumbnailAndDuaration(url: path)
                            mediaObj.duration = path.getDuration()
                        }
                        catch{
                        }
                    }
                }
                if let tagRel = filesObj.tag_rel {
                    for tag in tagRel {
                        let tagInfo = tag as! Tag
                        var tagObj = UserTag()
                        tagObj.id = tagInfo.id
                        tagObj.text = tagInfo.text
                        tagObj.firstName = tagInfo.firstName
                        tagObj.lastName = tagInfo.lastName
                        tagObj.profilePic = tagInfo.profilePic
                        if let pointX = tagInfo.pointX {
                            tagObj.centerX = CGFloat(exactly: pointX)
                        }
                        if let pointY = tagInfo.pointY {
                            tagObj.centerY = CGFloat(exactly: pointY)
                        }
                        mediaTagsArray.append(tagObj)
                    }
                }
                mediaObj.taggedPeople = mediaTagsArray
                print("media Tagged count: \(mediaTagsArray.count)")
                mediaArray.append(mediaObj)
            }
            post.media = mediaArray
        }
        
        if let likes = self.likes_rel {
            for like in likes {
                let likesInfo = like as! LikesInfo
                let likesObj = Likes()
                likesObj.id = likesInfo.id
                likesObj.profilePic = likesInfo.profilePic
                
                likesArray.append(likesObj)
            }
            post.likes = [Likes]()
            post.likes = likesArray
        }
        
        if let tags = self.tag_rel {
            for tag in tags {
                let tagInfo = tag as! Tag
                var tagObj = UserTag()
                tagObj.id = tagInfo.id
                tagObj.text = tagInfo.text
                captionTagsArray.append(tagObj)
            }
            post.captionTags = [UserTag]()
            post.captionTags = captionTagsArray
        }
        
        let address:Address = Address()
        address.city = self.address_rel?.city
        address.state = self.address_rel?.state
        address.country = self.address_rel?.country
        if let arrCoordinates = self.address_rel?.cordinates,
            arrCoordinates.count > 0 {
            address.lat = arrCoordinates.first
            address.lng = arrCoordinates.last
            post.coordinates = arrCoordinates
        }
        post.address = address
        
        //getting user information
        if let user = self.user_rel {
            let userInfo: Friends = Friends()
            userInfo.firstName = user.firstName
            userInfo.lastName = user.lastName
            userInfo.profilePic = user.profilePic
            userInfo.userName = user.userName
            userInfo.id = user.id
            post.user = userInfo
        }
        return post
        
    }
    
}
