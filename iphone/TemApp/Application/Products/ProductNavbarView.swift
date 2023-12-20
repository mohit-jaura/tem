//
//  ProductNavbarView.swift
//  TemApp
//
//  Created by debut_mac on 14/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

enum ActionType{
    case backAction
    case cartAction
    case menuAction
}

protocol ActionsDelegate{
    func navBarButtonsTapped(actionType:ActionType)
}

class ProductNavbarView: UIView {

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var containerView: UIView!

    @IBOutlet weak var cartMenuStackView: UIStackView!
    
    @IBOutlet weak var LineShadowView: SSNeumorphicView!{
        didSet{
            LineShadowView.viewDepthType = .innerShadow
            LineShadowView.viewNeumorphicMainColor = LineShadowView.backgroundColor?.cgColor
            LineShadowView.viewNeumorphicLightShadowColor = UIColor.clear.cgColor
            LineShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.8).cgColor
            LineShadowView.viewNeumorphicCornerRadius = 0
        }
    }
    
    var actionDelegate: ActionsDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    func configureView() {
         Bundle.main.loadNibNamed("ProductNavbarView", owner: self, options: nil)
        containerView.frame = self.frame
        self.addSubview(containerView)
        initiliseUI()
        cartNotification()
        cartUpdate()
        
    }
    func cartNotification() {
        NotificationCenter.default.addObserver(self,selector: #selector(self.cartUpdate),name: NSNotification.Name(rawValue:Constant.NotiName.cartUpdate),object: nil)
    }
    
    @objc func cartUpdate() {
        let count = Cart.getCartCount()
        numberLabel.text = "\(count)"
        numberLabel.isHidden = count == 0
        numberLabel.animateTapEffect()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        initiliseUI()
        
    }
    func initiliseUI() {
        numberLabel.layer.cornerRadius = numberLabel.frame.height / 2
        numberLabel.layer.masksToBounds = true
        
    }
    @IBAction func menuAction(_ sender: Any) {
        actionDelegate?.navBarButtonsTapped(actionType: .menuAction)
        
       
    }
    @IBAction func cartAction(_ sender: Any) {
        actionDelegate?.navBarButtonsTapped(actionType: .cartAction)
        
    }
    @IBAction func backButtonAction(_ sender: Any) {
        actionDelegate?.navBarButtonsTapped(actionType: .backAction)
        
        
    }
}
