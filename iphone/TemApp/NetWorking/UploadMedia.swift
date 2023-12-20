//
//  UploadMedia.swift
//  TemApp
//
//  Created by Harpreet_kaur on 04/03/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit

enum uploadType {
    case firebase
    case awsBucket
}

protocol uploadMediaProtocol {
    func uploadImage(success: @escaping (_ url: String ,_ media:Media) -> (), failure: @escaping (_ error: DIError) -> ())
    func downloadImage()
}

class UploadMedia: uploadMediaProtocol {
    
    // MARK: Variables
    static let shared = UploadMedia()
    static var uploadMediaDelegate:uploadMediaProtocol?
    private var uploadType:uploadType = .firebase
    private var uploadData:Data?
    private var quality:CGFloat = 1.0
    private var imageName:String?
    private var imageMimeType:String?
    private var mediaData:Media?
    private let keyName: String = "file"
    
    
    func configureDataToUpload(type:uploadType = .firebase, data: Data, withQuality value: CGFloat = 1.0, withName: String,mimeType:String, mediaObj:Media) { //,success: @escaping (String, Media) -> (), failure: @escaping (DIError) -> ()) {
        uploadType = type
        uploadData = data
        quality = value
        imageName = withName
        imageMimeType = mimeType
        mediaData = mediaObj
        //        uploadImage(success: { (url, media) in
        //            success(url,media)
        //        }) { (error) in
        //            failure(error)
        //        }
    }
    
    func uploadImage(success: @escaping (String, Media) -> (), failure: @escaping (DIError) -> ()) {
        switch uploadType {
        case .firebase:
            DIFirebaseImageManager.firebaseInstance.uploadImage1(data: uploadData ?? Data(), withQuality : quality, mediaObj: mediaData ?? Media(), withName: imageName ?? "", mimeType:imageMimeType ?? "" , progress: { (progress) in
            }) { (callback, url, error, media) in
                if let firebaseUrl = url {
                    success(firebaseUrl,media)
                }else{
                    failure(error)
                }
            }
        case .awsBucket:
            AWSBucketMangaer.bucketInstance.uploadFile(data: uploadData ?? Data(), mediaObj: mediaData ?? Media(), mimeType: imageMimeType ?? "", key: keyName, fileName: imageName ?? "") { (callback, url, error, media) in
                if let url = url {
                    success(url, media)
                } else {
                    failure(error)
                }
            }
        }
    }
    
    func downloadImage() {
        switch uploadType {
        case .firebase:
            break
        case .awsBucket:
            break
            
        }
    }
    
    
}

