//
//  MessageView.swift
//  TemApp
//
//  Created by Harpreet_kaur on 25/03/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

class MessageView: UIView {

    // MARK: IBOutlets.
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: UIView Functions.
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
}
