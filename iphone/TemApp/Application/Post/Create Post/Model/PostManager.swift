//
//  PostManager.swift
//  TemApp
//
//  Created by shilpa on 15/02/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
class PostManager: DIWebLayer {
    
    static let shared = PostManager()
    
    /// create post api call
    ///
    /// - Parameters:
    ///   - post: post object
    ///   - success: success block with message and the post object
    ///   - failure: error block
    func publish(post: Post, success: @escaping (_ message: String, _ post: Post) -> (), failure: @escaping Failure) -> Void {
        self.call(method: .post, function: "posts", parameters: post.json, success: { (response) in
            if let status = response["status"] as? Int, status == 1, let message = response["message"] as? String {
                print(response)
                print("post created successfully")
                if let postId = response["post_id"] as? String {
                    let updatedPost = post.copy() as! Post
                    updatedPost.id = postId
                    success(message, updatedPost)
                } else {
                    success(message, post)
                }
            } else {
                failure(DIError.unKnowError())
            }
        }) { (error) in
            print("error in uploading spot \(error)")
            failure(error)
        }
    }
    
    /// get the news feeds for the user
    ///
    /// - Parameters:
    ///   - page: Page number for which the feeds are to be fetched
    ///   - completion: the list of feeds on success
    ///   - failure: error block
    func getFeeds(atPage page: Int, completion: @escaping (_ feeds: [Post]) -> (), failure: @escaping Failure) {
        let function = "posts/\(page)"
        self.call(method: .get, function: function, parameters: nil, success: { (response) in
            //DILog.print(items: "get feeds response: \(response)")
            if let data = response["data"] as? [Parameters] {
                self.decodeFrom(data: data, success: { (posts) in
                    completion(posts)
                }, failure: { (error) in
                    DILog.print(items: "error in decoding: \(error)")
                    failure(error)
                })
            }
        }, failure: { (error) in
            DILog.print(items: "error in api response: \(error)")
            failure(error)
        })
    }
    
    
    func saveWaterTracker(params: Parameters, completion: @escaping OnlySuccess, failure: @escaping Failure) {
        self.call(method: .post, function: Constant.SubDomain.saveWaterTrack, parameters: params) { responseValue in
                if let status = responseValue["status"] as? Int, status == 0 {
                    let error = DIError(message: responseValue["message"] as? String)
                    failure(error)
                } else {
                    completion()
                }
        } failure: { error in
            failure(error)
        }
    }

    func getFoodTrek(userId:String = "", isOtherUser:Bool = false, type:Int = 1, completion: @escaping (_ feeds: [FoodTrekModel],_ on_treak:String,_ streak:Int, _ waterTrackingCount: Int) -> (), failure: @escaping Failure) {
        let date = Date()
        let startDate = date.startOfDay.locaToUTCString(inFormat: .preDefined)
        let endDate = date.endOfDay.locaToUTCString(inFormat: .preDefined)
        let function = isOtherUser ? "food-trek/otherfrienddatalist?user_id=\(userId)&type=\(type)&startDate=\(startDate)&endDate=\(endDate)" : "food-trek/list?type=\(type)&startDate=\(startDate)&endDate=\(endDate)"
        
        
        self.call(method: .get, function: function, parameters: nil, success: { (response) in
            //DILog.print(items: "get feeds response: \(response)")
            let streak = response["streak"] as? Int ?? 0
            let waterTrackCount = response["waterintake"] as? Int ?? 0
            let on_treak = response["on_treak"] as? String ?? "0"
//            let selectedTrek = Double(on_treak)
            if let data = response["data"] as? [Parameters] {
                self.decodeFrom(data: data, success: { (foodTrekModel) in
                    completion(foodTrekModel,on_treak,Int(streak), waterTrackCount)
                }, failure: { (error) in
                    DILog.print(items: "error in decoding: \(error)")
                    failure(error)
                })
            }
        }, failure: { (error) in
            DILog.print(items: "error in api response: \(error)")
            failure(error)
        })
    }
    
    func getFoodTrekDetail(id: String, completion: @escaping (FoodTrekModel) -> Void, failure: @escaping Failure) {
        let url = "food-trek/trek-details/\(id)"
        self.call(method: .get, function: url, parameters: nil, success: { (response) in
            if let data = response["data"] as? [Parameters] {
                self.decodeFrom(data: data[0], success: { foodTrek in
                    completion(foodTrek)
                }, failure: { (error) in
                    DILog.print(items: "error in decoding: \(error)")
                    failure(error)
                })
            }
        }, failure: { (error) in
            DILog.print(items: "error in api response: \(error)")
            failure(error)
        })
    }
    func getTrekTime(timeStamp:Int) -> Date {
        let sDate = String(describing: timeStamp)
        var date = Date()
        if sDate.count == 10 {
            date = timeStamp.toDate
        }
        else if sDate.count == 13 {
            date = timeStamp.timestampInMillisecondsToDate
        }
        return date
    }
    
    func getFoodTrekHistory(date:Int,isOtherUser:Bool = false,userId:String = "",completion: @escaping (_ feeds: [FoodTrekModel], _ waterCount: Int) -> (), failure: @escaping Failure) {
        let startDate = getTrekTime(timeStamp: date).startOfDay.locaToUTCString(inFormat: .preDefined)
        let endDate = getTrekTime(timeStamp: date).endOfDay.locaToUTCString(inFormat: .preDefined)
        let function = isOtherUser ? "food-trek/otherfrienddetail?date=\(date)&user_id=\(userId)&startDate=\(startDate)&endDate=\(endDate)" : "food-trek/detail?date=\(date)&startDate=\(startDate)&endDate=\(endDate)"
        //        let function = "food-trek/detail?date=\(date)"
        self.call(method: .get, function: function, parameters: nil, success: { (response) in
            //DILog.print(items: "get feeds response: \(response)")
            if let data = response["data"] as? [Parameters] {
                self.decodeFrom(data: data, success: { (foodTrekModel) in
                    let waterTrackCount = response["waterintake"] as? Int ?? 0
                    completion(foodTrekModel, waterTrackCount)
                }, failure: { (error) in
                    DILog.print(items: "error in decoding: \(error)")
                    failure(error)
                })
            }
        }, failure: { (error) in
            DILog.print(items: "error in api response: \(error)")
            failure(error)
        })
    }
    
    /// delete post server call
    ///
    /// - Parameters:
    ///   - parameters: parameters for delete post
    ///   - success: success block
    ///   - failure: error block
    func deletepost(parameters: Parameters?,success: @escaping (_ message: String) -> (), failure: @escaping (_ error: DIError) -> ()){
        
        self.call(method:.delete,function: Constant.SubDomain.deletePost, parameters: parameters, success: { response in
            if let status = response["status"] as? Int , status == 1 {
                if let message = response["message"] as? String {
                    success(message)
                    return
                }
            }
        }) {
            failure($0)
        }
    }
    
    /// report post api call
    ///
    /// - Parameters:
    ///   - parameters: parameters of report post
    ///   - success: success block
    ///   - failure: error block
    func reportPost(parameters: Parameters?,success: @escaping (_ message: String) -> (), failure: @escaping (_ error: DIError) -> ()){
        
        self.call(method:.put,function: Constant.SubDomain.reportPost, parameters: parameters, success: { response in
            if let status = response["status"] as? Int , status == 1 {
                if let message = response["message"] as? String {
                    success(message)
                    return
                }
            }
        }) {
            failure($0)
        }
    }
    
    /// Api call to get the post details
    ///
    /// - Parameters:
    ///   - postId: post id
    ///   - success: success block
    ///   - failure: error block
    func getPostDetailsWith(postId: String, success: @escaping (_ post: Post) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        let url = Constant.SubDomain.getPostDetails + "?post_id=\(postId)"
        self.call(method: .get, function: url, parameters: nil, success: { (response) in
            if let data = response["data"] as? Parameters {
                self.decodeFrom(data: data, success: { (post) in
                    success(post)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func getFoodTrekPostDetailsWith(postId: String, success: @escaping (_ post: Post) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        let url = Constant.SubDomain.getFoodTrekPostDetail + "?post_id=\(postId)"
        self.call(method: .get, function: url, parameters: nil, success: { (response) in
            if let data = response["data"] as? Parameters {
                self.decodeFrom(data: data, success: { (post) in
                    success(post)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    /// Api call to get the report post reasons
    ///
    /// - Parameters:
    ///   - success: success block
    ///   - failure: error block
    func getReportHeadings(success: @escaping (_ data: [ReportData]) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        self.call(method:.get,function: Constant.SubDomain.reportCategories, parameters: nil, success: { response in
            if let data = response["data"] as? [Parameters] {
                self.decodeFrom(data: data, success: { (reports: [ReportData]) in
                    success(reports)
                    return
                }, failure: { (error) in
                    DILog.print(items: "error in decoding: \(error)")
                    failure(error)
                })
            }
        }) {
            failure($0)
        }
    }
}
