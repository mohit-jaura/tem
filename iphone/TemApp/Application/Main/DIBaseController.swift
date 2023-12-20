//
//  DIBaseController.swift
//  BaseProject
//
//  Created by narinder on 28/02/17.
//  Copyright © 2017 openkey. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import NVActivityIndicatorView
import MessageUI
import MediaPlayer
import Mute

class DIBaseController: UIViewController {
    
    var returnKeyHandler: IQKeyboardReturnKeyHandler!
    let  activityIndicator = UIActivityIndicatorView()
    let refresh = UIRefreshControl()
    let footerViewHeight: CGFloat = 40
    var pageLimit = 10
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.hideNavBar = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // self.hideNavBar = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /// Will hide shoe nav bar according to bool value
    var hideNavBar: Bool? {
        didSet {
            UINavigationBar.appearance().barTintColor = .clear
            UINavigationBar.appearance().tintColor = UIColor.white
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
            UINavigationBar.appearance().backgroundColor = .clear
            
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.setNavigationBarHidden(hideNavBar!, animated: false)
        }
    }
    
    
    /// Will hide shoe nav bar according to bool value
    var hideBackButton: Bool? {
        didSet {
            if hideBackButton == false{
                self.hideNavBar = false
                let image : UIImage? =       UIImage(named:"Back")!.withRenderingMode(.alwaysOriginal)
                let newBtn = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(goBack))
                self.navigationItem.leftItemsSupplementBackButton = false
                self.navigationItem.leftBarButtonItem = newBtn
            }else{
                self.hideNavBar = true
                self.navigationItem.leftBarButtonItem = nil
            }
        }
    }
    
    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setIQKeyboardManager(toEnable status: Bool) {
        IQKeyboardManager.shared.enable = status
        IQKeyboardManager.shared.enableAutoToolbar = status
    }
    
    func keyboardDisplayedWithHeight(value: CGFloat) {
        //implement in the child class
    }
    
    func keyboardHide(height: CGFloat) {
        //implement in the child class
    }
    
    //This method will change all textfield return keys next or done accoring to their view heierachy.
    func viewDidLoadWithKeyboardManager( viewController: UIViewController) {
        super.viewDidLoad()
        returnKeyHandler = IQKeyboardReturnKeyHandler.init(controller: viewController)
        returnKeyHandler.lastTextFieldReturnKeyType = .done
    }

    //MARK:- Output Volume Helpers
    /// observing the key path observers and get the respective value
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == Constant.KeyPathObserver.outputVolume {
            let outputVolume = AVAudioSession.sharedInstance().outputVolume
            //if the output volume is 0 then change the mute status to false (mute the videos), else change it to true
            if outputVolume == 0.0 {
                updateDefaultsForSoundStatus(withValue: true)
            } else {
                updateDefaultsForSoundStatus(withValue: false)
            }
            self.outputVolumeChanged()
        }
    }
    
    /// add observer to listen the volume change notifications from the device
    func listenVolumeButton(){
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
        } catch {
            print("error")
        }
        audioSession.addObserver(self, forKeyPath: Constant.KeyPathObserver.outputVolume,
                                 options: NSKeyValueObservingOptions.new, context: nil)
        Mute.shared.alwaysNotify = false
        Mute.shared.notify = { [weak self] status in
            self?.updateDefaultsForSoundStatus(withValue: status)
            self?.outputVolumeChanged()
        }
    }
    
    func updateDefaultsForSoundStatus(withValue value: Bool) {
        Defaults.shared.set(value: value, forKey: .muteStatus)
    }
    
    func removeVolumeListeners() {
        AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: Constant.KeyPathObserver.outputVolume)
    }
    
    /// call this function in the base class where the view needs to be updated on volume change
    func outputVolumeChanged() {}
}

extension DIBaseController: NVActivityIndicatorViewable {
    /*
     Show loader will add the custom loader view to current controller
     */
    func showLoader(message: String = "Please wait...", color: UIColor = .white) {
        //let size = CGSize(width: 120, height:120)
        
        startAnimating(CGSize.init(width: 140, height: 140), message: message, messageFont: UIFont.boldSystemFont(ofSize: 15), type: .orbit, color: color, padding: 20, displayTimeThreshold: 1, minimumDisplayTime: 3, backgroundColor: UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.6), textColor: .white)
    }
    
    
    /*
     Hide loader will from remove its superview and hide loader from current view
     */
    func hideLoader() {
        stopAnimating()
    }
    
    func showIndicator()->UIView{
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40)
        let container = UIView(frame: frame)
        activityIndicator.frame = frame
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        activityIndicator.color = UIColor.gray
        activityIndicator.startAnimating()
        container.addSubview(activityIndicator)
        return container
    }
    
    
}//Extension + Class.....

extension DIBaseController {
    /// This Method is used to display the Error to user
    ///
    /// - Parameter error: Error Generated By System
    /// - Author: Aj Mehra
    
    func showAlert(withError error: DIError = DIError.unKnowError(), okayTitle: String = AppMessages.AlertTitles.Ok, cancelTitle: String? = nil, okCall: @escaping () -> () = {  }, cancelCall: @escaping () -> () = {  }) {
        showAlert(message: error.message, okCall: {
            okCall()
        }) {
            cancelCall()
        }
    }
    
    @objc func showAlert(withTitle title: String? = "", message:String? = nil, okayTitle:String = "ok".localized , cancelTitle:String? = nil , okCall:@escaping () -> ()  = {  }, cancelCall: @escaping () -> () = {  }) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okayTitle, style: .default, handler: { (action) in
            okCall()
        }))
        if cancelTitle != nil {
            alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: { (action) in
                cancelCall()
            }))
        }
        present(alert, animated: true, completion: nil)
    }
}

