//
//  ProfileCollectionCell.swift
//  TemApp
//
//  Created by shivani on 08/07/21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
import Kingfisher

protocol ProfileRedirectionDelegate{
    func redirectToProfile()
    func redirectToFindTemates()
}

class ProfileCollectionCell: UICollectionViewCell {
    
    // MARK: Properties
    var rightInset: CGFloat = 7
    var profileRedirectionDelegate:ProfileRedirectionDelegate?
    let neumorphicShadow = NumorphicShadow()
    
    // MARK: Outlets
    @IBOutlet weak var myJourneyLabel: UILabel!
    @IBOutlet weak var labelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelTopConstrbaint: NSLayoutConstraint!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var gradientView: GradientDashedLineCircularView!
    @IBOutlet weak var gradientContainerView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var InnerMostView: SSNeumorphicView!{
        didSet{
            neumorphicShadow.addNeumorphicShadow(view: InnerMostView, shadowType: .outerShadow, cornerRadius: InnerMostView.frame.width/2, shadowRadius: 3, mainColor:  #colorLiteral(red: 0.2457352877, green: 0.5107920766, blue: 0.8709122539, alpha: 1), opacity: 0.5, darkColor: UIColor.white.cgColor, lightColor: #colorLiteral(red: 0.3728501797, green: 0.4557161331, blue: 0.5142025352, alpha: 1), offset: CGSize(width: 2, height :2))
        }
    }
    
    @IBOutlet weak var profilePicInnerView: SSNeumorphicView!{
        didSet{
            neumorphicShadow.addNeumorphicShadow(view: profilePicInnerView, shadowType: .outerShadow, cornerRadius: profilePicInnerView.frame.width/2, shadowRadius: 3, mainColor:  #colorLiteral(red: 0.2457352877, green: 0.5107920766, blue: 0.8709122539, alpha: 1), opacity: 0.2, darkColor: UIColor.black.cgColor, lightColor: #colorLiteral(red: 0.2440355718, green: 0.5068868995, blue: 0.8669529557, alpha: 1), offset: CGSize(width: 3, height: 3))
        }
    }
    
    @IBOutlet weak var userImageOuterShadowView: SSNeumorphicView! {
        didSet {
            neumorphicShadow.addNeumorphicShadow(view: userImageOuterShadowView, shadowType: .outerShadow, cornerRadius: userImageOuterShadowView.frame.width/2, shadowRadius: 3, mainColor:  #colorLiteral(red: 0.2457352877, green: 0.5107920766, blue: 0.8709122539, alpha: 1), opacity: 0.4, darkColor: UIColor.black.cgColor, lightColor: #colorLiteral(red: 0.4096193314, green: 0.9829475284, blue: 0.9586761594, alpha: 1), offset: CGSize(width: 2, height: 2))
        }
    }
    
    @IBOutlet weak var mainView: SSNeumorphicView! {
        didSet{
            neumorphicShadow.addNeumorphicShadow(view: mainView, shadowType: .innerShadow, cornerRadius: 8, shadowRadius: 0.8, mainColor: #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.2431372549, alpha: 1), opacity:  0.5, darkColor:  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.9), lightColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(0.2).cgColor, offset: CGSize(width: 4, height: 4))
        }
    }
    @IBOutlet var findTematesShadowView: SSNeumorphicView! {
        didSet {
            findTematesShadowView.viewDepthType = .outerShadow
            findTematesShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
            findTematesShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
            findTematesShadowView.viewNeumorphicCornerRadius = findTematesShadowView.frame.width/2
            findTematesShadowView.viewNeumorphicShadowRadius = 1.0
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        gradientContainerView.cornerRadius = gradientContainerView.frame.width / 2
        userImageView.cornerRadius = userImageView.frame.width / 2
        setUserInfo()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        labelTrailingConstraint.constant = rightInset - myJourneyLabel.frame.width/2 + myJourneyLabel.frame.height/2
        myJourneyLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        
        let gradient = getGradientLayer(bounds: descriptionTextView.bounds)
        descriptionTextView.textColor = GradientOnText().gradientColor(bounds: descriptionTextView.bounds, gradientLayer: gradient)
        
        descriptionTextView.isEditable = false
        descriptionTextView.isScrollEnabled = true
        
        setGradientView()
//        setUserInfo()
        
    }
    // MARK: IBAction
    @IBAction func userProfileTapped(_ sender: UIButton) {
        profileRedirectionDelegate?.redirectToProfile()
    }
    @IBAction func userPicTapped(_ sender: UIButton) {
        profileRedirectionDelegate?.redirectToProfile()
    }
    @IBAction func findTematesTapped(_ sender: UIButton) {
        profileRedirectionDelegate?.redirectToFindTemates()
    }
    
    // MARK: Helper Function
    
    
    func getGradientLayer(bounds : CGRect) -> CAGradientLayer{
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = [UIColor(red: 0.97, green: 0.71, blue: 0.00, alpha: 1.00).cgColor,UIColor(red: 0.71, green: 0.13, blue: 0.88, alpha: 1.00).cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        return gradient
    }
    private func setGradientView() {
        gradientView.configureViewProperties(colors: [UIColor.cyan.withAlphaComponent(1), UIColor.yellow.withAlphaComponent(0.6), UIColor.cyan.withAlphaComponent(1)], gradientLocations: [0.28, 0.30, 0.55])
        gradientView.instanceWidth = 1.5
        gradientView.instanceHeight = 3.0
        gradientView.extraInstanceCount = 1
    }
    
    func setUserInfo(){
        if  UserManager.getCurrentUser()?.accountabilityMission != ""{
            descriptionTextView.text = UserManager.getCurrentUser()?.accountabilityMission
        }else{
            descriptionTextView.text = """
Own
Your
Journey.
"""
        }
        userName.text = UserManager.getCurrentUser()?.userName
        firstName.text = UserManager.getCurrentUser()?.firstName
        locationLabel.text = UserManager.getCurrentUserAddress()?.formatAddress()
        if let imageUrl = URL(string: UserManager.getCurrentUser()?.profilePicUrl ?? "" ) {
            userImageView.kf.setImage(with: imageUrl, placeholder:#imageLiteral(resourceName: "placeholder"))
        }
        else{
            userImageView.image = #imageLiteral(resourceName: "placeholder")
        }
    }
}

