//  NoDataFound.swift
//  Created by PrabSharan on 20/11/20.
//  Copyright © 2020 Gurpreet Singh. All rights reserved.

import UIKit

extension DIBaseController {
    func noDataFound(_ selfView:UIView, _ title:String? = "Nothing here",_ tapped:OnlySuccess? = nil) ->  UIView?{
        
            if let noDataFound = Bundle.main.loadNibNamed("NoDataFound", owner: self, options: nil)?.first as? NoDataFound {
            noDataFound.titleGet = title
                noDataFound.frame = CGRect(x: 0, y: 0, width: selfView.frame.width, height: selfView.frame.height)
                noDataFound.tapped = tapped

           return noDataFound
        }
        return nil

        }
}
class NoDataFound: UIView {
    var titleGet:String? = "Nothing there"
    var tapped:OnlySuccess?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var plusButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

    }
    @IBAction func addButton(_ sender:UIButton) {
        tapped?()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.text = titleGet
        
    }
    
}
