//
//  TaggedUserView.swift
//  TemApp
//
//  Created by shilpa on 24/12/19.
//

import UIKit
protocol TaggedUserViewDelegate: AnyObject {
    func didTapOnCrossOnTaggedView(sender: UIButton)
    func didTapOnNameView(sender: UIButton)
}
extension TaggedUserViewDelegate {
    func didTapOnCrossOnTaggedView(sender: UIButton) {}
}

class TaggedUserView: UIView {

    // MARK: Properties
    weak var delegate: TaggedUserViewDelegate?
    var lastLocation = CGPoint(x: 0, y: 0)
    var taggedUserId = ""
    
    // MARK: IBOutlets
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var crossButton: UIButton!
    @IBOutlet weak var nameViewButton: UIButton!
    
    // MARK: IBActions
    @IBAction func nameViewTapped(_ sender: UIButton) {
        self.delegate?.didTapOnNameView(sender: sender)
    }
    @IBAction func crossTapped(_ sender: UIButton) {
        self.delegate?.didTapOnCrossOnTaggedView(sender: sender)
    }
    
    // MARK: Initializer
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.addGestures()
    }
    
    static func loadNib(frame: CGRect) -> TaggedUserView? {
        if let nib = TaggedUserView.loadNib() as? TaggedUserView {
            return nib
        }
        return nil
    }
    
    // MARK: Add gestures
    func addGestures() {
        nameView.isUserInteractionEnabled = true
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panDetected(recognizer:)))
        self.nameView.addGestureRecognizer(panGesture)
    }
    
    @objc func panDetected(recognizer: UIPanGestureRecognizer) {
        let translation  = recognizer.translation(in: self.superview?.superview)
        self.center = CGPoint(x: lastLocation.x + translation.x, y: lastLocation.y + translation.y)
        
        if recognizer.state == .ended {
            print("pan end")
            //self.delegate?.updateTagPoint(newPoint: lastLocation)
        }
    }
  
}
