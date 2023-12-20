//
//  VideoChatViewController.swift
//  Agora iOS Tutorial
//
//  Created by James Fang on 7/14/16.
//  Copyright © 2016 Agora.io. All rights reserved.
//

import UIKit
import AgoraRtcKit

class VideoChatViewController: DIBaseController {
    @IBOutlet weak var localContainer: UIView!
    @IBOutlet weak var remoteContainer: UIView!
    @IBOutlet weak var remoteVideoMutedIndicator: UIImageView!
    @IBOutlet weak var localVideoMutedIndicator: UIView!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    
    var streamModal:StreamModal?
    
    //    var agoraKit: AgoraRtcEngineKit!
    //=======
    weak var logVC: LogViewController?
    
    var agoraKit: AgoraRtcEngineKit!
    var localVideo: AgoraRtcVideoCanvas?
    var remoteVideo: AgoraRtcVideoCanvas?
    let userRole: AgoraClientRole = .broadcaster

    var token: String?
    var channelId:String?
    var uId:UInt?
    
    var isRemoteVideoRender: Bool = true {
        didSet {
            if let it = localVideo, let view = it.view {
                if view.superview == localContainer {
                    remoteVideoMutedIndicator.isHidden = isRemoteVideoRender
                    remoteContainer.isHidden = !isRemoteVideoRender
                } else if view.superview == remoteContainer {
                    localVideoMutedIndicator.isHidden = isRemoteVideoRender
                }
            }
        }
    }
    
    var isLocalVideoRender: Bool = false {
        didSet {
            if let it = localVideo, let view = it.view {
                if view.superview == localContainer {
                    localVideoMutedIndicator.isHidden = isLocalVideoRender
                } else if view.superview == remoteContainer {
                    remoteVideoMutedIndicator.isHidden = isLocalVideoRender
                }
            }
        }
    }
    
    var isStartCalling: Bool = true {
        didSet {
            if isStartCalling {
                micButton.isSelected = false
            }
            micButton.isHidden = !isStartCalling
            cameraButton.isHidden = !isStartCalling
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialise()
        
    }
    func removeHeaderAppearAgain() {
        Stream.connect.resetAllBanners()
        Stream.connect.addDetailsToDefaults(streamModal?.channel_id, streamModal?.affiliate_id)
    }
    
    func initialise() {
      //  self.view.alpha = 0
        initialiseModal()
        removeHeaderAppearAgain()
        setupVideo()
        setupLocalVideo()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
            Stream.connect.openPop(.Connecting, parent: self) {
                self.dismiss(animated: false, completion: nil)
            }
        })
    }
    func initialiseModal() {
        if let token = streamModal?.token,let name = streamModal?.channel_id, let uID = streamModal?.uid {
            self.token = token
            self.channelId = name
            self.uId = UInt(uID)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.dismiss(animated: true) {
                    self.alertOpt("Error Connecting", okayTitle: "Exit", okCall: {
                        self.dismiss(animated: true)
                    }, parent: self)
                }
            })
        }
    }
    func setupVideo() {

        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: StreamHelper.appId, delegate: self)
        //agoraKit.setClientRole(userRole)
        agoraKit.enableVideo()
        agoraKit.setVideoEncoderConfiguration(AgoraVideoEncoderConfiguration(size: AgoraVideoDimension640x360,
                                                                             frameRate: .fps30,
                                                                             bitrate: AgoraVideoBitrateStandard,
                                                                             orientationMode: .adaptative))

        self.joinChannel()
    }
    
    func setupLocalVideo() {
        let view = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: localContainer.frame.size))
        localVideo = AgoraRtcVideoCanvas()
        localVideo?.view = view
        localVideo?.renderMode = .hidden
        localVideo?.uid = uId ?? 0
        localContainer.addSubview(localVideo?.view ?? UIView())
        agoraKit.setupLocalVideo(localVideo)
        agoraKit.startPreview()
    }

    
    func joinChannel() {
        
        agoraKit.joinChannel(byToken: token, channelId: channelId ?? "", info: nil, uid: uId ?? 0) { [unowned self] (_, _, _) -> Void in
            // Did join channel "demoChannel1"
            self.isLocalVideoRender = true
        }
        isStartCalling = true
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func leaveChannel() {
        // leave channel and end chat
        agoraKit.leaveChannel(nil)
        isRemoteVideoRender = false
        isLocalVideoRender = false
        isStartCalling = false
        UIApplication.shared.isIdleTimerDisabled = false
        Stream.connect.openPop(.Thankyou, parent: self) {
            self.dismiss(animated: false, completion: nil)
            
        }
    }
    
    @IBAction func didClickHangUpButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected {
            leaveChannel()
            _ =  removeFromParent(localVideo)
            localVideo = nil
            _ =   removeFromParent(remoteVideo)
            remoteVideo = nil
            
        }
        Stream.connect.openPop(.Thankyou, parent: self) {
            self.dismiss(animated: false, completion: nil)
            
        }
    }
    
    @IBAction func didClickMuteButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        // mute local audio
        agoraKit.muteLocalAudioStream(sender.isSelected)
    }
    
    @IBAction func didClickSwitchCameraButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        agoraKit.switchCamera()
    }
    
    @IBAction func didClickLocalContainer(_ sender: Any) {
        switchView(localVideo)
        switchView(remoteVideo)
    }
    
    func removeFromParent(_ canvas: AgoraRtcVideoCanvas?) -> UIView? {
        if let it = canvas, let view = it.view {
            let parent = view.superview
            if parent != nil {
                view.removeFromSuperview()
                return parent
            }
        }
        return nil
    }
    
    func switchView(_ canvas: AgoraRtcVideoCanvas?) {
        let parent = removeFromParent(canvas)
        if parent == localContainer {
            canvas?.view?.frame.size = remoteContainer.frame.size
            remoteContainer.addSubview(canvas?.view ?? UIView())
        } else if parent == remoteContainer {
            canvas?.view?.frame.size = localContainer.frame.size
            localContainer.addSubview(canvas?.view ?? UIView())
        }
    }
}

extension VideoChatViewController: AgoraRtcEngineDelegate {
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        isRemoteVideoRender = true
        //self.view.alpha = 1
        var parent: UIView = remoteContainer
        if let it = localVideo, let view = it.view {
            if view.superview == parent {
                parent = localContainer
            }
        }
        if remoteVideo != nil {
            return
        }
        let mainView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: parent.frame.size))
        remoteVideo = AgoraRtcVideoCanvas()
        remoteVideo?.view = mainView
        remoteVideo?.renderMode = .hidden
        remoteVideo?.uid = uid
        parent.addSubview(remoteVideo?.view ?? UIView())
        agoraKit.setupRemoteVideo(remoteVideo ??  AgoraRtcVideoCanvas())
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3, execute: {
            self.dismiss(animated: false, completion: nil)
        })
    }
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid:UInt, reason:AgoraUserOfflineReason) {
        isRemoteVideoRender = false
        if let it = remoteVideo, it.uid == uid {
            removeFromParent(it)
            remoteVideo = nil
        }
        print("User \(reason)")
        if reason == .quit {
            Stream.connect.openPop(.Thankyou, parent: self) {
                self.dismiss(animated: false, completion: nil)
                
            }
        } else if reason == .dropped {
            Stream.connect.openPop(.Disconnected, parent: self) {
                self.dismiss(animated: false, completion: nil)
            }
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.leaveChannel()
        }
    }
    func rtcEngine(_ engine: AgoraRtcEngineKit, didVideoMuted muted:Bool, byUid:UInt) {
        isRemoteVideoRender = !muted
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurWarning warningCode: AgoraWarningCode) {
        print( "did occur warning, code: \(warningCode.rawValue)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        print( "did occur error, code: \(errorCode.rawValue)")
        
    }
    func rtcEngine(_ engine: AgoraRtcEngineKit, didLeaveChannelWith stats: AgoraChannelStats) {
        print("left ......")
    }
    
}

