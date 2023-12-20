//
//  CustomAlert.swift
//  CustomActionSheet
//
//  Created by Narinder Singh on 30/03/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit
import SSNeumorphicView

protocol CustomBottomSheetDelegate {
    func customSheet(actionForItem action: UserActions)
}

open class CustomBottomSheet: UIView {
    
    
    var delegate: CustomBottomSheetDelegate?
    
    /// Background view
    private var dimView:UIView!
    
    
    /// ActionSheet Image
    private var ivLogo:UIImageView!
    
    
    /// Main bottom container view
    private var containerView:UIView!
    /// Actions view
    private var actionView: UIView!
    
    
    private var spacerView: UIView!
    
    
    /// Number of actions like: ["Report","Block","Cancel"]
    var actionTitle:[UserActions]!
    var section:Int?
    
    /// Colors for each item in order: [.black,.black,.gray,.red]
    open var colors:[UIColor]!
    
    ///Height for each action button
    open var buttonHeight:CGFloat = 78.0
    
    /// custom titles for each item, if any. Must be equal to the number of items in actionTitle Array
    open var customTitles: [String]?
    
    
    /// Animation duration to slide the bottom view
    open var animationDuration:Double = 0.6
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// To dismiss the action sheet popup
    open func dismissSheet() {
        dimView.fadeOut()
        containerView.slideOut(to: .bottom, x: 0, y: self.frame.maxY, duration: animationDuration, delay: 0) { (_) in
            self.delegate = nil
            self.removeFromSuperview()
        }
    }
    
    
    /// call one time to create and set basic layout for popup view
    open func setupViewElements(){
        
        //Adding Dim view for light black background
        dimView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        dimView.backgroundColor = .black
        dimView.alpha = 0.4
        self.addSubview(dimView)
        setupActionSheet()
        spacerView.roundedButton()
    }
    
    
    /// create action buttons and adjust the frame for buttons and logo
    private func setupActionSheet(){
        
        // check if titles are not nil, as atleat one action is required
        if actionTitle == nil {
            fatalError("action are required: atleast one action is required")
        }
        
        // Getting height for action view
        let containerHeight = (CGFloat(actionTitle.count) * buttonHeight) + (CGFloat(actionTitle.count) * 25)
        
        // assign main container frame size
        containerView = UIView(frame: CGRect(x: 0, y: self.frame.height - containerHeight + 30, width: self.frame.width, height: containerHeight))
        containerView.backgroundColor = UIColor.appThemeDarkGrayColor
        containerView.cornerRadius = 40
        containerView.center.x = self.center.x
        
        actionView = UIView()
        actionView.frame = CGRect(x: 0, y: buttonHeight, width: self.frame.width, height: containerHeight - buttonHeight)
        actionView.backgroundColor = .clear

        spacerView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: buttonHeight))
        spacerView.backgroundColor = .clear
        
        // Creating and Adding action in actionview
        for (index, action) in actionTitle.enumerated() {
            let button = UIButton()
            button.frame = CGRect(x: 0.0, y: (CGFloat(index) * buttonHeight) + (CGFloat(index) * 20.0), width: actionView.frame.width - 50, height: buttonHeight)
            // if there is value in customTitles array, then set the value at index, otherwise set the defined action title
            if let customTitles = self.customTitles {
                button.setTitle(customTitles[index].uppercased(), for: .normal)
            } else {
                button.setTitle(action.title.uppercased(), for: .normal)
            }
            button.backgroundColor = .clear
            button.center.x = actionView.center.x
            if action != .cancel {
                // create shadow view buttons
                if let font = UIFont(name:"AvenirNext-Medium", size: 32.0) {
                    button.titleLabel?.font = font
                    button.backgroundColor = UIColor.appCyanColor
                    button.cornerRadius = buttonHeight / 2
                    button.setTitleColor(.black, for: .normal)
                    actionView.addSubview(button)
                }
            }else{
                // create cancel "cross" button
                button.frame = CGRect(x: spacerView.frame.maxX - spacerView.frame.height, y: 0, width: spacerView.frame.height, height: spacerView.frame.height)
                button.setImage(UIImage(named: "newBackButtonArrow"), for: .normal)
                button.setTitle("", for: .normal)
                button.center.y = spacerView.center.y
                spacerView.addSubview(button)
            }
            button.tag = index
            button.addTarget(self, action: #selector(buttinAction(button:)), for: .touchUpInside)
        }
        
        containerView.addSubview(actionView)
        containerView.addSubview(spacerView)
        self.addSubview(containerView)
        //Animate view
        presentSheet(containerHeight: containerHeight)
    }
    
    @objc private func buttinAction(button:UIButton)  {
        
        delegate?.customSheet(actionForItem:self.actionTitle[button.tag])
    }
    
    func presentSheet(containerHeight:CGFloat){
        containerView.bounceIn(from: .bottom, x: 0, y:  self.frame.height-containerHeight-50, duration: animationDuration, delay: 0.001) { (_) in
        }
    }
}
