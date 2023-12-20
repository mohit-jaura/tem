//
//  AffilativeContentDetailVC.swift
//  TemApp
//
//  Created by Developer on 15/04/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

class AffilativeContentDetailVC: UIViewController {
    var contentModel: ContentModel?
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var episodeNameLabel: UILabel!
    @IBOutlet weak var episodeDescriptionLabel: UILabel!
    @IBOutlet weak var videoBtn: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var bgImageViewHeight: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        // Do any additional setup after loading the view.
    }
    // MARK: IBActions
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true
        )
    }
    
    func configureView() {
        if let type = contentModel?.type {
            if type == 2 {
                videoBtn.isHidden = false
            } else {
                videoBtn.isHidden = true
            }
            
        }
        if let imageUrl = contentModel?.preview,
           let url = URL(string: imageUrl){
            backgroundImageView.kf.setImage(with: url, placeholder: UIImage(named: "ImagePlaceHolder"))
        }
        if let bgImage = backgroundImageView.image{
            let ratio = bgImage.size.width / bgImage.size.height
            let newHeight = backgroundImageView.frame.width / ratio
            bgImageViewHeight.constant = newHeight
            view.layoutIfNeeded()
        }
        episodeNameLabel.text = contentModel?.name?.capitalized
        self.textView.text = contentModel?.description ?? ""
        setGradientBackground()
    }
    
    @IBAction func onClickVideo(_ sender:UIButton) {
        let episodeVideoVC: EpisodeVideoViewController = UIStoryboard(storyboard: .temTv).initVC()
        episodeVideoVC.url = contentModel?.file ?? ""
        self.navigationController?.pushViewController(episodeVideoVC, animated: true)
    }
    func setGradientBackground() {
        let maskLayer = CAGradientLayer(layer: backgroundImageView.layer)
        maskLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        maskLayer.startPoint = CGPoint(x: 0, y: 0)
        maskLayer.endPoint = CGPoint(x: 0, y: 1.0)
        maskLayer.frame = backgroundImageView.bounds
        backgroundImageView.layer.mask = maskLayer
        
    }
}
