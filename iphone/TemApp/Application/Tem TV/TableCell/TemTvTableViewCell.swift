//
//  TemTvTableViewCell.swift
//  TemApp
//
//  Created by Shiwani Sharma on 14/01/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import Kingfisher

class TemTvTableViewCell: UITableViewCell {

    // MARK: IBOutlet
    
    @IBOutlet weak var videoPlayIcon: UIImageView!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionLabelBottomConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setSeriesData(seriesData: TvSeries){
        videoPlayIcon.isHidden = true
        let url = URL(string: seriesData.image ?? "")
        videoImageView.kf.setImage(with: url, placeholder: UIImage(named: "ImagePlaceHolder"))
        nameLabel.text = seriesData.name?.firstUppercased
        descriptionLabel.text = seriesData.about
        descriptionLabel.numberOfLines = 3
    }
    
    func setEpisodesData(episodeData: Episodes){
        let url = URL(string: episodeData.previewUrl)
        videoImageView.kf.setImage(with: url, placeholder: UIImage(named: "ImagePlaceHolder"))
        nameLabel.text = episodeData.name.firstUppercased
        descriptionLabel.text = episodeData.description
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

