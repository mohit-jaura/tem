//
//  MediaCollectionViewCell.swift
//  TemApp
//
//  Created by Shiwani Sharma on 06/07/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

class MediaCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setData(data: SavedURls) {
        nameLabel.text = data.name
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
