//
//  AWSS3BucketManager.swift
//  TemApp
//
//  Created by Harpreet_kaur on 04/03/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit
//import AWSS3
//import AWSCore

class AWSBucketMangaer{
    
    // MARK: Variables.
    static let bucketInstance:AWSBucketMangaer = AWSBucketMangaer()
    //var transferManager: AWSS3TransferUtility?
    //let S3BucketName = "tem-files"
    
    func uploadFile(data: Data, mediaObj: Media, mimeType: String, key: String, fileName: String, completion: @escaping (_ apiResponse: APICallBacks, _ apiUrl: String?, _ error: DIError,_ media:Media) -> Void) {
        DIWebLayerUserAPI().getS3UrlForFileUpload(completion: { (credentials) in
            if let path = credentials.url {
                DIWebLayerUserAPI().uploadToS3Bucket(atPath: path, data: credentials, file: data, key: key, fileName: fileName, mimeType: mimeType, media: mediaObj, completion: { (fileUrl) in
                    print("file url: \\ ----> \(fileUrl)")
                    completion(.success, fileUrl, DIError.noResponse(), mediaObj)
                }, failure: { (error) in
                    completion(.failure, nil, error, mediaObj)
                })
            }
        }) { (error) in
            completion(.failure, nil, error, mediaObj)
        }
    }
    
    /// cancels all the transfer utility uploading tasks, if any.
    /*func cancelAllTasks() {
     let uploadedTasks = transferManager?.getUploadTasks().result
     guard let tasks = uploadedTasks,
     tasks.count != 0 else {
     return
     }
     for task in uploadedTasks! {
     if let uploadedTask = task as? AWSS3TransferUtilityUploadTask {
     uploadedTask.cancel()
     }
     }
     }
     */
}


