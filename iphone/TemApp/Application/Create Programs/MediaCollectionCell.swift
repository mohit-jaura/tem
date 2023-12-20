//
//  MediaCollectionCell.swift
//  TemApp
//
//  Created by Shiwani Sharma on 09/12/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class MediaCollectionCell: UICollectionViewCell {
    @IBOutlet weak var bgView: SSNeumorphicView!{
        didSet{
            addInnerShadow(view: bgView)
        }
    }
    
    @IBOutlet weak var imgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func addInnerShadow(view: SSNeumorphicView){
        view.viewDepthType = .innerShadow
        view.viewNeumorphicLightShadowColor = UIColor(red: 163.0 / 255.0, green: 177.0 / 255.0, blue: 198.0 / 255.0, alpha: 0.3).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.3).cgColor
        view.viewNeumorphicCornerRadius = 8.0
        view.viewNeumorphicMainColor = UIColor.blakishGray.cgColor
        view.viewNeumorphicShadowRadius = 2.0
    }
    func setData(data: SavedURls) {
        if let mediaType = data.mediaType {
            switch EventMediaType(rawValue: mediaType) {
            case .video:
                imgView.image = UIImage(named: "video2")
            case .pdf:
                imgView.image = UIImage(named: "pdf")
            default:
                break
            }
        }
    }
    
}
