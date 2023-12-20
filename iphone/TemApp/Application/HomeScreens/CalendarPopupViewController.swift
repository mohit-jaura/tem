//
//  CalendarPopupViewController.swift
//  TemApp
//
//  Created by shivani on 16/07/21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class CalendarPopupViewController: UIViewController {
    
    // MARK: Properties
    var contentText: String = ""
    private let viewBackgroundColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.59)
    
    // MARK: IBOutlet
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet weak var shadowView: SSNeumorphicView!{
        didSet{
            shadowView.viewDepthType = .innerShadow
            shadowView.viewNeumorphicMainColor = viewBackgroundColor.cgColor
            self.shadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
            self.shadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(1).cgColor
            shadowView.viewNeumorphicCornerRadius = 9
            shadowView.viewNeumorphicShadowRadius = 3
            shadowView.borderWidth = 0
//             shadowView.viewNeumorphicShadowOpacity = 0.5
        }
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = viewBackgroundColor
//        self.view.backgroundColor = UIColor.clear//UIColor.black.withAlphaComponent(0.4)
        self.setContent()
    }
    
    // MARK: IBActions
     @IBAction func crossButtonTapped(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }

    private func setContent() {
        self.contentLabel.text = contentText
    }
}
