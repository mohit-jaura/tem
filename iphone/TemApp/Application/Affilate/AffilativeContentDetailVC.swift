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
//            if newHeight > 350{
//                bgImageViewHeight.constant = 350
//            }else{
            bgImageViewHeight.constant = newHeight
            view.layoutIfNeeded()
    //    }
     
        }
        episodeNameLabel.text = contentModel?.name?.capitalized
       // episodeDescriptionLabel.text = contentModel?.description ?? ""
        self.textView.text = contentModel?.description ?? ""
        //textViewHeightConstraint.constant = self.textView.contentSize.height
        setGradientBackground()
    }
    
    @IBAction func onClickVideo(_ sender:UIButton) {
        let episodeVideoVC: EpisodeVideoViewController = UIStoryboard(storyboard: .temTv).initVC()
        episodeVideoVC.url = contentModel?.file ?? ""
//        let fileType = episodesData[indexPath.row].fileType
//        if fileType.contains("image"){
//            episodeVideoVC.fileType = .image
//        } else if fileType.contains("video"){
//            episodeVideoVC.fileType = .video
//        } else if fileType.contains("application"){
//            episodeVideoVC.fileType = .pdf
//        }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
