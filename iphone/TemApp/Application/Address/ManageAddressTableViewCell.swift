//
//  ManageAddressTableViewCell.swift
//  TemApp
//
//  Created by Mohit Soni on 15/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

protocol ManageAddressTableViewCellDelegate{
    func editTapped(index:Int)
}

class ManageAddressTableViewCell: UITableViewCell {

    @IBOutlet weak var addressLbl:UILabel!
    @IBOutlet weak var addressCountLbl:UILabel!
    @IBOutlet weak var shadowView:SSNeumorphicView!{
        didSet{
            shadowView.viewNeumorphicCornerRadius = 8
            shadowView.viewDepthType = .outerShadow
            shadowView.viewNeumorphicMainColor = #colorLiteral(red: 0.9686275125, green: 0.9686275125, blue: 0.9686275125, alpha: 1)
            shadowView.viewNeumorphicShadowOpacity = 0.8
            shadowView.viewNeumorphicDarkShadowColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
            shadowView.viewNeumorphicShadowOffset = CGSize(width: -2, height: -2)
            shadowView.viewNeumorphicLightShadowColor = #colorLiteral(red: 0.8010598938, green: 0.8089911799, blue: 0.8089911799, alpha: 1)
        }
    }
    @IBOutlet weak var editBtn:UIButton!
    var delegate:ManageAddressTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func editTapped(_ sender:UIButton){
        self.delegate?.editTapped(index: sender.tag)
    }
    
    func setData(address:SavedAddresses,index:Int){
        self.addressLbl.text = address.formattedAdress ?? ""
        self.addressCountLbl.text = "Address \(index + 1)"
        self.editBtn.tag = index
    }

}
