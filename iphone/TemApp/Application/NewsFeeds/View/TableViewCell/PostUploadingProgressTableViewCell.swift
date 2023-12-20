//
//  PostUploadingProgressTableViewCell.swift
//  TemApp
//
//  Created by shilpa on 07/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

class PostUploadingProgressTableViewCell: UITableViewCell {

    // MARK: Properties
    var linearBar: LinearProgressBar!
    
    // MARK: IBOutlets
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.linearBar = LinearProgressBar()//LinearProgressBar(superview: self.progressView)
        self.progressView.addSubview(linearBar)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: Initializer
    func setDataWith(post: Post, showErrorLabel:Bool = false) {
        self.imgView.image = UIImage(named: "ImagePlaceHolder")
        
        if (showErrorLabel) {
          self.errorLabel.isHidden = false
          self.progressView.isHidden = true
        } else {
          self.errorLabel.isHidden = true
          self.progressView.isHidden = false
        }
        if let media = post.media,
            !media.isEmpty {
            if let urlString = media[0].previewImageUrl,
                let url = URL(string: urlString) {
                self.imgView.kf.setImage(with: url, placeholder: UIImage(named: "ImagePlaceHolder"))
            } else {
                self.imgView.image = media[0].image ?? UIImage(named: "ImagePlaceHolder")
            }
        }
        
    }
    
    func startAnimation() {
        self.linearBar.startAnimation()
    }
    
    func stopAnimation() {
        //self.linearBar.stopAnimation()
    }
}
