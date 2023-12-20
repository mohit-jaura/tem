//
//  StreamAudienceVC.swift
//  TemApp
//
//  Created by PrabSharan on 31/08/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import AgoraRtcKit
import IQKeyboardManagerSwift
import NVActivityIndicatorView
import UIKit
class StreamAudienceVC: DIBaseController {
    
    @IBOutlet weak var heightForChatContainerView: NSLayoutConstraint!
    @IBOutlet weak var blurrImageView: UIImageView!
    var token:String?
    var isConnectedToStreaming :Bool = false
    var channelName :String?
    var roomId:String?
    var userID:UInt = 12345
    var streamModal:StreamModal?
    var userRole: AgoraClientRole = .audience
    var timer:Timer?
    var intervalTime:Double = 1
    var chatManager:ChatManager?
    var sendMessage:StringCompletion?
    var voidCallBack:OnlySuccess?
    let hostingView = UIView()
    let videoCanvas = AgoraRtcVideoCanvas()

    @IBOutlet weak var profileImgVirw: CircularImgView!
    
    @IBOutlet weak var chatContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatContainerView: UIView!
    @IBOutlet weak var loaderView: NVActivityIndicatorView!
    @IBOutlet weak var streamView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var totalLiveCountButOut: UIButton!
    @IBOutlet weak var closeButOut: UIButton!
    @IBOutlet weak var liveLabel: UILabel!
    @IBOutlet weak var sendButton:UIButton!
    @IBOutlet weak var messageTextView:IQTextView!
    @IBOutlet weak var messageViewBottomConstraint:NSLayoutConstraint!
    @IBOutlet weak var messageTextViewHeightConstraint: NSLayoutConstraint!

    let config = AgoraVideoEncoderConfiguration()
    var isHighDefinition: Bool {
        return streamModal?.highStreamQuality ?? 0 == 1
    }
    lazy var agkit: AgoraRtcEngineKit! = {
        let engine = AgoraRtcEngineKit.sharedEngine(
            withAppId: StreamHelper.appId,
            delegate: self
        )
        if isHighDefinition {         engine.setRemoteDefaultVideoStreamType(.high)
        } else {
            engine.setRemoteDefaultVideoStreamType(.low)
        }
        engine.setChannelProfile(.liveBroadcasting)
        engine.setClientRole(userRole)
        config.orientationMode =  .fixedLandscape
        engine.setVideoEncoderConfiguration(config)
        return engine
    }()
    lazy var localVideoView: UIView = {
        let vview = UIView()
        return vview
    }()
    var remoteUserIDs: Set<UInt> = []
    var tap :UITapGestureRecognizer?
    override func viewDidLoad() {
        super.viewDidLoad()
        initialise()
        Stream.connect.isVideoShown = true
        Stream.isComingFromInActiveApp = false
        Stream.affiliateID = nil
        messageTextView.delegate = self
        self.messageTextView.returnKeyType = .done
        messageTextView.keyboardAppearance = .dark
        self.messageTextView.text = nil
        self.setIQKeyboardManager(toEnable: false)
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        self.addKeyboardNotificationObservers()
       // setOrientationMode()
        notiForOrientaion()
        
    }
    func notiForOrientaion() {
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)

    }
    deinit {
       NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }

   @objc func rotated() {
       self.view.layoutIfNeeded()
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            OrientationManager.landscapeSupported = true
            OrientationManager.setOrientation(.landscapeLeft)
            setOrientationMode(.fixedLandscape)
            //self.view.layoutSubviews()
        } else {
            OrientationManager.landscapeSupported = false
             setOrientationMode(.fixedPortrait)
            OrientationManager.setOrientation(.portrait)
            print("Portrait")
        }
    }

    func setOrientationMode(_ mode:AgoraVideoOutputOrientationMode = .fixedLandscape) {
        config.orientationMode =  mode
        agkit.setVideoEncoderConfiguration(config)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        OrientationManager.landscapeSupported = false
        let orientationValue = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(orientationValue, forKey: "orientation")
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)

    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        resetCallBacknTimers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initialiseRecentJoinedCallBacks()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hostingView.frame = streamView.bounds
    }
    
    // MARK: Initialsie Methods
    func initialise() {
        self.view.alpha = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            Stream.connect.openPop(.Connecting, parent: self) {
                self.leaveChannel()
            }

        })
        uiInitilaise()
        initialiseModal()
        addChatVC()
        addTapGester()
        removeHeaderAppearAgain()
    }
    func removeHeaderAppearAgain() {
        Stream.connect.resetAllBanners()
        Stream.connect.addDetailsToDefaults(streamModal?.channel_id, streamModal?.affiliate_id)
    }

    func addTapGester() {
        tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardSec))
        tap?.cancelsTouchesInView = false
        tap?.delegate = self
        if let tap = tap{
            view.addGestureRecognizer(tap)
        }
    }
    @objc func dismissKeyboardSec() {
        
    }
    // MARK: UI intialise
    
    func showBlurrImage() {
        UIView.animate(withDuration: 1, delay: 0, options: .curveLinear, animations: {
            self.blurrImageView.alpha  = 0
        }, completion: nil)
    }
    
    func uiInitilaise() {
        //  liveLabel.isHidden = true
        blurrImageView.alpha = 0
        blurrImageView.addBlur()
        loaderView.isHidden = true
        //   loaderView.alpha = 0.9
        // loaderView.isHidden = false
        liveLabel.backgroundColor = SystemColors.systemMainSecondColor
        liveLabel.cornerRadius = 5
        totalLiveCountButOut.cornerRadius = 5
        totalLiveCountButOut.tintColor = .white
        closeButOut.cornerRadius = 5
        closeButOut.backgroundColor = .red
    }
    
    /// Local modal initialse
    func initialiseModal() {
        if let token = streamModal?.token,let name = streamModal?.channel_id, let uID = streamModal?.uid,let chatRoomId = streamModal?.chat_room_id {
            self.token = token
            self.channelName = name
            self.userID = UInt(uID)
            self.roomId = chatRoomId
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                print("Join channel call")
                self.joinStreaming()
            })
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.dismiss(animated: true) {
                    self.alertOpt("Error Connecting", okayTitle: "Exit", okCall: {
                        self.dismiss(animated: true)
                    }, parent: self)
                }
            })
        }
        blurrImageView.setImg(streamModal?.affilaiateProfileImage)
        profileImgVirw.setImg(streamModal?.affilaiateProfileImage)
        nameLabel.text = "\(streamModal?.affiliate_first_name ?? "")" + (streamModal?.affiliate_last_name ?? "")
    }
    /// Add Chat in View
    ///
    func addChatVC() {
        let VC = loadVC(.LiveSessionChatVC) as! LiveSessionChatVC
        VC.sessionId = roomId
        addChild(VC)
        VC.dynamicHeight = {(height) in
            self.view.layoutIfNeeded()
            self.heightForChatContainerView.constant = height
        }
        VC.view.frame = self.chatContainerView.bounds
        chatContainerView.addSubview(VC.view)
        VC.didMove(toParent: self)
    }
    // MARK: Reset Call Backs and Timers from VC
    func resetCallBacknTimers() {
        timer?.invalidate()
        timer = nil
        Stream.connect.isVideoShown = false
        chatManager?.streamJoinedListener?.remove()
        chatManager?.removeRecentlyJoined(roomId ?? "")
        chatManager = nil
    }
    
    // MARK: Set Call Backs and Timers from VC
    
    func initialiseRecentJoinedCallBacks() {
        chatManager = ChatManager()
        writeRecentTimeToFB()
        timerInitialiseForRecentTimeToFB()
        connectToJoinedMembers()
    }
    func timerInitialiseForRecentTimeToFB() {
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: StreamHelper.secForWriteDelay, target: self, selector: #selector(writeRecentTimeToFB), userInfo: nil, repeats:                 true)
    }
    
    func connectToJoinedMembers() {
        
        chatManager?.queryRecentlyJoinedMembers(roomId ?? "") { [weak self] count in
            guard let self = self else {return }
            DispatchQueue.main.async {
                debugPrint(count)
                self.totalLiveCountButOut.isHidden = count == 0
                self.totalLiveCountButOut.setTitle("\(count)", for: .normal)
            }
        }
    }
    
    @objc func writeRecentTimeToFB() {
        chatManager?.writeJoinedCount(chatId: self.roomId ?? "")
    }
    // MARK: Method for join Streaming
    
    @objc func joinStreaming() {

        agkit.enableVideo()
        agkit.enableAudio()

      //  streamView.backgroundColor = .red
        self.agkit.joinChannel(
                byToken: self.token ?? "",
                channelId: self.channelName ?? "",
                info: nil, uid: self.userID
            ) { [weak self] _, _, _ in
                //self?.userID = uid
                print("Live stream started")
               // self?.showBlurrImage()
            }

        //})
    }
    /// Leave the Agora channel and return to the main screen
    @objc func leaveChannel() {
        self.agkit.leaveChannel(nil)
        AgoraRtcEngineKit.destroy()
        self.dismiss(animated: false)
    }
    
    override func dismissKeyboard() {
        print("Do nothing")
    }
    @IBAction func endAction(_ sender: Any) {
       // setOrientationMode()
        leaveChannel()
    }
    
    @IBAction func sendTapped(_ sender: UIButton) {
        print("Send button tapped")
        sendMessage?(messageTextView.text ?? "")
        messageTextView.text = nil
        setSendButtonState(message: false)
        messageTextViewHeightConstraint.constant = 35
    }
    // MARK: Methods to handle keyboard height
    override func keyboardDisplayedWithHeight(value: CGRect) {
        let verticalSafeAreaInset : CGFloat = 0.0
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, animations: {
            self.messageViewBottomConstraint.constant = (value.height+verticalSafeAreaInset)
            self.chatContainerBottomConstraint.constant = value.height+verticalSafeAreaInset + 20
        })
    }
    
    override func keyboardHide(height: CGFloat) {
        self.messageViewBottomConstraint.constant = 20
    self.chatContainerBottomConstraint.constant = 40
        voidCallBack?()
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == tap {
            self.view.endEditing(true)
        }
        return true
    }
    
    private func setSendButtonState(message:Bool) {
        sendButton.isEnabled = message
        sendButton.backgroundColor = message ? UIColor.appThemeColor : UIColor.gray
    }
}
// MARK: Agora Delegate Methods
extension StreamAudienceVC: AgoraRtcEngineDelegate {
    func rtcEngineVideoDidStop(_ engine: AgoraRtcEngineKit) {
        print("Agora Engine Video Stopped")
    }
    
    /// Called when we get a new video feed from a remote user
    /// - Parameters:
    ///   - engine: Agora Engine.
    ///   - uid: ID of the remote user.
    ///   - size: Size of the video feed.
    ///   - elapsed: Time elapsed (ms) from the remote user sharing their video until this callback fired.
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid: UInt, size: CGSize, elapsed: Int) {
        if !isConnectedToStreaming {
            self.view.alpha = 1
           // let hostingView = UIView()
            isConnectedToStreaming = true
            self.loaderView.isHidden = true
           liveLabel.isHidden = false
           liveLabel.alpha = 1
           liveLabel.blink()
         //  hostingView.translatesAutoresizingMaskIntoConstraints = false
           blurrImageView.alpha  = 0
           // hostingView.frame = CGRect(x: 0, y: 0, width: streamView.frame.size.width, height: streamView.frame.size.height)

           //hostingView.backgroundColor = .blue
            let videoCanvas = AgoraRtcVideoCanvas()
            videoCanvas.uid = uid
          //  self.streamView.addSubview(hostingView)
            videoCanvas.view = streamView
            videoCanvas.renderMode = .hidden
            self.agkit.setupRemoteVideo(videoCanvas)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                self.view.alpha = 1
                NotificationCenter.default.post(name: NSNotification.Name.closePopup, object: nil)
            })
        }

    }

    /// Called when the local user role successfully changes
    /// - Parameters:
    ///   - engine: AgoraRtcEngine of this session.
    ///   - oldRole: Previous role of the user.
    ///   - newRole: New role of the user.
    func rtcEngine(
        _ engine: AgoraRtcEngineKit,
        didClientRoleChanged oldRole: AgoraClientRole,
        newRole: AgoraClientRole
    ) {
        //        if newRole == .broadcaster  {
        //            setupLocalAgoraVideo()
        //        }
    }
    
    func rtcEngine(
        _ engine: AgoraRtcEngineKit,
        didJoinedOfUid uid: UInt,
        elapsed: Int
    ) {
//            self.loaderView.isHidden = true
//            liveLabel.isHidden = false
//            liveLabel.alpha = 1
//            liveLabel.blink()
//            hostingView.frame = self.streamView.bounds
//            hostingView.translatesAutoresizingMaskIntoConstraints = false
//            blurrImageView.alpha  = 0
//            hostingView.backgroundColor = .blue
//
//           // let view = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: streamView.frame.size))
//            videoCanvas.view = hostingView
//            videoCanvas.renderMode = .hidden
//            videoCanvas.uid = uid
//            streamView.addSubview(videoCanvas.view ?? UIView())
//            agkit.setupRemoteVideo(videoCanvas)
//           // agkit.enableVideo()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
//                NotificationCenter.default.post(name: NSNotification.Name.closePopup, object: nil)
//            })

         //   self.streamView.addSubview(hostingView)
//            videoCanvas.uid = uid
//            videoCanvas.view = streamView
//            videoCanvas.renderMode = .hidden
//            self.agkit.setupRemoteVideo(videoCanvas)
//            self.agkit.enableVideo()
//            NotificationCenter.default.post(name: NSNotification.Name.closePopup, object: nil)
//
////            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
////                Stream.connect.close(parent: self)
////            })
       // }
    }
    func rtcEngine(
        _ engine: AgoraRtcEngineKit,
        didOfflineOfUid uid: UInt,
        reason: AgoraUserOfflineReason
    ) {
        
        print("User \(reason)")
        if reason == .quit {
            Stream.connect.openPop(.Thankyou, parent: self) {
                self.leaveChannel()
                // self.dismiss(animated: false, completion: nil)
                
            }
        } else if reason == .dropped {
            Stream.connect.openPop(.Disconnected, parent: self) {
                self.leaveChannel()
                //self.dismiss(animated: false, completion: nil)
            }
            
        }
    }
    
    func rtcEngine(
        _ engine: AgoraRtcEngineKit,
        tokenPrivilegeWillExpire token: String
    ) {
        print("Token is about to expire")
    }
}

// MARK: TextView Extension
extension StreamAudienceVC :UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        voidCallBack?()
    }
    func textViewDidChange(_ textView: UITextView) {
        setSendButtonState(message: !textView.text.isBlank)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.messageTextViewHeightConstraint.constant = textView.contentSize.height
        if self.messageTextViewHeightConstraint.constant > 70 {
            self.messageTextViewHeightConstraint.constant = 70
        }
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
}
