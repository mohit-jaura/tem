//
//  OfflineSync.swift
//
//  Created by Dhiraj on 21/06/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

enum UploadStatus {
    case inprogress
    case paused
    case cancelled
}
protocol SpotUploadDelegate {
    func spotUploaded()
    func spotuploadFailed(error:DIError)
}


import UIKit
import Firebase

class OfflineSync: NSObject {
    static let shared = OfflineSync()
    //var spots:[Spot]?
    var media:[Media]?
    var status:UploadStatus = .paused
    var postCounter: Int = 0
    var mediaCounter:Int = 0
    var totalPosts:Int = 0
    //var loaderView:LoaderView?
    var uploadCounter = 1
    var totalSpotToUpload = 0
    //var spot = Spot()
    var post = Post()
    var spotUploadDelegate:SpotUploadDelegate?
    
    func savePostLocally(post: Post, success: () -> (), failure: @escaping (NSError) -> ()) {
        let key = Constant.CoreData.PostEntityKeys.isuploaded.rawValue
        let predicate  = NSPredicate(format: "\(key) == %d",0)
        let postInfoArr: [Postinfo] = CoreDataManager.shared.getEntityData(with: predicate, of: Constant.CoreData.postEntity) as! [Postinfo]
        if postInfoArr.count < 10 {
            let media = post.media
            var fileName = ""
            if let mediaArray = media,
                mediaArray.count > 0 {
                for i in 0...(mediaArray.count)-1 {
                    let media:Media = mediaArray[i]
                    guard let fileExtension = media.ext else { return }
                    fileName = "Media_" +  "\(i)" + "\(Utility.shared.currentTimeStamp())" + fileExtension
                    if let data = media.data {
                        let result =  DocumentManager.shared.saveDataToDocumentDirectory(fileData: data, fileName: fileName)
                        if !result {
                            DILog.print(items: "Unable to save")
                        } else {
                            //set name of teh media
                            let media = mediaArray[i]
                            media.name = fileName
                            post.media![i] = media
                        }
                    }
                }
            }
            
            //Save data to coredata
            var mediaSet:NSOrderedSet = NSOrderedSet()
            var mediaItems:[FilesInfo] = []
            let postinfo: Postinfo = CoreDataManager.shared.saveData(of: Constant.CoreData.postEntity, object: post) as! Postinfo
            if let postAddress = post.address {
                
                let address: PostAddress = PostAddress(context: appDelegate.persistentContainer.viewContext)
                address.postId = post.id
                address.saveDetailsInDB(object: postAddress)
                postinfo.address_rel = address
            }
            
            if let user = post.user {
                let userDetailEntity = UserDetail(context: appDelegate.persistentContainer.viewContext)
                userDetailEntity.postId = postinfo.id
                userDetailEntity.saveDetailsInDB(object: user)
                postinfo.user_rel = userDetailEntity
            }
            
            if let mediaArray = post.media,
                mediaArray.count > 0 {
                for media in mediaArray {
                    var mediaTagItems: [Tag] = []
                    if media.previewImageUrl == nil
                    {
                        media.postId = postinfo.id
                        let spotMedia:FilesInfo = CoreDataManager.shared.saveData(of: Constant.CoreData.FileEntity,object:media) as! FilesInfo
                        //mediaSet.adding(spotMedia)
                        
                        _ = media.taggedPeople?.map({ (userTag) -> UserTag in
                            let tagInfo: Tag = CoreDataManager.shared.saveData(of: Constant.CoreData.tagEntity,object:userTag) as! Tag
                            mediaTagItems.append(tagInfo)
                            return userTag
                        })
                        
                        spotMedia.tag_rel = NSSet(array: mediaTagItems)
                        mediaItems.append(spotMedia)
                    }
                }
            }
            mediaSet = NSOrderedSet(array: mediaItems)
            //spotInfo.address_rel = spotAddress
            postinfo.files_rel = mediaSet
            
            var captionTagsSet:NSOrderedSet = NSOrderedSet()
            var captionTagItems:[Tag] = []
            
            if let captionTags = post.captionTags,
                captionTags.count > 0 {
                for tag in captionTags {
                    var newTag = tag
                    newTag.postId = postinfo.id
                    let tagEntity: Tag = CoreDataManager.shared.saveData(of: Constant.CoreData.tagEntity, object: newTag) as! Tag
                    captionTagItems.append(tagEntity)
                }
            }
            captionTagsSet = NSOrderedSet(array: captionTagItems)
            postinfo.tag_rel = captionTagsSet
            //            postinfo.addToTag_rel(captionTagsSet)
            
            appDelegate.saveContext(succes: {
                success()
            })
            { (error) in
                failure(error)
            }
            DILog.print(items:"media set count is \(mediaSet.count)")
            //if Utility.shared.isInternetAvailable() {
            if Reachability.isConnectedToNetwork() {
                //processOfflinePosts()
                createCurrentPost() { (error) in
                    if let id = post.id {
                        self.deletePostFromDatabase(withId: id)
                    }
                    failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : ErrorMessage.Post.error]))
                }
            }
            //}
            
        } else {
            failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : ErrorMessage.Post.Offline.save]))
        }
    }
    
    func createCurrentPost(failure: @escaping (DIError) -> ()) {
        self.mediaCounter = 0
        DILog.print(items: "Processing Offline Posts")
        let key1 = Constant.CoreData.PostEntityKeys.isuploaded.rawValue
        let key2 = Constant.CoreData.PostEntityKeys.uploadingInProgress.rawValue
        let predicate  = NSPredicate(format: "\(key1) == %d",0)
        let predicate2 = NSPredicate(format: "\(key2) == %d",0)
        let predicateCompound = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        let tempSpots:[Postinfo] = CoreDataManager.shared.getEntityData(with: predicateCompound, of: Constant.CoreData.postEntity) as! [Postinfo]
        totalPosts = tempSpots.count
        print("@@@@@@@@@@@@ un-uploaded posts count: \(tempSpots.count)")
        if tempSpots.count > 0 {
            DILog.print(items: "Found Some Posts")
            status = .inprogress
            //Convert SpotInfo to Spot
            self.post = tempSpots[0].getPostData()
            NotificationCenter.default.post(name: .postUploadInProgress, object: self.post)
            let fileKey1 = Constant.CoreData.FileEntityKeys.isuploaded.rawValue
            let filePostIdKey = Constant.CoreData.FileEntityKeys.postId.rawValue
            let predicate1 = NSPredicate(format: "\(fileKey1) == %d",1)
            let predicate2 = NSPredicate(format: "\(filePostIdKey) == %@",post.id!)
            let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1,predicate2])
            let files:[FilesInfo] = CoreDataManager.shared.getEntityData(with: predicateCompound, of: Constant.CoreData.FileEntity) as! [FilesInfo]
            guard let media = post.media else {
                return
            }
            
//            if media.count <= 0 {
//                //if in any case media count of post is zero, return from function as the post cannot be uploaded without the media
//                return
//            }
            
            self.updateMediaUploadingProgressStatusFor(postId: post.id!)
            if files.count == media.count {
                if self.isPostMediaNotNil() {
                    DILog.print(items: "No Media Found But spot uploaded")
                    uploadPost(post: post, done: { (message) in
                    }) { (error) in
                        NotificationCenter.default.post(name: .postUploadingError, object: self.post)
                        failure(error)
                    }
                }
            }
            else if files.count < media.count {
                UploadMediaToFireBase() { (error) in
                    NotificationCenter.default.post(name: .postUploadingError, object: self.post)
                    failure(error)
                }
            }
        }
    }
    
    func processOfflinePosts() {
        self.mediaCounter = 0
        DILog.print(items: "Processing Offline Posts")
        let isUploadedKey = Constant.CoreData.PostEntityKeys.isuploaded.rawValue
        let predicate  = NSPredicate(format: "\(isUploadedKey) == %d",0)
        let tempSpots:[Postinfo] = CoreDataManager.shared.getEntityData(with: predicate, of: Constant.CoreData.postEntity) as! [Postinfo]
        totalPosts = tempSpots.count
        if tempSpots.count > 0 {
            DILog.print(items: "Found Some Posts")
            status = .inprogress
            //Convert SpotInfo to Spot
            self.post = tempSpots[0].getPostData()
            
            let fileUploadedKey = Constant.CoreData.FileEntityKeys.isuploaded.rawValue
            let postIdKey = Constant.CoreData.FileEntityKeys.postId.rawValue
            
            let predicate1 = NSPredicate(format: "\(fileUploadedKey) == %d",1)
            let predicate2 = NSPredicate(format: "\(postIdKey) == %@",post.id!)
            let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1,predicate2])
            let files:[FilesInfo] = CoreDataManager.shared.getEntityData(with: predicateCompound, of: Constant.CoreData.FileEntity) as! [FilesInfo]
            
            guard let media = post.media else {
                return
            }
            if media.count <= 0 {
                //if in any case media count of post is zero, return from function as the post cannot be uploaded without the media
                return
            }
            if let id = self.post.id {
                updateMediaUploadingProgressStatusFor(postId: id)
            }
            if (files.count == media.count) {
                if self.isPostMediaNotNil() {
                    DILog.print(items: "No Media Found But spot uploaded")
                    uploadPost(post: post, done: { (message) in
                    }) { (error) in
                        if let id = self.post.id {
                            self.deletePostFromDatabase(withId: id)
                        }
                        NotificationCenter.default.post(name: Notification.Name.postUploadingError, object: self.post)
                    }
                }
            }
            else if files.count < media.count {
                UploadMediaToFireBase() { (error) in
                    if let id = self.post.id {
                        self.deletePostFromDatabase(withId: id)
                    }
                    NotificationCenter.default.post(name: Notification.Name.postUploadingError, object: self.post)
                }
            }
        }
    }
    
    func somecallBack(succes:@escaping () -> (),failure:(String) -> ()){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            succes()
        }
        
    }
    
    func updateMediaUploadingProgressStatusFor(postId: String) {
        let predicate = NSPredicate(format: "\(Constant.CoreData.PostEntityKeys.id.rawValue) == %@",postId)
        let posts:[Postinfo] = CoreDataManager.shared.getEntityData(with: predicate, of: Constant.CoreData.postEntity) as! [Postinfo]
        if posts.count > 0 {
            guard let post = posts.first else { return }
            post.uploadingInProgress = true
        }
        appDelegate.saveContext(succes: {
        }) { (_) in
        }
    }
    
    /// function for uploading media to firebase asynchronously
    /*func UploadMediaToFireBase() {
     if let postMedia = post.media {
     for (index,data) in postMedia.enumerated() {
     print("media id: \(data.id)")
     var mediaId: String?
     let media: Media = data
     if media.url != nil && !(media.url?.isBlank)! {
     print("Uploaded")
     //this is not the last media item to upload
     if mediaCounter != post.media!.count - 1 {
     mediaCounter = mediaCounter + 1
     uploadCounter += uploadCounter
     continue
     }
     }else{
     guard let data = media.data else {
     print("media data not found")
     return
     }
     if let id = media.id {
     mediaId = id
     } else {
     /*if !spot.isEdit {
     return
     } */
     }
     guard let postId = post.id else { return }
     guard let mimeType = media.mimeType else { return }
     let filepath = "\(User.sharedInstance.id  ?? "UserID101")/" + "media\(media.id ?? "")\(index)" + Utility.shared.getFileNameWithDate()
     //print("media id before upload ********** \(media.id) path: \(filepath)")
     UploadMedia.shared.configureDataToUpload(type: .firebase,data: data, withName: filepath, mimeType: mimeType, mediaObj: media)
     UploadMedia.shared.uploadImage( success: { (url, mediaObj) in
     for (index,data) in postMedia.enumerated() {
     if data.id == mediaObj.id {
     data.url = url
     self.post.media?[index] = data
     if data.type == .video {
     self.uploadThumnbnail(post: self.post, index: index, mimeType: Constant.MimeType.image, mediaId: mediaId!)
     } else {
     self.uploadCounter = self.uploadCounter + 1
     self.mediaCounter = self.mediaCounter + 1
     data.previewImageUrl = url
     self.post.media?[index] = data
     //print("uploaded firebase url for media id: \(data.id) is \(url)")
     self.updateMediaStatus(id:data.id!,firebaseUrl: url, previewUrl: url)
     if self.mediaCounter < (self.post.media?.count ?? 0) {
     //repeat the upload to firebase process
     } else {
     
     //check if any of the media in the current post contains nil url
     if self.isPostMediaNotNil() {
     print("uploading the posts to server")
     //upload the post to server
     self.uploadCounter = 1
     self.mediaCounter = 0
     self.uploadPost(post: self.post, done: { (message) in
     //DILog.print(items: "upload post params: \(self.post.json)")
     //DILog.print(items: "Spot uploaded")
     }, failed: { (result) in
     //                                            self.spotUploadDelegate?.spotuploadFailed(error: result)
     //                                            Utility.shared.hideLoader()
     })
     }
     }
     }
     }
     }
     }) { (error) in
     
     }
     }
     }
     }
     } */
    
    /// function to upload media to firebase synchronously
    func UploadMediaToFireBase(failure: @escaping (DIError) -> ()) {
        
        if self.mediaCounter < post.media!.count {
            
            var mediaId:String?
            let media: Media = post.media![mediaCounter]
            //skip the media object if it is already has the firebase url
            if media.url != nil && !(media.url?.isBlank)! {
                if mediaCounter != post.media!.count - 1 {
                    mediaCounter = mediaCounter + 1
                    UploadMediaToFireBase(failure: failure)
                    return
                }
            }
            guard let data = media.data else { return }
            if let id = media.id {
                mediaId = id
            }
            //            else {
            //                return
            //            }
            //guard let postId = post.id else { return }
            //guard let mimeType = post.media![mediaCounter].mimeType else { return }
            //let postId = post.id
            let mimeType = post.media![mediaCounter].mimeType
            let filepath = "UserID101" + "media" + Utility.shared.getFileNameWithDate()
            // DILog.print(items:"media is \(media.type)")
            DispatchQueue.main.async {
                AWSBucketMangaer.bucketInstance.uploadFile(data: data, mediaObj: media, mimeType: mimeType ?? "", key: "file", fileName: filepath) { (callback, firebaseUrl, error, mediaObjFromFirebase) in
                    if let url = firebaseUrl {
                        
                        let mediaObj = self.post.media![self.mediaCounter]
                        mediaObj.url = url
                        if media.type == .video {
                            self.uploadThumnbnail(post: self.post, mimeType: Constant.MimeType.image, mediaId: mediaId!)
                        } else {
                            self.uploadCounter = self.uploadCounter + 1
                            mediaObj.previewImageUrl = url
                            self.mediaCounter  = self.mediaCounter + 1
                            if let mediaId = mediaId {
                                self.updateMediaStatus(id: mediaId,firebaseUrl: url, previewUrl: url)
                            }
                            DILog.print(items:"Media counter is \(self.mediaCounter)")
                            if self.mediaCounter < self.post.media!.count {
                                self.UploadMediaToFireBase(failure: failure)
                            } else {
                                if self.isPostMediaNotNil() {
                                    DILog.print(items: "All media uploaded")
                                    self.mediaCounter = 0
                                    self.uploadCounter = 1
                                    self.uploadPost(post: self.post, done: { (message) in
                                    }, failed: failure)
                                }
                            }
                        }
                    }
                    else {
                        DILog.print(items: "Error Occured \(error)")
                        failure(error)
                    }
                }
            }
            
            /* AWSBucketMangaer.bucketInstance.uploadImage(data: data, withName: filepath, mimeType: mimeType  ?? "", mediaObj: media, progress: { (progress) in
             }) { (callback, firebaseUrl, error, mediaObjFromFirebase) in
             if let url = firebaseUrl {
             
             let mediaObj = self.post.media![self.mediaCounter]
             mediaObj.url = url
             if media.type == .video {
             self.uploadThumnbnail(post: self.post, mimeType: Constant.MimeType.image, mediaId: mediaId!)
             } else {
             self.uploadCounter = self.uploadCounter + 1
             mediaObj.previewImageUrl = url
             self.mediaCounter  = self.mediaCounter + 1
             if let mediaId = mediaId {
             self.updateMediaStatus(id: mediaId,firebaseUrl: url, previewUrl: url)
             }
             DILog.print(items:"Media counter is \(self.mediaCounter)")
             if self.mediaCounter < self.post.media!.count {
             self.UploadMediaToFireBase()
             } else {
             if self.isPostMediaNotNil() {
             DILog.print(items: "All media uploaded")
             self.mediaCounter = 0
             self.uploadCounter = 1
             self.uploadPost(post: self.post, done: { (message) in
             }, failed: { (error) in
             
             })
             }
             }
             }
             }
             else {
             DILog.print(items: "Error Occured \(error)")
             // self.UploadMediaToFireBase()
             }
             } */
        }
    }
    
    func isPostMediaNotNil() -> Bool {
        //check if any of the media in the current post contains nil url
        let mediaFiles = self.post.media?.filter({ (media) -> Bool in
            return (media.url == nil || media.url == "")
        })
        
        //if all media contains url only then upload it to server
        if let media = mediaFiles,
            media.isEmpty {
            return true
        }
        return false
    }
    
    /* func uploadThumnbnail(post:Post,index:Int,mimeType:String,mediaId:String) {
     
     DILog.print(items:"media thumbnail ")
     let filePath = "\(User.sharedInstance.id  ?? "UserID101")/" + "media" + Utility.shared.getFileNameWithDate()
     guard var image:UIImage  = post.media?[index].image else {
     return
     }
     if let resizeImage = image.resizeImage(image: image, newHeight: 400) {
     image = resizeImage
     }
     guard let data  = image.jpegData(compressionQuality: 0.4) else {
     return
     }
     UploadMedia.shared.configureDataToUpload(type: .firebase,data: data, withName: filePath, mimeType: mimeType, mediaObj: post.media?[index] ?? Media())
     UploadMedia.shared.uploadImage(success: { (url, mediaObj) in
     let mediaObj = post.media?[index] ?? Media()
     mediaObj.previewImageUrl = url
     post.media?[index] = mediaObj
     self.updateMediaStatus(id: mediaId,firebaseUrl: mediaObj.url!, previewUrl: url)
     self.mediaCounter = self.mediaCounter + 1
     DILog.print(items:"media counter thumbnail is \(self.mediaCounter)")
     if self.mediaCounter < self.post.media!.count {
     self.uploadCounter = self.uploadCounter + 1
     } else {
     if self.isPostMediaNotNil() {
     self.mediaCounter = 0
     self.uploadPost(post: post, done: { (message) in
     
     }, failed: { (failure) in
     
     })
     }
     }
     }) { (error) in
     
     }
     
     } */
    
    func uploadThumnbnail(post: Post, mimeType: String, mediaId: String) {
        
        DILog.print(items:"media thumbnail ")
        let filePath = "UserID101" + "media" + Utility.shared.getFileNameWithDate()
        guard var image:UIImage  = post.media![self.mediaCounter].image else {
            return
        }
        if let resizeImage = image.resizeImage(image: image, newHeight: 400) {
            image = resizeImage
        }
        guard let data = image.jpegData(compressionQuality: 0.4) else {
            return
        }
        let media = post.media![self.mediaCounter]
        
        AWSBucketMangaer.bucketInstance.uploadFile(data: data, mediaObj: media, mimeType: mimeType, key: "file", fileName: filePath) { (callback, firebaseUrl, error, mediaObjFromFirebase) in
            if let url = firebaseUrl {
                let mediaObj = post.media![self.mediaCounter]
                mediaObj.previewImageUrl = url
                post.media![self.mediaCounter] = mediaObj
                self.updateMediaStatus(id: mediaId,firebaseUrl: mediaObj.url!, previewUrl: url)
            }
            
            self.mediaCounter = self.mediaCounter + 1
            if self.mediaCounter < self.post.media!.count {
                self.uploadCounter = self.uploadCounter + 1
                self.UploadMediaToFireBase() { (error) in
                    // do nothing ?
                }
            } else {
                if self.isPostMediaNotNil() {
                    self.mediaCounter = 0
                    self.uploadPost(post: post, done: { (_) in
                        
                    }, failed: { (_) in
                        // do nothing ?
                    })
                }
            }
        }
        
        /*AWSBucketMangaer.bucketInstance.uploadImage(data: data, withName: filePath, mimeType: mimeType, mediaObj: media, progress: { (progress) in
         
         
         }) { (callback, firebaseUrl, error, mediaObjFromFirebase) in
         if let url = firebaseUrl {
         let mediaObj = post.media![self.mediaCounter]
         mediaObj.previewImageUrl = url
         post.media![self.mediaCounter] = mediaObj
         self.updateMediaStatus(id: mediaId,firebaseUrl: mediaObj.url!, previewUrl: url)
         }
         
         self.mediaCounter = self.mediaCounter + 1
         if self.mediaCounter < self.post.media!.count {
         self.uploadCounter = self.uploadCounter + 1
         self.UploadMediaToFireBase()
         } else {
         if self.isPostMediaNotNil() {
         self.mediaCounter = 0
         self.uploadPost(post: post, done: { (message) in
         
         }, failed: { (error) in
         
         })
         }
         }
         } */
    }
    
    
    func updateMediaStatus(id:String,firebaseUrl:String,previewUrl:String) {
        let idKey = Constant.CoreData.FileEntityKeys.id.rawValue
        let predicate = NSPredicate(format: "\(idKey) == %@",id)
        let files:[FilesInfo] = CoreDataManager.shared.getEntityData(with: predicate, of: Constant.CoreData.FileEntity) as! [FilesInfo]
        if files.count > 0 {
            guard let file = files.first else { return }
            file.isuploaded = true
            file.firebaseurl = firebaseUrl
            file.previewurl = previewUrl
            
            //delete from document directory
            if let fileName = file.name {
                DocumentManager.shared.deleteFromDocumentDirectory(atPath: fileName)
            }
        }
        appDelegate.saveContext(succes: {
        }) { (_) in
        }
    }
    
    func updatePostStatus(id:String) {
        let idKey = Constant.CoreData.PostEntityKeys.id.rawValue
        let predicate  = NSPredicate(format: "\(idKey) == %@",id)
        let posts:[Postinfo] = CoreDataManager.shared.getEntityData(with: predicate, of:Constant.CoreData.postEntity) as! [Postinfo]
        if posts.count > 0 {
            guard let post = posts.first else { return }
            post.isuploaded = true
        }
        appDelegate.saveContext(succes: {
            
        }) { (_) in
            
        }
    }
    
    func deletePostFromDatabase(withId id: String) {
        DILog.print(items: "Deleting post with ID----------: \(id)")
        let idKey = Constant.CoreData.PostEntityKeys.id.rawValue
        let predicate  = NSPredicate(format: "\(idKey) == %@",id)
        CoreDataManager.shared.delete(entityName: Constant.CoreData.postEntity, fromContext: appDelegate.persistentContainer.viewContext, predicate: predicate)
    }
    
    func uploadPost(post: Post,done: @escaping (_ message: String) -> (), failed: @escaping (DIError) -> ()) {
        guard UserManager.isUserLoggedIn() else {
            return
        }
        PostManager.shared.publish(post: post, success: { (message, updatedPost) in
            //updatedPost will contain the post object with the post id from server
            //if let id  = post.id {
            if let id = post.id {
                self.deletePostFromDatabase(withId: id)
            }
            
                AlertBar.show(.success, message: AppMessages.Post.publishOnline)
                self.postCounter = +1
                self.mediaCounter = 0
                if self.postCounter < self.totalPosts {
                    self.processOfflinePosts()
                } else {
                    self.status = .paused
                }
                //sending the notification with the updatedPost object
                NotificationCenter.default.post(name: Notification.Name.postUploaded, object: updatedPost)
            NotificationCenter.default.post(name: Notification.Name.goalAsPostUpload, object: updatedPost)
                DispatchQueue.main.async {
                    done(message)
                    
                }
           // }

        }) { (failure) in
            /*DispatchQueue.main.asyncAfter(deadline: .now() + 2.1, execute: {
             AlertBar.show(.error, message: failure.message ?? ErrorMessage.Unknown.message)
             }) */
            print("error in uploading post: \(String(describing: failure.message))")
            self.status = .cancelled
            //self.processOfflinePosts()
            NotificationCenter.default.post(name: Notification.Name.goalAsPostUpload, object: post)
            AlertBar.show(.success, message: failure.message ?? "Error in uploading your post due to some error. Please try again.")
            failed(failure)
        }
    }
    
    func updatePost(post:Post,postInfo:Postinfo) -> Bool {
        
        var status:Bool = false
        var mediaItems:[FilesInfo] = []
        var mediaSet:NSOrderedSet = NSOrderedSet()
        if let title = post.caption {
            postInfo.title = title
        }
        
        if let value = post.tem_post_type as NSNumber?{
            postInfo.tem_post_type = value
        }
        if let _ = post.media {
            if (post.media!.count) > 0 {
                var index:Int = 0
                for media in post.media! {
                    if media.previewImageUrl == nil {
                        media.postId = postInfo.id
                        guard let fileExtension = media.ext else { return false}
                        if let data  = media.data {
                            let fileName = "Media_" +  "\(index)" + "\(Utility.shared.currentTimeStamp())" + fileExtension
                            let result =  DocumentManager.shared.saveDataToDocumentDirectory(fileData: data, fileName: fileName)
                            if result {
                                media.name = fileName
                            }
                        }
                    }
                    let postMedia:FilesInfo = CoreDataManager.shared.saveData(of: Constant.CoreData.FileEntity,object:media) as! FilesInfo
                    mediaItems.append(postMedia)
                    index = +1
                }
            }
        }
        mediaSet = NSOrderedSet(array: mediaItems)
        postInfo.files_rel = mediaSet
        appDelegate.saveContext(succes: {
            status = true
        }) { (_) in
        }
        return status
    }
    
    func deleteFirebaseURL(firebaseUrl:String) {
        //        let imageRef = Storage.storage().reference(forURL: firebaseUrl)
        //        imageRef.delete { (error) in
        //            if error != nil {
        //                DILog.print(items: "Error Occured while deleting \(error.debugDescription)")
        //            }
        //            DILog.print(items: "URL delete Successfully")
        //        }
    }
    
    func removeMediaFromFirebase(url:String) {
        
        DILog.print(items:"URL IS \(url)")
        //        let imageRef = Storage.storage().reference(forURL: url)
        //        imageRef.delete { (error) in
        //            if error != nil {
        //                DILog.print(items: "Unable to delete \(error.debugDescription)")
        //            }
        //        }
        
    }
}


