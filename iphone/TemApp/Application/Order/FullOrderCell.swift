//
//  FullOrderCell.swift
//  TemApp
//
//  Created by PrabSharan on 17/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

enum OrderStatus: Int {
    case ordered = 1
    case packed = 2
    case shipped = 3
    case delivered = 4
    
    var type: String{
        switch self {
        case .ordered:
            return "Ordered"
        case .packed:
            return "Packed"
        case .shipped:
            return "Shipped"
        case .delivered:
            return "Delivered"
        }
    }
}

class FullOrderCell: UITableViewCell {
    
    @IBOutlet weak var backView: SSNeumorphicView! {
        didSet{
            backView.viewDepthType = .outerShadow
            backView.viewNeumorphicMainColor = UIColor(red: 247.0 / 255.0, green: 247.0 / 255.0, blue: 247.0 / 255.0, alpha: 1).cgColor
            backView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
            backView.viewNeumorphicDarkShadowColor = UIColor(red: 163/255, green: 177/255, blue: 198/255, alpha: 0.5).cgColor
            backView.viewNeumorphicCornerRadius = 8
        }
    }
    
    @IBOutlet weak var dateLbl:UILabel!
    @IBOutlet weak var orderStatsLbl:UILabel!
    @IBOutlet weak var priceLbl:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(order:OrderHistory){
        let date = order.date?.toDate(dateFormat: .displayDate)
        dateLbl.text = date?.toString(inFormat: .displayDate) ?? ""
        orderStatsLbl.text = OrderStatus(rawValue: order.status ?? 0)?.type
        priceLbl.text = "\(Constant.CUR_Sign)\(order.totalPrice ?? 0)"
    }
    
}
