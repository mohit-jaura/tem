//
//  PostImageCollectionViewCell.swift
//  TemApp
//
//  Created by shilpa on 19/02/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

class PostImageCollectionViewCell: UICollectionViewCell {

    // MARK: IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // MARK: Initializer
    func initializeWith(media: Media, atIndexPath indexPath: IndexPath) {
        self.imageView.kf.indicatorType = .activity
        if let urlString = media.url,
            let url = URL(string: urlString) {
            self.imageView.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: { (receivedSize, _) in
            }, completionHandler: {(_) in
            })
        }
    }
}
