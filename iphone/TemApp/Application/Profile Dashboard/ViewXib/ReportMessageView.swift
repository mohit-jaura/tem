//
//  ReportMessageView.swift
//  TemApp
//
//  Created by Harpreet_kaur on 02/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
protocol ReportMessageViewDelegate {
    func getReportMessage(decription:String,index:Int)
}

class ReportMessageView: UIView {

    // MARK: IBOutlets.
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var dimView: UIView!
    var delegate:ReportMessageViewDelegate?
    var index:Int?
    
    
    // MARK: IBActions.
    @IBAction func submitButtonAction(_ sender: UIButton) {
        if messageTextView.text.isBlank {
            Utility.showPopupOnTopViewController(withTitle: "", message: "Please write first what is in your mind")
            return
        }
        delegate?.getReportMessage(decription: messageTextView.text.trim,index:self.index ?? 0)
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0.0
            
        }) { (true) in
            self.removeXib()
        }
    }
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0.0
        }) { (true) in
            self.removeXib()
        }
    }
    
    // MARK: Function to remove Xib from its superview.
    func removeXib() {
        UIView.animate(withDuration: 0.2, animations: {
            self.removeFromSuperview()
        }) { (true) in
        }
    }
}
