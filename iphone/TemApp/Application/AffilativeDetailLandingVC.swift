//
//  AffilativeDetailLandingVC.swift
//  TemApp
//
//  Created by Developer on 20/04/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

class AffilativeDetailLandingVC: DIBaseController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var bgImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var videoBtn: UIButton!
    @IBOutlet weak var pdfBtn: UIButton!
    @IBOutlet weak var audioButton: UIButton!

    // MARK: Variables
    
    var marketPlaceId = ""
    var contentMarketData: SeeAllModelNew?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSereverData()
        setGradientBackground()
        
    }
    @IBAction func onClickVideo(_ sender:UIButton) {

        if contentMarketData?.type ?? 0 == 2 {
            let episodeVideoVC: EpisodeVideoViewController = UIStoryboard(storyboard: .temTv).initVC()
            episodeVideoVC.url = contentMarketData?.file ?? ""
            episodeVideoVC.fileType = .video
            self.navigationController?.pushViewController(episodeVideoVC, animated: true)
        }
        else if contentMarketData?.type ?? 0 == 1 {
            let selectedVC:AffilativePDFView = UIStoryboard(storyboard: .affilativeContentBranch).initVC()
            selectedVC.urlString = contentMarketData?.file ?? ""
            
            self.navigationController?.pushViewController(selectedVC, animated: true)

        }else{
            let audioPlayVC: AudioPlayViewController = UIStoryboard(storyboard: .temTv).initVC()
            audioPlayVC.previewImage = contentMarketData?.preview ?? ""
            audioPlayVC.remoteUrl = contentMarketData?.file ?? ""
            self.navigationController?.pushViewController(audioPlayVC, animated: false)
        }
        
    }
    
    @IBAction func audioButtonTapped(_ sender: UIButton) {
        let audioPlayVC: AudioPlayViewController = UIStoryboard(storyboard: .temTv).initVC()
        audioPlayVC.previewImage = contentMarketData?.preview ?? ""
        audioPlayVC.remoteUrl = contentMarketData?.file ?? ""
        self.navigationController?.pushViewController(audioPlayVC, animated: false)
    }

    @IBAction func onClickPdf(_ sender:UIButton) {
        let selectedVC:AffilativePDFView = UIStoryboard(storyboard: .affilativeContentBranch).initVC()
        selectedVC.urlString = contentMarketData?.file ?? ""
        self.navigationController?.pushViewController(selectedVC, animated: true)
    }
    
    
    // MARK: Helper Functions
    
    func setGradientBackground() {
        let maskLayer = CAGradientLayer(layer: backgroundImageView.layer)
        maskLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        maskLayer.startPoint = CGPoint(x: 0, y: 0)
        maskLayer.endPoint = CGPoint(x: 0, y: 1.0)
        maskLayer.frame = backgroundImageView.bounds
        backgroundImageView.layer.mask = maskLayer
        
    }
    func getSereverData(){
        self.showLoader()
        DIWebLayerContentMarket().getAffiliateData1 (id: self.marketPlaceId){ contentListing in
            self.hideLoader()
            self.contentMarketData = contentListing
            self.configureViews()
        } failure: { error in
            self.hideLoader()
        }
    }
    
    func configureViews(){
        if let type = contentMarketData?.type {
            if type == 2 {
                videoBtn.isHidden = false
                pdfBtn.isHidden = true
                audioButton.isHidden = true
            }
            else if type == 1 {
                videoBtn.isHidden = true
                pdfBtn.isHidden = false
                audioButton.isHidden = true
            }else{
                videoBtn.isHidden = false
                pdfBtn.isHidden = true
                audioButton.isHidden = false
            }
        }
        titleLabel.text = contentMarketData?.marketplacename?.uppercased()
        contentLabel.text = contentMarketData?.name?.uppercased()
        descriptionTextView.isEditable = false
        descriptionTextView.isSelectable = false
        descriptionTextView.text = contentMarketData?.description
        if let url = URL(string: contentMarketData?.marketplacelogo ?? ""){
            logoImageView.kf.setImage(with: url, placeholder: UIImage(named: "ImagePlaceHolder"))
        }
        if let url = URL(string: contentMarketData?.preview ?? ""){
            previewImageView.kf.setImage(with: url, placeholder: UIImage(named: "ImagePlaceHolder"))
        }
    }
    
    // MARK: IBAction
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true
        )
    }
}
