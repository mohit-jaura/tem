//
//  LiveStreamStatusBarView.swift
//  TemApp
//
//  Created by PrabSharan on 16/11/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
class LiveStreamStatusBarView: UIView {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var containerView: UIView!
    var streamModal: StreamModal?
    var closeTapped: ((StreamModal?) -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder:coder)
    }

    @IBAction func buttonAction(_ sender: Any) {
        closeTapped?(streamModal)
    }
}
