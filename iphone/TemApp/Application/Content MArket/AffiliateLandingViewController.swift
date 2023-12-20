//
//  AffiliateLandingViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 12/04/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

class AffiliateLandingViewController: DIBaseController, URLTappableProtocol {
    enum LinkButtons: Int, CaseIterable{
        case website = 1
        case insta
        case tiktok
        case youTube
    }

    // MARK: IBOutlets
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bgImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var paginationDotView:UIView!
    @IBOutlet weak var navigationView:UIView!
    @IBOutlet weak var mainView:UIView!
    @IBOutlet weak var coachingProfileButton: UIButton!
    @IBOutlet var linkIcons: [UIButton]!
    @IBOutlet weak var shareButton: UIButton!

    // MARK: Variables
    
    var affiliateId = ""
    var marketPlaceId = ""
    var contentMarketData: SeeAllModel?
    var isPlanPurchased = true

    override func viewDidLoad() {
        super.viewDidLoad()
        getServerData()
        setGradientBackground()
        setPlanListView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    @IBAction func backTapped(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func linkIconTapped(_ sender: UIButton) {
        var urlString = URL(string: "")
        switch LinkButtons(rawValue: sender.tag){
        case .website:
            urlString = URL(string: contentMarketData?.websiteUrl ?? "")
        case .insta:
            urlString = URL(string: contentMarketData?.instaUrl ?? "")
        case .tiktok:
            urlString = URL(string: contentMarketData?.tiktokUrl ?? "")
        case .youTube:
            urlString = URL(string: contentMarketData?.youTubeUrl ?? "")
        case .none:
            break
        }
        if let url = urlString{
            self.pushToSafariVCOnUrlTap(url: url)
        }
    }
    // MARK: Helper Functions
    func setPlanListView(){
        if !isPlanPurchased{
            paginationDotView.isHidden = false
            navigationView.isHidden = false
            paginationDotView.backgroundColor = #colorLiteral(red: 0.9686275125, green: 0.9686275125, blue: 0.9686275125, alpha: 1)
            paginationDotView.cornerRadius = paginationDotView.frame.width / 2
            addSwipeGesture()
        }
    }
    
    private func addSwipeGesture(){
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(showPaymentAlert))
        swipeGesture.direction = .left
        mainView.addGestureRecognizer(swipeGesture)
    }
    
    @objc func showPaymentAlert(){
        self.showAlert(withTitle: "", message: AppMessages.ContentMarket.purchasePlan, okayTitle: AppMessages.AlertTitles.Ok,  okCall: {
            self.pushToPlansVC()
        })
    }
    
    private func pushToPlansVC(){
        let planListVc: PlanListVC = UIStoryboard(storyboard: .profile).initVC()
        planListVc.affiliateId = affiliateId
        self.navigationController?.pushViewController(planListVc, animated: true)
    }
    
    func setGradientBackground() {
        let maskLayer = CAGradientLayer(layer: backgroundImageView.layer)
        maskLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        maskLayer.startPoint = CGPoint(x: 0, y: 0)
        maskLayer.endPoint = CGPoint(x: 0, y: 1.0)
        maskLayer.frame = backgroundImageView.bounds
        backgroundImageView.layer.mask = maskLayer
        
    }
    func getServerData(){
        //        self.showLoader()
        DIWebLayerContentMarket().getAffiliateData (id: self.marketPlaceId){ contentListing in
            self.hideLoader()
            self.contentMarketData = contentListing
            self.affiliateId = contentListing.affiliateId ?? ""
            self.configureViews()
        } failure: { _ in
            self.hideLoader()
        }
    }
    
    func configureViews(){
        backgroundImageView.setImg(contentMarketData?.image,UIImage(named: "ImagePlaceHolder"))
        // Will show the complete image without chopping the sides
        if let bgImage = backgroundImageView.image{
            let ratio = bgImage.size.width / bgImage.size.height
            _ = backgroundImageView.frame.width / ratio
            view.layoutIfNeeded()
        }
        titleLabel.text = contentMarketData?.title?.uppercased()
        descriptionTextView.isEditable = false
        descriptionTextView.isSelectable = false
        descriptionTextView.text = contentMarketData?.description
        logoImageView.setImg(contentMarketData?.logo,UIImage(named: "ImagePlaceHolder"))
        if contentMarketData?.isAffiliateCoach == 0{ // 0 for not showing the button and 1 for showing
            coachingProfileButton.isHidden = true
        } else{
            coachingProfileButton.isHidden = false
        }
        self.view.bringSubviewToFront(navigationView)
        if contentMarketData?.studioUrl != "" && contentMarketData?.studioUrl != nil {
            shareButton.isHidden = false
        } else{
            shareButton.isHidden = true
        }
        setLinkButtons()
    }

    private func setLinkButtons(){
        for button in linkIcons{
            switch LinkButtons(rawValue: button.tag){
            case .website:
                if contentMarketData?.websiteUrl != "" && contentMarketData?.websiteUrl != nil{
                    button.isHidden = false
                }
            case .insta:
                if contentMarketData?.instaUrl != "" && contentMarketData?.instaUrl != nil{
                    button.isHidden = false
                }
            case .tiktok:
                if contentMarketData?.tiktokUrl != "" && contentMarketData?.tiktokUrl != nil{
                    button.isHidden = false
                }
            case .youTube:
                if contentMarketData?.youTubeUrl != "" && contentMarketData?.youTubeUrl != nil{
                    button.isHidden = false
                }
            case .none:
                break
            }
        }
    }

    // MARK: IBAction
    @IBAction func textIconTapped(_ sender: UIButton) {
        let popverVC: CalendarPopupViewController = UIStoryboard(storyboard: .dashboard).initVC()
        popverVC.contentText = contentMarketData?.text ?? ""
        self.present(popverVC, animated: true, completion: nil)
    }
    @IBAction func coachingProfileTapped(_ sender: UIButton) {
        let profileVC: CoachingProfileViewController = UIStoryboard(storyboard: .coachingTools).initVC()
        profileVC.affiliateID = self.affiliateId
        self.navigationController?.pushViewController(profileVC, animated: true)
    }

    @IBAction func shareTapped(_ sender: UIButton) {
        self.shareLink(data: contentMarketData?.studioUrl ?? "")
    }

    func shareLink(data:String) {
        let activityViewController = UIActivityViewController(activityItems: [ data ] , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}
