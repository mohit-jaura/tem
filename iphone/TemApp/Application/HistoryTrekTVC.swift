//
//  HistoryTrekTVC.swift
//  TemApp
//
//  Created by Developer on 03/03/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class HistoryTrekTVC: UITableViewCell {

    @IBOutlet weak var dateLbl:UILabel!
    @IBOutlet weak var trekValueLbl:UILabel!
    @IBOutlet weak var shadowView: SSNeumorphicView! {
        didSet{
            shadowView.viewDepthType = .outerShadow
            shadowView.viewNeumorphicCornerRadius = 19.5
            shadowView.viewNeumorphicMainColor =   #colorLiteral(red: 0.2431372702, green: 0.2431372702, blue: 0.2431372702, alpha: 1).cgColor

            shadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.1).cgColor
            shadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    var initializeCell:FoodTrekModel?{
        didSet {
            guard let timeStamp = initializeCell?.date else{
                return
            }
            let sDate = String(describing: timeStamp)
            var date = Date()
            if sDate.count == 10 {
                date = timeStamp.toDate
            }
            else if sDate.count == 13 {
                date = timeStamp.timestampInMillisecondsToDate
            }
            guard let displayDate = date.toString(inFormat: .displayDate) else{
                return
            }
            let trekValue = initializeCell?.on_treak ?? ""
            dateLbl.text = "\(displayDate)"
            let updatedTrek = Double(trekValue)
            trekValueLbl.text = "\(Int(updatedTrek ?? 0))%"
        }
        
    }
    
    
    
}
