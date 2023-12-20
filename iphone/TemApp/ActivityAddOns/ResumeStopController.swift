//
//  ResumeStopController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 08/08/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

class ResumeStopController: DIBaseController {
    var isOptionalActivity:Bool = false
    var isPlaying:Bool = false
    var pauseResume:BoolCompletion?
    var skip:OnlySuccess?
    var stopActivity:OnlySuccess?
    @IBOutlet weak var widthSkipButOut: NSLayoutConstraint!
    @IBOutlet weak var skipButOut: UIButton!
    @IBOutlet weak var stopButOut: UIButton!
    @IBOutlet weak var resumeButOut: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        initialise()
        
    }
    
    func initialise() {
        widthSkipButOut.constant = isOptionalActivity ? 0 : 0
        playPauseInitialise()
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }
    @IBAction func skipAction(_ sender: Any) {
  
    }
    func playPauseInitialise() {
        let title = isPlaying ? "PAUSE" : "RESUME"
        resumeButOut.setTitle(title, for: .normal)
    }
    
    @IBAction func resumeAction(_ sender: Any) {
        isPlaying = !isPlaying
        playPauseInitialise()
        pauseResume?(isPlaying)
    }
    
    @IBAction func stopAction(_ sender: Any) {
        pauseResume?(false)
        alertOpt("Do you want to stop current activity?", okayTitle: "Yes", cancelTitle: "No", okCall: {
            self.dismiss(animated: true) {
                self.stopActivity?()
            }
        }, cancelCall: {
            self.pauseResume?(self.isPlaying)
        }, parent: self)
        
    }
}
