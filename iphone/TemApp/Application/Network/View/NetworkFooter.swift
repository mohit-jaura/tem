//
//  NetworkFooter.swift
//  VIZU
//
//  Created by dhiraj on 14/11/18.
//  Copyright © 2018 Capovela LLC. All rights reserved.
//

import UIKit

protocol NetworkFooterDelegate: AnyObject {
    func showMoreTapped(section:Int)
}

class NetworkFooter: UITableViewCell {

    @IBOutlet weak var btnShowMore: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    weak var delegate:NetworkFooterDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.roundCorners([.bottomLeft, .bottomRight], radius: 10.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureSection(hasDataLoaded:Bool,shouldShowMore:Bool) {
        
        if hasDataLoaded {
            self.activityIndicator.isHidden = true
            self.btnShowMore.isHidden = false

        } else {
            self.activityIndicator.isHidden = false
            self.btnShowMore.isHidden = true
        }
        
    }
    
    @IBAction func actionShowMore(_ sender: Any) {
        let button:UIButton = sender as! UIButton
        self.delegate?.showMoreTapped(section: button.tag )
    }
}
