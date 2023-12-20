//
//  TrekRightTVC.swift
//  TemApp
//
//  Created by Developer on 02/03/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
import AMPopTip


class TrekLeftTVC: UITableViewCell, TaggedUserViewDelegate {
    func didTapOnCrossOnTaggedView(sender: UIButton) {

    }

    func didTapOnNameView(sender: UIButton) {

    }

    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var toprightLbl: UILabel!
    @IBOutlet weak var rightLbl: UILabel!
    @IBOutlet weak var leftLbl: UILabel!
    @IBOutlet weak var leftBottomLbl: UILabel!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var leftPolygon: UIImageView!
    @IBOutlet weak var rightPolygon: UIImageView!
    @IBOutlet weak var lbl: ActiveLabel!
    @IBOutlet weak var lbl1: ActiveLabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var leftLikeButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var rightLikeButton: UIButton!
    @IBOutlet weak var leftTimeLbl: UILabel!
    @IBOutlet weak var rightTimeLbl: UILabel!
    @IBOutlet weak var rightTagButton: CustomButton!
    @IBOutlet weak var leftTagButton: CustomButton!
    @IBOutlet weak var leftLikeButtonShadowView:SSNeumorphicView!{
        didSet{
            self.setViewShadow(view: leftLikeButtonShadowView, shadowType: .outerShadow)
        }
    }
    
    @IBOutlet weak var leftcaptionShadowView:SSNeumorphicView!{
        didSet{
            self.setViewShadow(view: leftcaptionShadowView, shadowType: .outerShadow)
            leftcaptionShadowView.viewNeumorphicCornerRadius = 4
        }
    }
    
    @IBOutlet weak var rightcaptionShadowView:SSNeumorphicView!{
        didSet{
            self.setViewShadow(view: rightcaptionShadowView, shadowType: .outerShadow)
            rightcaptionShadowView.viewNeumorphicCornerRadius = 4
        }
    }
    @IBOutlet weak var leftCommentButtonShadowView:SSNeumorphicView!{
        didSet{
            self.setViewShadow(view: leftCommentButtonShadowView, shadowType: .outerShadow)
        }
    }
    @IBOutlet weak var righttLikeButtonShadowView:SSNeumorphicView!{
        didSet{
            self.setViewShadow(view: righttLikeButtonShadowView, shadowType: .outerShadow)
        }
    }
    @IBOutlet weak var rightCommentButtonShadowView:SSNeumorphicView!{
        didSet{
            self.setViewShadow(view: rightCommentButtonShadowView, shadowType: .outerShadow)
        }
    }
    weak var delegate: PostTableCellDelegate?
    var isLeftTrek: Bool?

    @IBAction func leftTaggedButtonTapped(_ sender: CustomButton) {
        self.delegate?.didTapOnViewTaggedPeople(sender: sender)
    }
    @IBAction func rightTaggedButtonTapped(_ sender: CustomButton) {
        self.delegate?.didTapOnViewTaggedPeople(sender: sender)
    }
    private let arcView = WaterTrackerCurvedLineView()

    private func commonInit() {
        arcView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(arcView)
        leftLbl.isHidden = true
        rightLbl.isHidden = true
        leftBottomLbl.isHidden = true
        toprightLbl.isHidden = true
    }
    func checkForAnyTagInMedia(tagIds:[UserTag], isLeftTrek: Bool){
        self.isLeftTrek = isLeftTrek
        if tagIds.isEmpty {
            leftTagButton.isHidden = true
            rightTagButton.isHidden = true
        } else{
            if isLeftTrek{
                leftTagButton.isHidden = false
            } else{
                rightTagButton.isHidden = false
            }
        }
    }

    func fillData(currentDirection: WaterTrackerDirection, nextDirection: WaterTrackerDirection) {
        arcView.currentLayoutDirection = currentDirection
        arcView.nextLayoutDirection = nextDirection
        NSLayoutConstraint.activate([
            
            // constrain arcView to all 4 sides
            arcView.topAnchor.constraint(equalTo: contentView.topAnchor),
            arcView.leadingAnchor.constraint(equalTo: view1.trailingAnchor),
            arcView.trailingAnchor.constraint(equalTo: view2.leadingAnchor),
            arcView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
        ])
        if currentDirection == .right {
            rightPolygon.isHidden = false
            leftPolygon.isHidden = true
            rightPolygon.layer.zPosition = 1
        } else {
            leftPolygon.isHidden = false
            rightPolygon.isHidden = true
            leftPolygon.layer.zPosition = 1
        }
    }
    
     func setAndDetectTagsInCaption(descriptionLabel: ActiveLabel) {
        descriptionLabel.isUserInteractionEnabled = true
        let customType = ActiveType.custom(pattern: RegEx.mention.rawValue)
        let hashTagCustomType = ActiveType.custom(pattern: RegEx.hashTag.rawValue)
        
        descriptionLabel.numberOfLines = 3
        descriptionLabel.customColor[customType] = UIColor.white
        descriptionLabel.customSelectedColor[customType] = UIColor.white
        descriptionLabel.customColor[hashTagCustomType] = UIColor.white
        descriptionLabel.customSelectedColor[hashTagCustomType] = UIColor.white
        descriptionLabel.enabledTypes = [customType, hashTagCustomType, .url]
        
        descriptionLabel.customize { (label) in
            label.configureLinkAttribute = { (type, attributes, isSelected) in
                var atts = attributes
                switch type {
                    case customType, hashTagCustomType:
                        atts[NSAttributedString.Key.font] = UIFont(name: UIFont.robotoMedium, size: descriptionLabel.font.pointSize)!
                        atts[NSAttributedString.Key.foregroundColor] = UIColor.appThemeColor
                    case .url:
                        atts[NSAttributedString.Key.font] = UIFont(name: UIFont.robotoMedium, size: descriptionLabel.font.pointSize)!
                        atts[NSAttributedString.Key.foregroundColor] = UIColor.appThemeColor
                    default: ()
                }
                
                return atts
            }
        }
         descriptionLabel.handleCustomTap(for: customType, handler: {[weak self] (element) in
             if let wkSelf = self {
                 DispatchQueue.main.async {
                     print("tapped in post table cell")
                     let tagText = element.replace(Constant.taggedSymbol, replacement: "")
                     wkSelf.delegate?.didTapMentionOnCaptionAt(row: descriptionLabel.row, section: descriptionLabel.section, tagText: tagText)
                 }
             }
         })
        descriptionLabel.handleURLTap { _ in
            return
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        commonInit()
    }
    
    override func layoutIfNeeded() {
        commonInit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setViewShadow(view: SSNeumorphicView, shadowType: ShadowLayerType){
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor =  UIColor.white.cgColor
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.7).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = view.frame.width / 2
        view.viewNeumorphicShadowRadius = 3
        view.viewNeumorphicShadowOffset = CGSize(width: 2, height: 2 )
    }

}
