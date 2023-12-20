//
//  FeedsDataProvider.swift
//  TemApp
//
//  Created by shilpa on 26/02/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import CoreData

class FeedsDataProvider {
    
    /// this function saves the data to the core data base
    ///
    /// - Parameter posts: array of posts from server to be saved to core data
    func savePostsOffline(posts: [Post]) {
        
        let key = Constant.CoreData.PostEntityKeys.isuploaded.rawValue
        let fetchPredicate = NSPredicate(format: "\(key) == %d",CustomBool.yes.rawValue)
        CoreDataManager.shared.delete(entityName: Constant.CoreData.postEntity, fromContext: appDelegate.persistentContainer.viewContext, predicate: fetchPredicate)
        
        // creates a private managed object context
        let newTaskContext = appDelegate.persistentContainer.newBackgroundContext()
        
        // Perform tasks in a background queue
        newTaskContext.perform {
            
            //first delete the already saved posts and then insert new
          
            for (_, post) in posts.enumerated() {
                let postInfo = CoreDataManager.shared.saveDataInContext(viewContext: newTaskContext, entity: Constant.CoreData.postEntity, object: post) as! Postinfo
                postInfo.isuploaded = true
                if let postAddress = post.address {
                    
                    let address: PostAddress = PostAddress(context: newTaskContext)
                    address.postId = post.id
                    address.saveDetailsInDB(object: postAddress)
                    postInfo.address_rel = address
                }
                if let userInfo = post.user {
                    let userDetail: UserDetail = UserDetail(context: newTaskContext)
                    userDetail.postId = post.id
                    userDetail.saveDetailsInDB(object: userInfo)
                    postInfo.user_rel = userDetail
                }
                if let postLikes = post.likes {
                    var likesInfo: [LikesInfo] = []
                    for like in postLikes {
                        like.id = post.id
                        let postLikesInfo: LikesInfo = LikesInfo(context: newTaskContext)
                        postLikesInfo.saveDetailsInDB(object: like)
                        likesInfo.append(postLikesInfo)
                    }
                    let likesInfoOrderedSet = NSOrderedSet(array: likesInfo)
                    postInfo.addToLikes_rel(likesInfoOrderedSet)
                }
                if let postMedia = post.media {
                    var mediaItems: [FilesInfo] = []
                    for media in postMedia {
                        media.postId = post.id
                        let filesInfo: FilesInfo = FilesInfo(context: newTaskContext)
                        filesInfo.saveDetailsInDB(object: media)
                        mediaItems.append(filesInfo)
                    }
                    let mediaSet = NSOrderedSet(array: mediaItems)
                    postInfo.addToFiles_rel(mediaSet)
                }
            }
            //save any of the unsaved changes in the newTaskContext
            CoreDataManager.saveContext(viewContext: newTaskContext)
        }
    }
    
    
    /// Call this function to get the data from core database
    ///
    /// - Parameters:
    ///   - completion: the core data entity converted into the local model
    ///   - failure: error in case, the data could not be fetched
    func getOfflineSavedPosts(completion: (_ posts: [Post]) -> (), failure: (_ error: Error) -> Void) {
        let key = Constant.CoreData.PostEntityKeys.isuploaded.rawValue
        let predicate = NSPredicate(format: "\(key) == %d", CustomBool.yes.rawValue)
        CoreDataManager.getOfflineSavedData(entityName: Constant.CoreData.postEntity, predicate: predicate, completion: { (result) in
            if let result = result as? [Postinfo] {
                var posts = [Post]()
                for postInfo in result {
                    let post = postInfo.getPostData()
                    posts.append(post)
                }
                completion(posts)
            }
        }, failure: {(error) in
            failure(error)
        })
    }
    
    
    /// get the posts which are not yet uploaded to server
    ///
    /// - Parameters:
    ///   - completion: the array of posts, on success
    ///   - failure: error, in case of data could not be fetched
    func getInProgressUploadingPosts(completion: (_ posts: [Post]) -> (), failure: (_ error: Error) -> Void) {
        let key = Constant.CoreData.PostEntityKeys.uploadingInProgress.rawValue
        let predicate = NSPredicate(format: "\(key) == %d", CustomBool.yes.rawValue)
        CoreDataManager.getOfflineSavedData(entityName: Constant.CoreData.postEntity, predicate: predicate, completion: { (result) in
            if let result = result as? [Postinfo] {
                var posts = [Post]()
                for postInfo in result {
                    let post = postInfo.getPostData()
                    if let media = post.media,
                        media.isEmpty {
                        continue
                    }
                    posts.append(post)
                }
                completion(posts)
            }
        }) { (error) in
            failure(error)
        }
    }
    
    
    /// update likes corresponding to post in core data
    ///
    /// - Parameters:
    ///   - postId: id of post whose likes are to be updated
    ///   - isLikeByMe: like status
    ///   - likesCount: likes count
    func updateLikesInPostInDatabaseWith(postId: String?, isLikeByMe: Int?, likesCount: Int?) {
        guard let postId = postId else {
            return
        }
        let postIdKey = Constant.CoreData.PostEntityKeys.id.rawValue
        let fetchPredicate = NSPredicate(format: "\(postIdKey) == %@",postId)
        let posts:[Postinfo] = CoreDataManager.shared.getEntityData(with: fetchPredicate, of: Constant.CoreData.postEntity) as! [Postinfo]
        if let post = posts.first {
            var likedByMe = false
            var newLikesCount: String?
            if let isLikeByMe = isLikeByMe {
                likedByMe = isLikeByMe == 1 ? true : false
            }
            
            if let likesCount = likesCount {
                newLikesCount = "\(likesCount)"
            }
            
            post.setValue(likedByMe, forKey: Constant.CoreData.PostEntityKeys.likedByMe.rawValue)
            post.setValue(newLikesCount, forKey: Constant.CoreData.PostEntityKeys.likesCount.rawValue)
            appDelegate.saveContext(succes: {
            }) { (error) in
                print("unable to update the likes in post \(error.localizedDescription)")
            }
        }
    }
}
