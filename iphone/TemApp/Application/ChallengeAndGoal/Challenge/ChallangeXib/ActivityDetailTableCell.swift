//
//  ActivityDetailTableCell.swift
//  TemApp
//
//  Created by Mohit Soni on 25/03/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

protocol ShowTemmatesDelegate{
    func showTemmatesList()
}

protocol ActivityDetailTableCellDelegate{
    func donateButtonTapped()
}
class ActivityDetailTableCell: UITableViewCell {

    @IBOutlet weak var honeyCombImageView:UIImageView!{
        didSet{
            setImageShape()
        }
    }
    
    @IBOutlet weak var honeyCombShapeView:UIView!
    
    @IBOutlet weak var activityNameShadowView:SSNeumorphicView!{
        didSet{
            activityNameShadowView.setOuterDarkShadow()
            activityNameShadowView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
        }
    }
    
    @IBOutlet weak var tematesShadowView:SSNeumorphicView!{
        didSet{
            tematesShadowView.setOuterDarkShadow()
            tematesShadowView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
        }
    }
    
    @IBOutlet weak var donateShadowView:SSNeumorphicView!{
        didSet{
            donateShadowView.setOuterDarkShadow()
            donateShadowView.viewNeumorphicMainColor = UIColor(red: 3.0 / 255.0, green: 246.0 / 255.0, blue: 240.0 / 255.0, alpha: 0.92).cgColor
        }
    }
    
    @IBOutlet weak var activityNameLbl:UILabel!
    
    @IBOutlet weak var tematesLbl:UILabel!
    
    @IBOutlet weak var durationLbl:UILabel!
    
    @IBOutlet weak var donateButton:UIButton!
    
    var delegate:ActivityDetailTableCellDelegate?
    var temmatesDelegate: ShowTemmatesDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func tematesTapped(_ sender: UIButton) {
        temmatesDelegate?.showTemmatesList()
    }
    
    @IBAction func donateButtonTapped(_ sender:UIButton){
        self.delegate?.donateButtonTapped()
    }
    func initializCell(challenge:GroupActivity){
        activityNameLbl.text = challenge.name ?? "G/C NAME"
        tematesLbl.text = "\(challenge.membersCount ?? 0)"
        if challenge.fundraising != nil{
            donateButton.isHidden = false
            donateShadowView.isHidden = false
        }else{
            donateButton.isHidden = true
            donateShadowView.isHidden = true
        }
        
        if let imageUrl = challenge.image,
            let url = URL(string: imageUrl) {
            self.honeyCombImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"))
        }else{
            self.honeyCombImageView.image = UIImage(named: "placeholder")
        }

        switch challenge.status{
            case .open:
                durationLbl.text = challenge.remainingTime()
            case .completed:
                self.durationLbl.text = "Expired"
            case .upcoming:
                durationLbl.text = challenge.remainingTime()
            case .none:
                break
        }
    }

    func setImageShape(){
        let path = UIBezierPath(rect: honeyCombImageView.bounds, sides: 6, lineWidth: 5, cornerRadius: 0)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        honeyCombImageView.layer.mask = mask
    }
}
