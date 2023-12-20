//
//  SplashViewController.swift
//  TemApp
//
//  Created by Sourav on 2/12/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//
import AVFoundation
import AVKit
import UIKit
import Firebase

class SplashViewController: DIBaseController {
    
    // MARK: Variables:---
    var user:User?
    static var isSplash:Bool = true
    var player: AVPlayer?
    var timer: Timer?
    // MARK: @IBOutlets:-----
    
    @IBOutlet weak var logo: UIImageView!
    
    // MARK: App life Cycle:---
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        FirebaseApp.configure()
        DispatchQueue.main.async { [weak self] in
            self?.initializeVideoPlayer()
        }
        intializer()
//        self.checkToRedirection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: Custom Methods:---
    private func initializeVideoPlayer() {
        loadVideo()
        timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(stopVideo), userInfo: nil, repeats: true)
    }
    private func loadVideo() {
        //this line is important to prevent background music stop
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
        } catch { }
        
        let path = Bundle.main.path(forResource: "splash screen final", ofType:"mp4")
        
        let filePathURL = NSURL.fileURL(withPath: path!)
        player = AVPlayer(url: filePathURL)
        let playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.frame = self.view.frame
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer.zPosition = -1
        
        self.view.layer.addSublayer(playerLayer)
        
        player?.seek(to: CMTime.zero)
        player?.play()
    }
    @objc func stopVideo(){
        timer?.invalidate()
        player?.pause()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.checkToRedirection()
        }
    }
    private func intializer() {
        user = UserManager.getCurrentUser()
        User.sharedInstance = user ?? User()
    }
    
    private func navigateToLoginPage() {
        let loginVC:LoginViewController = UIStoryboard(storyboard: .main).initVC()
        appDelegate.setNavigationToRoot(viewContoller: loginVC, animated: true)
    }
    
    private func navigateToCreateProfile() {
        let createProfileVC:CreateProfileViewController = UIStoryboard(storyboard: .main).initVC()
        // self.navigationController?.pushViewController(createProfileVC, animated: true)
        appDelegate.setNavigationToRoot(viewContoller: createProfileVC, animated: true)
    }
    private func navigateToDashBoard() {
        let homeVC: HomePageViewController = UIStoryboard(storyboard: .dashboard).initVC()
        appDelegate.setNavigationToRoot(viewContoller: homeVC, animated: true)
    }
    
    private func handleDeepLinking() {
        if let deeplinkInfo = appDelegate.deepLinkInfo() {
            if let postId = deeplinkInfo.postId {
                self.handleDeepLinkOfPostShare(id: postId)
            } else if let affiliateMarketPlaceId = deeplinkInfo.affiliateMarketPlaceId {
                self.handleDeepLinkOfAffiliateShare(id: affiliateMarketPlaceId)
            }
            return
        }
        let isDeepLinkingPage = appDelegate.getDeepLinkRedirectionStatus()
        if isDeepLinkingPage {
            appDelegate.saveDeepLinkRedirection(value: false)
            return
        } else {
            navigateToDashBoard()
        }
    }
    private func navigateToSelectInterest() {
        let networkVC:SelectInterestViewController = UIStoryboard(storyboard: .main).initVC()
        appDelegate.setNavigationToRoot(viewContoller: networkVC, animated: true)
    }

    private func checkToRedirection() {
        if SplashViewController.isSplash {
            if user != nil {
                let name = user?.firstName ?? ""
                //  Analytics.logEvent("userSessionCount", parameters: ["name": name,"id": user?.id])
                AnalyticsManager.logEventWith(event: Constant.EventName.userSessionCount,parameter: ["name": name,"id": user?.id ?? ""])
                if User.sharedInstance.profileCompletionStatus == UserProfileCompletion.notDone.rawValue {
                    print("send to profile completion ***********")
                    self.navigateToCreateProfile()
                    User.sharedInstance.isFromSignUp = true
                } else if User.sharedInstance.profileCompletionStatus == UserProfileCompletion.createProfile.rawValue {
                    print("send to select interests ***********")
                    User.sharedInstance.isFromSignUp = true
                    self.navigateToSelectInterest()
                } else {
                    self.handleDeepLinking()
                }
            } else {
                self.navigateToLoginPage()
            }
        }else{
            SplashViewController.isSplash = true
        }
    }
}
