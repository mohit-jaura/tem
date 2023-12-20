//
//  PhotoManager.swift
//  TemApp
//
//  Created by Sourav on 2/15/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Photos

typealias PhotoTakingHelperCallback = ((UIImage?) -> Void)
typealias CallbackwithURL = ((UIImage?) -> Void)

enum ImagePickerOptions: Int {
    case Camera
    case Gallery
}

private struct constant {
    static let actionTitle = "Choose From"
    static let actionMessage = "Please select an option to choose image"
    static let cameraBtnTitle = "Take Picture"
    static let galeryBtnTitle = "Select From Gallery"
    static let cancelBtnTitle = "Cancel"
}

@objc class PhotoManager:NSObject {
    
    let imagePicker = UIImagePickerController()
    internal var navController: UINavigationController!
    internal var callback: PhotoTakingHelperCallback!
    var allowEditing: Bool
    
    /*
     Intialize the navController from give reference of navigationcontroller while creating Photomanager class object.
     Callback: Callback will be call after the picking image.
     */
    init(navigationController:UINavigationController, allowEditing:Bool , callback:@escaping PhotoTakingHelperCallback) {
        
        self.navController = navigationController
        self.callback = callback
        self.allowEditing = allowEditing
        super.init()
        
        self.presentActionSheet()
        
    }
    
    
    // MARK: ImagePicker Custom Functions
    /// Presenting sheet with option to select image source
    private func presentActionSheet() {
        
        let alertController = UIAlertController(title: constant.actionTitle, message: constant.actionMessage, preferredStyle: .actionSheet)
        
        //For Gallery.....
        
        let  galleryButton = UIAlertAction(title: constant.galeryBtnTitle, style: .default, handler: { (_) -> Void in

            self.checkPhotoLibraryPermission()
        })
        alertController.addAction(galleryButton)
        //
        
        //For Camera.....
        let  cameraButton = UIAlertAction(title: constant.cameraBtnTitle, style: .default, handler: { (_) -> Void in
            
            self.checkCameraPermission()
        })
        alertController.addAction(cameraButton)
        //
        
        //For Cancel....
        
        let cancelButton = UIAlertAction(title: constant.cancelBtnTitle, style: .cancel, handler: { (_) -> Void in
            
        })
        alertController.addAction(cancelButton)
        
        //
        navController.present(alertController, animated: true, completion: nil)
    }
    
    //This Function will check the Camera permission.....
    
    private func checkCameraPermission() {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                
                if granted {
                    self.presentUIimagePicker(type: .camera)
                } else {
                    self.showAlertViewWithAction(title: AppMessages.camera.photoPermissionTitle, message: AppMessages.camera.photoPermissionMessage)
                }
            }
            
        case .authorized:
            self.presentUIimagePicker(type: .camera)
            
        case .denied, .restricted:
            self.showAlertViewWithAction(title: AppMessages.camera.photoPermissionTitle, message: AppMessages.camera.photoPermissionMessage)
            
        @unknown default:
            break
        }
    }
    
    //This Fucntion will check the Photo Permission....
    
  private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
            
        case .authorized, .limited:
            self.presentUIimagePicker(type: .photoLibrary)
            
        case .denied, .restricted :
            self.showAlertViewWithAction(title: AppMessages.camera.photoPermissionTitle, message: AppMessages.camera.photoPermissionMessage)
            
        //handle denied status
        case .notDetermined:
            // ask for permissions
            
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized:
                    
                    self.presentUIimagePicker(type: .photoLibrary)
                case .denied, .restricted , .notDetermined:
                    self.showAlertViewWithAction(title: AppMessages.camera.photoPermissionTitle, message: AppMessages.camera.photoPermissionMessage)
                case .limited:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    func showAlertViewWithAction(title:String,message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
            
            //Open Setting....
            self.openSetting()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Don't Allow", style: .cancel, handler: { (_) in
            //        cancelCall
        }))
        self.navController.present(alert, animated: true, completion: nil)
        
    }
    
    //This Fucntion will open the setting to give permission
    
    private func openSetting() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            } else {
                UIApplication.shared.openURL(NSURL(string:UIApplication.openSettingsURLString)! as URL)
                // Fallback on earlier versions
            }
        }
    }
    
    /*
     presentUIimagePicker will present the UIImagePicker with give type
     type: Camera or Gallery
     controller: UINavigationcontroller, navigationcontroller on with uiimagepicker will present.
     */
    private func presentUIimagePicker(type: UIImagePickerController.SourceType){
        DispatchQueue.main.async {
            self.imagePicker.allowsEditing = self.allowEditing
            self.imagePicker.sourceType = type
            self.imagePicker.delegate = self
            
            self.navController.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
}

/*Extension for UIImagePickerControllerDelegate & UINavigationControllerDelegate
 
 
 */
extension PhotoManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if(allowEditing) {
            guard let pickedEditedImage = info[.editedImage] as? UIImage else {
                return
            }
            callback(pickedEditedImage)
        } else {
            guard let pickedOriginalImg = info[.originalImage] as? UIImage else {
                return
            }
            callback(pickedOriginalImg)
        }
        navController.dismiss(animated: true, completion: nil)
        
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        navController.dismiss(animated: true, completion: nil)
    }
}

