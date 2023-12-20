//
//  HAISRotatingView.swift
//  TemApp
//
//  Created by shilpa on 30/03/20.
//

import UIKit

class HAISRotatingView: UIView {

    // MARK: Properties
    var isHAISViewVisible: Bool = false
    
    // MARK: IBOutlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var rotatingView: UIView!
    @IBOutlet weak var haisValueLabel: UILabel!
    @IBOutlet weak var haisTextLabel: UILabel!
    
    // MARK: IBActions
    @IBAction func viewTapped(_ sender: UIButton) {
        self.rotateViewOnAxis()
    }
    
    // MARK: Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        intialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        intialize()
    }
    
    private func intialize() {
        Bundle.main.loadNibNamed("HAISRotatingView", owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame.size = self.frame.size
        contentView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
    }
    
    // MARK: Helper functions
    func initializeDefaultViewLayout() {
        self.backgroundImage.image = #imageLiteral(resourceName: "Group235")
        self.backgroundImage.contentMode = .scaleAspectFit
    }
    
    func setScore(value: Double) {
        DispatchQueue.main.async {
            if value == 0 {
                self.haisValueLabel.text = "0"
            } else {
                self.haisValueLabel.text = "\(value.rounded(toPlaces: 2))"
            }
        }
    }
    
    private func rotateViewOnAxis() {
        UIView.transition(with: self.contentView, duration: 1.0, options: [.transitionFlipFromLeft], animations: {
            self.backgroundImage.image = !self.isHAISViewVisible ? #imageLiteral(resourceName: "pix2") : #imageLiteral(resourceName: "Group235")
            self.haisValueLabel.isHidden = self.isHAISViewVisible ? true: false
            self.haisTextLabel.isHidden = self.isHAISViewVisible ? true: false
        }) { (_) in
            self.isHAISViewVisible.toggle()
            if self.isHAISViewVisible {
                self.backgroundImage.shadowRadius = 10.0
            } else {
                self.backgroundImage.shadowRadius = 0.0
                self.backgroundImage.layer.shadowOpacity = 0
            }
        }
    }
}
