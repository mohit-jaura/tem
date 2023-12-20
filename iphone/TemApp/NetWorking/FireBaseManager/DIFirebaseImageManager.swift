
//
//  DIFirebaseImageManager.swift
//  Sparks
//
//  Created by narinder on 10/01/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

var userData = "userData"

import UIKit
import Foundation
import FirebaseStorage
import FirebaseAuth

typealias FirImageUploaderCallback = ((NSMutableDictionary?) -> Void)
typealias FirImageDeleteCallback = ((Bool?) -> Void)
typealias isSavedLocally = ((Bool?) -> Void)


@objc protocol FIRImageManagerDeletgate {
  func didDeleteImage(success:Bool, atIndex:Int)
  func didSavedlocally(sucess:Bool)
}

protocol DIFirebaseImageManagerDelegate {
  func uploadImage(data: Data, withQuality value: CGFloat , withName: String,mimeType:String, progress : @escaping (String) -> (),completion: @escaping (_ apiResponse: APICallBacks, _ apiUrl: String?, _ error: DIError) -> ())
}
@objc class DIFirebaseImageManager: NSObject,DIFirebaseImageManagerDelegate{
    func uploadImage(data: Data, withQuality value: CGFloat, withName: String, mimeType: String, progress: @escaping (String) -> (), completion: @escaping (APICallBacks, String?, DIError) -> ()) {
        
    }
    
  
  
  var storageRef: StorageReference!
  internal var callback: FirImageUploaderCallback!
  internal var deleteImagecallback: FirImageDeleteCallback!
  static let firebaseInstance:DIFirebaseImageManager = DIFirebaseImageManager()
  
  var DIFIRdelegate: FIRImageManagerDeletgate?
    
    var allTasks: [StorageUploadTask] = []
  
  
  override init() {
    storageRef = Storage.storage().reference()
  }
  
    //cancel all inprogess upload tasks
    func cancelAllTasks() {
        for task in allTasks {
            task.cancel()
        }
    }
  
//    func uploadImageUsingAWS_S3() {
//        let ext = "jpg"
//        let imageURL = Bundle.main.url(forResource: "imagename", withExtension: ext)
//        print("imageURL:\(imageURL)")
//        
//        let uploadRequest = AWSS3TransferManagerUploadRequest()
//        uploadRequest.body = imageURL
//        uploadRequest.key = "\(NSProcessInfo.processInfo().globallyUniqueString).\(ext)"
//        uploadRequest.bucket = S3BucketName
//        uploadRequest.contentType = "image/\(ext)"
//        
//        
//        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
//        transferManager.upload(uploadRequest).continueWithBlock { (task) -> AnyObject! in
//            if let error = task.error {
//                print("Upload failed ❌ (\(error))")
//            }
//            if let exception = task.exception {
//                print("Upload failed ❌ (\(exception))")
//            }
//            if task.result != nil {
//                let s3URL = NSURL(string: "http://s3.amazonaws.com/\(self.S3BucketName)/\(uploadRequest.key!)")!
//                print("Uploaded to:\n\(s3URL)")
//            }
//            else {
//                print("Unexpected empty result.")
//            }
//            return nil
//        }
//    }
  
  
  // MARK: Custom Functions
  func startDownloading(downloadUrl:String, imageName name:String)  {
    
    //    let destination: DownloadRequest.DownloadFileDestination = { _, _ in
    //
    //      let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    //      let fileURL = documentsURL.appendingPathComponent(name + ".png")
    //      return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
    //    }
    
    //    Alamofire.download(downloadUrl, to: destination).downloadProgress(closure: { (progress) in
    //
    //    }).response { response in
    //
    //      if response.error == nil, let LocalimagePath = response.destinationURL?.path {
    //
    //       DILog.print(items: LocalimagePath)
    //
    //        let imageObject = NSMutableDictionary()
    //        imageObject.setValue(downloadUrl, forKey: "FIRimageUrl")
    //        imageObject.setValue(LocalimagePath, forKey: "localImagePath")
    //        imageObject.setValue(name, forKey: "FIRimageName")
    //
    //        self.callback(imageObject)
    //
    //      }else{
    //       DILog.print(items: response.error!)
    //      }
    //    }
  }
  
  
  func removeFromServer(imageName name:String, atIndex:Int?,  completion : @escaping(Bool) -> ()) {
    
   // let imageName = name + ".png"
    //self.deleteImagecallback = reomverCallback
    
    // Create a reference to the file to delete
    let desertRef = storageRef.child(name)
    
    // Delete the file
    desertRef.delete { error in
      
      if let error = error {
        // Uh-oh, an error occurred!
       DILog.print(items: error.localizedDescription)
        // self.deleteImagecallback(false)
        if (error.localizedDescription .contains("does not exist"))
        {
         // self.deletFromDirectory(imageName: imageName, atIndex: atIndex)
        }else
        {
         // self.DIFIRdelegate?.didDeleteImage(success: false, atIndex: atIndex)
          
        }
        
        completion(false)

      } else {
        // File deleted successfully
       DILog.print(items: "image deleted successfully")
        completion(true)
       //self.deletFromDirectory(imageName: imageName, atIndex: atIndex)
      }
    }
  }
  
  
  func deletFromDirectory(imageName: String, atIndex:Int ) {
    let imagePath = ""
    //    if let userID = (UserDefaults.standard.value(forKey: Constants.userdefaultKeys.userData) as? NSDictionary)?.value(forKey: "_id") as? String {
    //       DILog.print(items: userID)
    //        imagePath = userID
    //    }
    
    let fileManager = FileManager.default
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = documentsURL.appendingPathComponent(imagePath)
   DILog.print(items: fileURL.path)
    do {
      let filePaths = try fileManager.contentsOfDirectory(atPath: fileURL.path)
     DILog.print(items: filePaths)
      
      if filePaths.count == 0 {
        //if no image found in local directory just send a tag 101 in controller to remove all saved urls from _photoArray and reload collection.
        self.DIFIRdelegate?.didDeleteImage(success: false, atIndex: 101)
      }
      
      for filePath in filePaths {
        if imageName.contains(filePath)
        {
          try fileManager.removeItem(atPath: documentsURL.appendingPathComponent(imageName).path)
          // fire delegation with sucess bool
          self.DIFIRdelegate?.didDeleteImage(success: true, atIndex: atIndex)
        }
      }
    } catch let error as NSError {
     DILog.print(items: "Could not clear temp folder: \(error.debugDescription)")
      self.DIFIRdelegate?.didDeleteImage(success: false, atIndex: atIndex)
    }
  }
  
  
  func deletFromDirectory() {
    
    var imagePath = ""
    if let userID = (UserDefaults.standard.value(forKey: userData) as? NSDictionary)?.value(forKey: "_id") as? String {
     DILog.print(items: userID)
      imagePath = userID
    }
    
    let fileManager = FileManager.default
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = documentsURL.appendingPathComponent(imagePath)
   DILog.print(items: fileURL.path)
    do {
      let filePaths = try fileManager.contentsOfDirectory(atPath: fileURL.path)
     DILog.print(items: filePaths)
      
      
      for _ in filePaths
      {
        try fileManager.removeItem(atPath: documentsURL.appendingPathComponent(fileURL.path).path)
        // fire delegation with sucess bool
      }
    } catch let error as NSError {
     DILog.print(items: "Could not clear temp folder: \(error.debugDescription)")
    }
    
  }
  
  
  @objc func saveImageIfNeeded(downloadUrl:String, withName fileName:String)  {
    
    //        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
    //
    //            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    //            let fileURL = documentsURL.appendingPathComponent(fileName + ".png")
    //            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
    //        }
    //
    //        Alamofire.download(downloadUrl, to: destination).downloadProgress(closure: { (progress) in
    //
    //        }).response { response in
    //
    //            if response.error == nil, let LocalimagePath = response.destinationURL?.path {
    //
    //               DILog.print(items: LocalimagePath)
    //
    //                guard let shouldUpdate = self.DIFIRdelegate?.didSavedlocally(sucess: true) else {
    //                        return
    //                }
    //
    //
    //            }else{
    //               DILog.print(items: response.error!)
    //                guard let shouldUpdate = self.DIFIRdelegate?.didSavedlocally(sucess: false) else {
    //                    return
    //                }
    //            }
    //        }
  }
    
    
    
    
    
    
    
    
    
    
    func uploadImage1(data: Data, withQuality value: CGFloat = 1.0,mediaObj:Media, withName: String,mimeType:String, progress : @escaping (String) -> (),completion: @escaping (_ apiResponse: APICallBacks, _ apiUrl: String?, _ error: DIError,_ media:Media) -> ())
    {
        
        let imagePath = withName
        let metadata = StorageMetadata()
        metadata.contentType = mimeType
        metadata.customMetadata = ["index": String(describing: index), "contentType": mimeType]
        
        // Upload file and metadata to the object 'images/mountains.jpg'
        let imageReference = storageRef.child(imagePath)
        let uploadTask = imageReference.putData(data, metadata: metadata)
        allTasks.append(uploadTask)
        // Listen for state changes, errors, and completion of the upload.
        uploadTask.observe(.resume) { snapshot in
            // Upload resumed, also fires when the upload starts
        }
        
        uploadTask.observe(.pause) { snapshot in
            // Upload paused
        }
        
        
        uploadTask.observe(.progress) { snapshot in
            // Upload reported progress
            let percentComplete =  Double((snapshot.progress?.completedUnitCount)!)/Double(snapshot.progress!.totalUnitCount)
            progress( String(format: "%.2f", percentComplete))
            DILog.print(items:percentComplete)
        }
        
        uploadTask.observe(.success) { snapshot in
            // Upload completed successfully
            //Download the the image from url and save it as Data in local directory
            imageReference.downloadURL(completion: { (url, error) in
                if let error = error {
                    print("did not get the download url")
                    print(error)
                } else {
                    DILog.print(items:url?.absoluteString ?? "no url found......")
                    completion(.success,(url?.absoluteString), DIError.noResponse(), mediaObj)
                }
            })
            // self.startDownloading(downloadUrl: (snapshot.metadata?.downloadURL()?.absoluteString)!, imageName: imagePath)
        }
        
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error as NSError? {
                completion(.failure, nil, DIError.serverResponseError(error: error),mediaObj)
                
                switch (StorageErrorCode(rawValue: error.code)!) {
                    
                case .objectNotFound:
                    // File doesn't exist
                    DILog.print(items: "OBJECT NOT FOUND")
                case .unauthorized:
                    // User doesn't have permission to access file
                    DILog.print(items: "UNATHRIZED")
                case .cancelled:
                    // User canceled the upload
                    DILog.print(items: "CANCELLED")
                    /* ... */
                case .unknown:
                    // Unknown error occurred, inspect the server response
                    DILog.print(items: "UNKNOWN")
                default:
                    // A separate error occurred. This is a good place to retry the upload.
                    break
                }
            }
        }
    }
    
    
//    func imageUploadRequest(image: UIImage, uploadUrl: NSURL, param: [String:String]?) {
//
//        //let myUrl = NSURL(string: "http://192.168.1.103/upload.photo/index.php");
//
//        let request = NSMutableURLRequest(url:uploadUrl as URL);
//        request.httpMethod = "POST"
//
//        let boundary = generateBoundaryString()
//
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        let imageData = image.jpegData(compressionQuality: 1)
//        if(imageData == nil)  { return; }
//
//        request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "file", imageDataKey: imageData! as NSData, boundary: boundary) as Data
//
//        //myActivityIndicator.startAnimating();
//
//        let task =  URLSession.shared.dataTask(with: request as URLRequest,
//                                                                     completionHandler: {
//                                                                        (data, response, error) -> Void in
//                                                                        if let data = data {
//
//                                                                            // You can print out response object
//                                                                            print("******* response = \(response)")
//
//                                                                            print(data.count)
//                                                                            // you can use data here
//
//                                                                            // Print out reponse body
//                                                                            let responseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
//                                                                            print("****** response data = \(responseString!)")
//
//                                                                            let json =  try!JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
//
//                                                                            print("json value \(json)")
//
//                                                                            //var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &err)
////
////                                                                            dispatch_async(dispatch_get_main_queue(),{
////                                                                                //self.myActivityIndicator.stopAnimating()
////                                                                                //self.imageView.image = nil;
////                                                                            });
//
//                                                                        } else if let error = error {
//                                                                           // print(error.description)
//                                                                        }
//        })
//        task.resume()
//
//
//    }
//
//
//    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
//        let body = NSMutableData();
//
//        if parameters != nil {
//            for (key, value) in parameters! {
//                body.appendString(string: "--\(boundary)\r\n")
//                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
//                body.appendString(string: "\(value)\r\n")
//            }
//        }
//
//        let filename = "user-profile.jpg"
//
//        let mimetype = "image/jpg"
//
//        body.appendString(string: "--\(boundary)\r\n")
//        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
//        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
//        body.append(imageDataKey as Data)
//        body.appendString(string: "\r\n")
//
//        body.appendString(string: "--\(boundary)--\r\n")
//
//        return body
//    }
//
//    func generateBoundaryString() -> String {
//        return "Boundary-\(NSUUID().uuidString)"
//    }
//
//}// extension for impage uploading
//
//extension NSMutableData {
//
//    func appendString(string: String) {
//        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
//        append(data!)
//    }
//}
//
//
//
//
//
//
//
}
