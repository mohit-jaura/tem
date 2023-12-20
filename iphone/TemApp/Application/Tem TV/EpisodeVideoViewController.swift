//
//  EpisodeVideoViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 20/01/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Kingfisher
import PDFKit


enum FileType: Int, Codable {
    case image = 1, video, pdf
}

class EpisodeVideoViewController: UIViewController {
    
    // MARK: Prooperty..
    let vc = AVPlayerViewController()
    var  url:String?
    var fileType: FileType?
    var screenFrom: Constant.ScreenFrom = Constant.ScreenFrom.activity
    
    // MARK: IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playerContainerView: UIView!
    @IBOutlet weak var pdfView: UIView!
    @IBOutlet weak var placeholderImageView: UIImageView!
    @IBOutlet weak var pdfContainerView: UIView!
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        OrientationManager.landscapeSupported = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        OrientationManager.landscapeSupported = false
        //The code below will automatically rotate your device's orientation when you exit this ViewController
        let orientationValue = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(orientationValue, forKey: "orientation")
        
    }
    // MARK: IBAction...
    
    @IBAction func backTapped(_ sender: UIButton) {
        //        vc.player?.pause()
        //        playerContainerView.isHidden = true
        //        vc.removeFromParent()
        if screenFrom == .event{
            self.dismiss(animated: true)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    // MARK: Helper functions
    func configureView(){
            imageView.isHidden = true
            playerContainerView.isHidden = false
            pdfContainerView.isHidden = true
            playVideo()
    }
    
    private func setView(){
        let url = URL(string: url ?? "")
        imageView.kf.setImage(with: url, placeholder: UIImage(named: "ImagePlaceHolder"))
        
    }
    
    private func playVideo() {
        
        if let videoURL = URL(string: url ?? "") {
            let player = AVPlayer(url: videoURL)
            vc.player = player
            addChild(vc)
            // Add Child View as Subview
            playerContainerView.addSubview(vc.view)
            
            // Configure Child View
            vc.view.frame = playerContainerView.bounds
            vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            // Notify Child View Controller
            vc.didMove(toParent: self)
            vc.player?.play()
        }
    }
    
}


