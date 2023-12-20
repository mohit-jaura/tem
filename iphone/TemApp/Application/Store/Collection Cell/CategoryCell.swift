//
//  CategoryCollectionViewCell.swift
//  TemApp
//
//  Created by Shiwani Sharma on 13/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
enum Select{
    case Selected
    case UnSelected
}
class CategoryCell: UICollectionViewCell {
    var updateUiDelegate: CategoryUiDelegate?
    
    @IBOutlet weak var nameTitleLabel: UILabel!
    @IBOutlet weak var containerView: SSNeumorphicView!
    {
        didSet {
//            containerView.viewDepthType = .innerShadow
//            containerView.viewNeumorphicMainColor = containerView.backgroundColor?.cgColor
//            containerView.viewNeumorphicLightShadowColor = UIColor.clear.cgColor
//            containerView.viewNeumorphicDarkShadowColor = UIColor.gray.withAlphaComponent(0.1).cgColor
//            containerView.viewNeumorphicCornerRadius = 18
        }
    }
    var selectedIndex:IndexSelected?
    
    // MARK: IBOutlets
   
    @IBOutlet weak var categoryNameButton: UIButton!
    
    @IBOutlet weak var bgImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
       // containerView.layer.cornerRadius = 15
        //containerView.layer.masksToBounds = true
       // containerView.doubleShadow_V1()
    }
    
    func setData(data: CategoryInfo? ){
        
        nameTitleLabel.text = data?.categoryname?.firstCapitalized
        setUIForSel(data?.isSelected ?? false)
      
    }
    
    private func setUIForSel(_ isSelected:Bool) {
        
        let image  = isSelected ? UIImage.sel_But : UIImage.unsel_But
        
        let titleColor:UIColor = isSelected ? .white : .gray
        
        containerView.viewNeumorphicMainColor = isSelected ? UIColor.appMainColour.cgColor : UIColor.white.cgColor
        
        containerView.viewBGColor = isSelected ? UIColor.appMainColour.cgColor : UIColor.white.cgColor
        
//        containerView.viewNeumorphicDarkShadowColor = isSelected ? UIColor.appMainColour.withAlphaComponent(0.2).cgColor : UIColor.white.cgColor
//        
//        containerView.viewNeumorphicLightShadowColor = isSelected ? UIColor.appMainColour.withAlphaComponent(0.1).cgColor : UIColor.white.cgColor
      //  bgImageView.image = image
        //categoryNameButton.setBackgroundImage( image, for: .normal)
        
        nameTitleLabel.textColor = titleColor
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        containerViewSetup()

    }
    func containerViewSetup() {
        containerView.viewDepthType = .outerShadow


       // containerView.layer.masksToBounds = true
       /// containerView.cornerRadius =  containerView.frame.height/2
      //  containerView.neumorphicLayer?.neumorphicMainColor = UIColor.green.cgColor
       // containerView.neumorphicShadowLayer
        
    }
    @IBAction func categoryButtonTapped(_ sender: UIButton) {
        
        setUIForSel(true)
        
        selectedIndex?(IndexPath(row:self.tag,section: 0))
    }
    
}


//struct EventDaysModal : Codable {
//    let data : Any?
//    let status : Int?
//    let message :String?
//    enum CodingKeys: String, CodingKey {
//        case message = "message"
//        case data = "data"
//        case status = "status"
//    }
//    
//
////    init(from decoder: Decoder) throws {
////        let values = try decoder.container(keyedBy: CodingKeys.self)
////        data = try values.decodeIfPresent([EventDetail]?.self, forKey: .data) as! [EventDetail]
////        message = try values.decodeIfPresent(String.self, forKey: .message)
////
////        status = try values.decodeIfPresent(Int.self, forKey: .status)
////    }
//
//}


struct CategoryData : Codable {
    let data : [CategoryInfo]?
    let status : Int?
    let message :String?
    enum CodingKeys: String, CodingKey {
        case message = "message"
        case data = "data"
        case status = "status"
    }
    

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent([CategoryInfo].self, forKey: .data)
        message = try values.decodeIfPresent(String.self, forKey: .message)

        status = try values.decodeIfPresent(Int.self, forKey: .status)
    }

}

struct CategoryInfo : Codable {
    let categoryname : String?
    var isSelected:Bool = false
    

    enum CodingKeys: String, CodingKey {

        case categoryname = "categoryname"
    }
    init(_ categoryname:String?,_ isSelected:Bool = true) {
        self.categoryname = categoryname
        self.isSelected  = isSelected
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        categoryname = try values.decodeIfPresent(String.self, forKey: .categoryname)
    }

}
