//
//  PopUpStreamVC.swift
//  TemApp
//
//  Created by PrabSharan on 16/09/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

enum StreamPopup {
    case Connecting
    case Thankyou
    case Disconnected
    
    var title:String {
        switch self {
        case .Connecting:
            return "Please wait while we are establishing the connection with Host."
        case .Thankyou:
            return "Thank you\nfor connecting with TĒM Host!"
        case .Disconnected:
            return "Host has lost connection. Please wait while we re-establish the connection."
        }
    }
    var image:String {
        switch self {
        case .Connecting:
            return "connecting"
        case .Thankyou:
            return "thanku"
        case .Disconnected:
            return "disconnected"
        }
    }
}

class PopUpStreamVC: UIViewController {
    var streamPopup:StreamPopup = .Disconnected
    
    @IBOutlet weak var gradientView: GradientDashedLineCircularView!
    @IBOutlet weak var bottomButView: UIView!
    @IBOutlet weak var bottombutName: UILabel!
    var close: OnlySuccess?
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var endStreamingOut: UIButton!
    @IBOutlet weak var imgView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        initialise()
    }
    func addPostNoti() {
        NotificationCenter.default.addObserver(self, selector: #selector(closePopUp), name: Notification.Name.closePopup, object: nil)
    }

   @objc func closePopUp() {
        self.dismiss(animated: false)
    }
    func initialise() {
        addPostNoti()
        if streamPopup == .Thankyou {
            endStreamingOut.isHidden = true
        } else {
            endStreamingOut.isHidden = false
        }
        activityIndicator.startAnimating()
        titleLabel.text = streamPopup.title
        imgView.image = UIImage(named: streamPopup.image)
        bottomButView.isHidden  = streamPopup == .Connecting
        activityIndicator.isHidden = streamPopup != .Connecting
        endStreamingOut.cornerRadius = 5
        bottombutName.text = "Exit"
        setGradientView()
    }
    private func setGradientView() {
        bottomButView.cornerRadius = bottomButView.frame.height / 2
        gradientView.configureViewProperties(colors: [UIColor.cyan.withAlphaComponent(1), UIColor.yellow.withAlphaComponent(0.6), UIColor.cyan.withAlphaComponent(1)], gradientLocations: [0.28, 0.30, 0.55])
        gradientView.instanceWidth = 1.5
        gradientView.instanceHeight = 3.0
        gradientView.extraInstanceCount = 1
    }

    @IBAction func pressAction(_ sender: Any) {
        self.dismiss(animated: false) {
            self.close?()
        }
    }
    
    @IBAction func endStreamingAction(_ sender: Any) {
        self.dismiss(animated: false) {
            self.close?()
        }
    }
}
