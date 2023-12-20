//
//  ManageCardsTableViewCell.swift
//  TemApp
//
//  Created by Mohit Soni on 23/05/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

protocol ManageCardsTableViewCellDelegate: AnyObject {
    func removeCard(index:Int)
}
class ManageCardsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cardNameLbl:UILabel!
    @IBOutlet weak var cardNumberLbl:UILabel!
    @IBOutlet weak var toggleImage:UIImageView!{
        didSet{
            toggleImage.cornerRadius = toggleImage.frame.height / 2
        }
    }
    @IBOutlet weak var bgView:SSNeumorphicView!{
        didSet{
            self.createShadowView(view: bgView, shadowType: .outerShadow, cornerRadius: 8, shadowRadius: 8)
        }
    }
    @IBOutlet weak var toggleView:SSNeumorphicView!{
        didSet{
            self.createShadowView(view: toggleView, shadowType: .innerShadow, cornerRadius: toggleView.frame.height / 2, shadowRadius: 3)
        }
    }
    @IBOutlet weak var removeButton:UIButton!
    
    var delegate:ManageCardsTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func removeCardTapped(_ sender:UIButton){
        self.delegate?.removeCard(index: sender.tag)
    }
    
    func setData(card:CardDetails?,index:Int,cardsCount:Int){
        guard let card = card else { return }
        removeButton.tag = index
        cardNameLbl.text = card.name ?? ""
        cardNumberLbl.text = " XXX XXXX XXXX \(card.number ?? "")"
        if card.isPrimary == 1 {
            toggleImage.image = UIImage(named: "Oval Copy 3")
        }else{
            toggleImage.image = UIImage(named: "")
        }
        if cardsCount > 1{
            removeButton.isHidden = false
        }else{
            removeButton.isHidden = true
        }
    }
    
    func createShadowView(view: SSNeumorphicView, shadowType: ShadowLayerType, cornerRadius:CGFloat,shadowRadius:CGFloat){
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor =  UIColor(red: 247.0 / 255.0, green: 247.0 / 255.0, blue: 247.0 / 255.0, alpha: 1).cgColor
        view.viewNeumorphicLightShadowColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.62).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor(red: 163.0 / 255.0, green: 177.0 / 255.0, blue: 198.0 / 255.0, alpha: 0.72).cgColor
        view.viewNeumorphicCornerRadius = cornerRadius
        view.viewNeumorphicShadowRadius = shadowRadius
        view.viewNeumorphicShadowOffset = CGSize(width: 2, height: 2 )
    }
    
    private func encryptCardNumber(_ cardNumber:String) -> String{
        var encryptedNumber = cardNumber
        let startPoint = encryptedNumber.index(encryptedNumber.startIndex,offsetBy: 4)
        let endPoint = encryptedNumber.index(encryptedNumber.endIndex,offsetBy: -6)
        let firstStar = encryptedNumber.index(after: startPoint)
        let lastStar = encryptedNumber.index(after: endPoint)
        encryptedNumber.replaceSubrange(firstStar...lastStar,with: " **** **** ")
        return encryptedNumber
    }
}
