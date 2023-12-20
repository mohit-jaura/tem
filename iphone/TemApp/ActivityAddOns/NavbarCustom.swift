//
//  NavbarCustom.swift
//  TemApp
//
//  Created by PrabSharan on 22/07/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
class NavbarCustom: UIView {
    
    @IBOutlet weak var addNewButOut: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var containerView: UIView!
    var createAction:OnlySuccess?
    @IBOutlet weak var shadowView: SSNeumorphicView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    func configureView() {
         Bundle.main.loadNibNamed("NavbarCustom", owner: self, options: nil)
        containerView.frame = self.frame
        self.addSubview(containerView)
        
    }
   
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    @IBAction func addNew(_ sender: Any) {
        createAction?()
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        NavigTO.navigateTo?.navigation?.popViewController(animated: true)
    }
}


