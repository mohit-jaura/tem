//
//  YPPhotoSaver.swift
//  YPImgePicker
//
//  Created by Sacha Durand Saint Omer on 10/11/16.
//  Copyright © 2016 Capovela LLC. All rights reserved.
//

import Foundation
import Photos

public class YPPhotoSaver {
    class func trySaveImage(_ image: UIImage, inAlbumNamed: String) {
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            if let album = album(named: inAlbumNamed) {
                saveImage(image, toAlbum: album)
            } else {
                createAlbum(withName: inAlbumNamed) {
                    if let album = album(named: inAlbumNamed) {
                        saveImage(image, toAlbum: album)
                    }
                }
            }
        }
    }
    
    private class func saveImage(_ image: UIImage, toAlbum album: PHAssetCollection) {
        PHPhotoLibrary.shared().performChanges({
            let changeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
            let enumeration: NSArray = [changeRequest.placeholderForCreatedAsset!]
            albumChangeRequest?.addAssets(enumeration)
        })
    }
    
    private class func createAlbum(withName name: String, completion:@escaping () -> Void) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
        }, completionHandler: { success, _ in
            if success {
                completion()
            }
        })
    }
    
    private class func album(named: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", named)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album,
                                                                 subtype: .any,
                                                                 options: fetchOptions)
        return collection.firstObject
    }
}
