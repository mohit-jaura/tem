//
//  ProImgCarouselCell.swift
//  TemApp
//
//  Created by debut_mac on 13/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

class ProImgCarouselCell: UICollectionViewCell {

    @IBOutlet weak var proImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func addImg(_ imgStr:String?) {
        proImgView.setImg(imgStr)
    }
    func addImgWithUrl(_ url:URL?) {
        proImgView.setImgwithUrl(url)
    }
}
