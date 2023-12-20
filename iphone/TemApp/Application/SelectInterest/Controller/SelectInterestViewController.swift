//
//  SelectInterestViewController.swift
//  TemApp
//
//  Created by dhiraj on 22/02/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import Alamofire

enum SelectInterestButtonTitle : String {
    case cancel = "CANCEL"
    case update = "UPDATE"
    case chooseInterestLater = "CHOOSE INTERESTS LATER"
    case saveAndContinue = "SAVE & CONTINUE"
}

class SelectInterestViewController: DIBaseController {
    
    // MARK: @IBoutlets:---
    @IBOutlet weak var chooseInterestButton: UIButton!
    @IBOutlet weak var saveAndContinueButton: UIButton!
    @IBOutlet weak var navigationBarView: UIView!
    var isComingFromDashBoard:Bool = false
    @IBOutlet weak var skHoneyCombView: SelectInterestHoneyCombView!
    // MARK: Variables.....
    var honeycombObjectsArray: [SKHoneyCombObject] = []
    private var interests: [Activity]?
    private var reachability:Reachability!;
    
    private var selectedInterests: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        self.selectedInterests = User.sharedInstance.interests
        let reachabilityManager = NetworkReachabilityManager()
        
        reachabilityManager?.startListening()
        reachabilityManager?.listener = { _ in
            if let isNetworkReachable = reachabilityManager?.isReachable,
                isNetworkReachable == true {
                //Internet Available
                self.getInterestData()
            } else {
                //Internet Not Available"
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

        /*if isComingFromDashBoard {
            chooseInterestButton.setTitle(SelectInterestButtonTitle.cancel.rawValue, for: .normal)
            saveAndContinueButton.setTitle(SelectInterestButtonTitle.update.rawValue, for: .normal)
        } else {
            chooseInterestButton.setTitle(SelectInterestButtonTitle.chooseInterestLater.rawValue, for: .normal)
            saveAndContinueButton.setTitle(SelectInterestButtonTitle.saveAndContinue.rawValue, for: .normal)
        } */
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    func createHoneyComb(data: [Activity]) {
        if self.interests == nil {
            self.interests = [Activity]()
        }
        self.honeycombObjectsArray = []
        self.interests?.append(contentsOf: data)
        for (_,item) in data.enumerated() {
            let honeycombObject = SKHoneyCombObject()
            honeycombObject.name = item.name
            honeycombObject.id = item.id
            honeycombObject.image = item.image
            honeycombObject.icon = item.icon
            if User.sharedInstance.interests.contains(item.id ?? "") {
                honeycombObject.isSelected = true
            }else{
                honeycombObject.isSelected = false
            }
            self.honeycombObjectsArray.append(honeycombObject)
        }
        self.skHoneyCombView.honeyCombObjectsArr = self.honeycombObjectsArray
        self.skHoneyCombView.layoutSubviews()
        self.skHoneyCombView.delegate = self
    }
    
    func getInterestData() {
        self.showLoader()
        DIWebLayerUserAPI().getInterestsList(success: { (data) in
            self.hideLoader()
            self.createHoneyComb(data: data)
        }) { (error) in
            self.hideLoader()
            self.showAlert(message:error.message)
        }
        
    }
    
    func saveInterestData() {
        guard isConnectedToNetwork() else {
            return
        }
        self.showLoader()
        DIWebLayerUserAPI().saveInterestsList(parameters: ["interest":self.selectedInterests], success: { (message) in
            self.hideLoader()
            self.updateProfileStatusToServer()
            self.setProfileControllerOnRoot()
            let user = User.sharedInstance
            user.interests.removeAll()
            user.interests.append(contentsOf: self.selectedInterests)
            UserManager.saveCurrentUser(user: user)
            //            let tabBarVC:TabBarViewController = UIStoryboard(storyboard: .dashboard).initVC()
            //            appDelegate.setNavigationToRoot(viewContoller: tabBarVC)
        }) { (error) in
            self.hideLoader()
            self.showAlert(message:error.message)
        }
    }
    
    //update status to server
    private func updateProfileStatusToServer() {
        let parameters: Parameters = ["status": UserProfileCompletion.selectInterests.rawValue]
        DIWebLayerUserAPI().updateProfileCompletionStatus(parameters: parameters) { (_) in
            let user = User.sharedInstance
            user.profileCompletionStatus = UserProfileCompletion.selectInterests.rawValue
            UserManager.saveCurrentUser(user: user)
        }
    }
    
    @IBAction func skipButtonAction(_ sender: UIButton) {
        self.updateProfileStatusToServer()
        self.setProfileControllerOnRoot()
    }
    @IBAction func saveAndContinueAction(_ sender: Any) {
        if isComingFromDashBoard == false,
            self.selectedInterests.count == 0 {
            self.showAlert(message:"Please select at least one interest.")
        }else{
            saveInterestData()
        }
    }
    // MARK: Function to set Navigation Bar.
    private func initUI() {
        self.setNavigationController(titleName: Constant.ScreenFrom.interest.title, leftBarButton: nil, rightBarButtom: nil, backGroundColor: .white, translucent: true)
        self.navigationController?.setTransparentNavigationBar()
    }
    
    // MARK: Helpers
    private func setProfileControllerOnRoot() {
        if isComingFromDashBoard {
            self.navigationController?.popViewController(animated: true)
            return
        }
        if let deeplinkInfo = appDelegate.deepLinkInfo() {
            if let postId = deeplinkInfo.postId {
                self.handleDeepLinkOfPostShare(id: postId)
            } else if let affiliateMarketPlaceId = deeplinkInfo.affiliateMarketPlaceId {
                self.handleDeepLinkOfAffiliateShare(id: affiliateMarketPlaceId)
            }
            return
        }
        //the user is coming from signup process
        let isDeepLinkingPage = appDelegate.getDeepLinkRedirectionStatus()
        if isDeepLinkingPage {
            appDelegate.saveDeepLinkRedirection(value: false)
            return
        } else {
            User.sharedInstance.isFromSignUp = true
            let networkVC:HomePageViewController = UIStoryboard(storyboard: .dashboard).initVC()
            appDelegate.setNavigationToRoot(viewContoller: networkVC)
        }
    }
    
}
extension SelectInterestViewController : HoneyCombViewDelegate{
    
    func didSelectHoneyComb(_ honeyCombObject: SKHoneyCombObject, _ honeyCombView: HoneyComb) {
        honeyCombObject.isSelected = !honeyCombObject.isSelected
        if honeyCombObject.isSelected {
            //User.sharedInstance.interests.append(honeyCombObject.id ?? "")
            self.selectedInterests.append(honeyCombObject.id ?? "")
            if honeyCombView.backGroundImage.image != nil{
                honeyCombView.shadowView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                honeyCombView.shadowView.alpha = 0.7
                honeyCombView.iconImage.setImageColor(color: UIColor.black)
                honeyCombView.title.textColor = UIColor.black
            }
        }else {
            /*for(index,data) in User.sharedInstance.interests.enumerated() {
                if data == honeyCombObject.id {
                    User.sharedInstance.interests.remove(at: index)
                }
            } */
            if !self.selectedInterests.isEmpty {
                for(index,data) in selectedInterests.enumerated() {
                    if data == honeyCombObject.id {
                        selectedInterests.remove(at: index)
                    }
                }
            }
            if let imageString = honeyCombObject.image {
                if let url = URL(string: BuildConfiguration.shared.serverUrl + imageString){
                    honeyCombView.backGroundImage.kf.setImage(with: url)
                    honeyCombView.shadowView.backgroundColor = .black
                    honeyCombView.shadowView.alpha = 0.6
                    honeyCombView.iconImage.setImageColor(color: UIColor.white)
                    honeyCombView.title.textColor = UIColor.white
                }
            }
        }
    }
    
    func didClickOnStart() {
        if self.selectedInterests.count == 0 {
            self.showAlert(message:"Please select at least one interest.")
        }else{
            saveInterestData()
        }
    }
    
}
extension UIImage {
    
    /**
     Tint, Colorize image with given tint color<br><br>
     This is similar to Photoshop's "Color" layer blend mode<br><br>
     This is perfect for non-greyscale source images, and images that have both highlights and shadows that should be preserved<br><br>
     white will stay white and black will stay black as the lightness of the image is preserved<br><br>
     
     <img src="http://yannickstephan.com/easyhelper/tint1.png" height="70" width="120"/>
     
     **To**
     
     <img src="http://yannickstephan.com/easyhelper/tint2.png" height="70" width="120"/>
     
     - parameter tintColor: UIColor
     
     - returns: UIImage
     */
    func tintPhoto(_ tintColor: UIColor) -> UIImage {
        
        return modifiedImage { context, rect in
            // draw black background - workaround to preserve color of partially transparent pixels
            context.setBlendMode(.normal)
            UIColor.black.setFill()
            context.fill(rect)
            
            // draw original image
            context.setBlendMode(.normal)
            context.draw(cgImage!, in: rect)
            
            // tint image (loosing alpha) - the luminosity of the original image is preserved
            context.setBlendMode(.color)
            tintColor.setFill()
            context.fill(rect)
            
            // mask by alpha values of original image
            context.setBlendMode(.destinationIn)
            context.draw(context.makeImage()!, in: rect)
        }
    }
    
    /**
     Tint Picto to color
     
     - parameter fillColor: UIColor
     
     - returns: UIImage
     */
    func tintPicto(_ fillColor: UIColor) -> UIImage {
        
        return modifiedImage { context, rect in
            // draw tint color
            context.setBlendMode(.normal)
            fillColor.setFill()
            context.fill(rect)
            
            // mask by alpha values of original image
            context.setBlendMode(.destinationIn)
            context.draw(cgImage!, in: rect)
        }
    }
    
    /**
     Modified Image Context, apply modification on image
     
     - parameter draw: (CGContext, CGRect) -> ())
     
     - returns: UIImage
     */
    private func modifiedImage(_ draw: (CGContext, CGRect) -> ()) -> UIImage {
        
        // using scale correctly preserves retina images
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context: CGContext! = UIGraphicsGetCurrentContext()
        assert(context != nil)
        
        // correctly rotate image
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        draw(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
}
