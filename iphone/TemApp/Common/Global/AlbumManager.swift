//
//  AlbumManager.swift
//
//  Created by Aj Mehra on 05/08/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import Foundation
import Photos

class AlbumManager: NSObject {
	static let albumName = "Spottales"
	static let shared = AlbumManager()
	
	private var assetCollection: PHAssetCollection!
	
	private override init() {
		super.init()
		
		if let assetCollection = fetchAssetCollectionForAlbum() {
			self.assetCollection = assetCollection
			return
		}
	}
	
	private func checkAuthorizationWithHandler(completion: @escaping ((_ success: Bool) -> Void)) {
		if PHPhotoLibrary.authorizationStatus() == .notDetermined {
			PHPhotoLibrary.requestAuthorization({ (_) in
				self.checkAuthorizationWithHandler(completion: completion)
			})
		}
		else if PHPhotoLibrary.authorizationStatus() == .authorized {
			self.createAlbumIfNeeded()
			completion(true)
		}
		else {
			completion(false)
		}
	}
	
	private func createAlbumIfNeeded() {
		if let assetCollection = fetchAssetCollectionForAlbum() {
			// Album already exists
			self.assetCollection = assetCollection
		} else {
			PHPhotoLibrary.shared().performChanges({
				PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: AlbumManager.albumName)   // create an asset collection with the album name
			}) { success, _ in
				if success {
					self.assetCollection = self.fetchAssetCollectionForAlbum()
				} else {
					// Unable to create album
				}
			}
		}
	}
	
	private func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
		let fetchOptions = PHFetchOptions()
		fetchOptions.predicate = NSPredicate(format: "title = %@", AlbumManager.albumName)
		let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
		
		if let _: AnyObject = collection.firstObject {
			return collection.firstObject
		}
		return nil
	}
	
	func save(image: UIImage) {
		self.checkAuthorizationWithHandler { (success) in
			if success, self.assetCollection != nil {
				PHPhotoLibrary.shared().performChanges({
					let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
					let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
					let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
					let enumeration: NSArray = [assetPlaceHolder!]
					albumChangeRequest!.addAssets(enumeration)
					
				}, completionHandler: nil)
			}
		}
	}
	func saveVideo(url:URL) -> Void {
		self.checkAuthorizationWithHandler { (success) in
			if success, self.assetCollection != nil {
				PHPhotoLibrary.shared().performChanges({
					let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
					let assetPlaceHolder = assetChangeRequest?.placeholderForCreatedAsset
					let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
					let enumeration: NSArray = [assetPlaceHolder!]
					albumChangeRequest!.addAssets(enumeration)
					
				}, completionHandler: nil)
			}
		}
//		let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0];
//		let filePath="\(documentsPath)/tempFile.mp4";
//		dispatch_async(dispatch_get_main_queue(), {
//			urlData?.writeToFile(filePath, atomically: true);
//			PHPhotoLibrary.sharedPhotoLibrary().performChanges({
//				PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(NSURL(fileURLWithPath: filePath))
//			}) { completed, error in
//				if completed {
//					print("Video is saved!")
//				}
//			}
//		})
	}
}
