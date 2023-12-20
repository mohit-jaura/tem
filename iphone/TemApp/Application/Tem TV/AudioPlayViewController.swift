//
//  AudioPlayViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 03/05/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//


    import UIKit
    import AVFoundation
    
   class AudioPlayViewController: DIBaseController {
        
        // MARK: Variables
        var audioPlayer = AVAudioPlayer()
        var toggleState = 1
        var remoteUrl = ""
        var previewImage = ""
        var timer: Timer?
        
        // MARK: IBOutlets
        @IBOutlet weak var audioImageView: UIImageView!
        @IBOutlet weak var ButtonPlay: UIButton!
        @IBOutlet weak var labelOverallDuration: UILabel!
        @IBOutlet var slider: UISlider!
        @IBOutlet var labelCurrentTime: UILabel!

        override func viewDidLoad() {
            super.viewDidLoad()
            self.showLoader( color: .black)
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            configureView()
        }
        
        // MARK: Helper functions
        func configureView(){
            self.showLoader( color: .black)
            slider.isUserInteractionEnabled = false
            let url = URL(string: previewImage)
            DispatchQueue.main.async {
                self.audioImageView.kf.setImage(with: url, placeholder: UIImage(named: "ImagePlaceHolder"))
                self.hideLoader()
               
            }
            DispatchQueue.main.async {
                self.musicFromURL(streamURL: self.remoteUrl)
                self.slider.maximumValue = Float(self.audioPlayer.duration)
            }
           
        }
        @objc func updateTime() {
            let timeConverted = Utility.shared.secondsToHoursMinutesSeconds(seconds: Int(audioPlayer.currentTime))
            
            let displayTime = Utility.shared.formattedTimeWithLeadingZeros(hours: timeConverted.hours, minutes: timeConverted.minutes, seconds: timeConverted.seconds)
            labelCurrentTime.text = displayTime
        }
        
        @objc  func updateSlider() {
            slider.value = Float(audioPlayer.currentTime)
        }
        
        func musicFromURL(streamURL: String) {
            guard let fileURL = URL(string:streamURL) else { return  }
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
                try AVAudioSession.sharedInstance().setActive(true)
                let soundData = try Data(contentsOf: fileURL)
                self.audioPlayer = try AVAudioPlayer(data: soundData)
               
             //   DispatchQueue.global().async {
                    self.audioPlayer.prepareToPlay()
            //    }
                let timeConverted = Utility.shared.secondsToHoursMinutesSeconds(seconds: Int(audioPlayer.duration))
                let displayTime = Utility.shared.formattedTimeWithLeadingZeros(hours: timeConverted.hours, minutes: timeConverted.minutes, seconds: timeConverted.seconds)
                labelOverallDuration.text = displayTime
            } catch {
                print(error)
            }
        }
        
        // MARK: IBActions
        @IBAction func backTapped(_ sender: UIButton) {
            audioPlayer.stop()
            self.navigationController?.popViewController(animated: true)
        }
        
        @IBAction func playAndPAuse(_ sender: UIButton) {
            if toggleState == 1 {
                audioPlayer.play()
                toggleState = 2
                timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
                timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
                sender.setImage(UIImage(named:"VGPlayer_ic_pause"),for:UIControl.State.normal)
            } else {
                audioPlayer.pause()
                timer?.invalidate()
                toggleState = 1
                sender.setImage(UIImage(named:"VGPlayer_ic_play"),for:UIControl.State.normal)
            }
        }
        
    }
