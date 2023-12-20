//
//  TodoMediaCollectionCell.swift
//  TemApp
//
//  Created by Shiwani Sharma on 26/06/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import UIKit

class TodoMediaCollectionCell: UICollectionViewCell {

    @IBOutlet weak var mediaButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setData(data:TodoMedia?){
//    var mediaData:TodoMedia?
//        mediaData?.mediaType = data?.mediaType
//        mediaData?.url = data?.url
            if let mediaType = data?.mediaType {
                switch EventMediaType(rawValue: mediaType.rawValue) {
                case .video:
                    mediaButton.setImage(UIImage(named: "todoPlay"), for: .normal)
                case .pdf:
                    mediaButton.setImage(UIImage(named: "todoMenu"), for: .normal)
                default:
                    break
                }
            }
    }
}
