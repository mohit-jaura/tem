//
//  CoachingProfileViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 20/02/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class CoachingProfileViewController: UIViewController,LoaderProtocol,NSAlertProtocol {

    enum CoachType: Int, CaseIterable{
        case physicalFitness = 1
        case nutrition = 2
        case mentalStrength = 3

        var title: String{
            switch self{
                case .physicalFitness:
                    return "Physical Fitness"
                case .nutrition:
                    return "Nutrition"
                case .mentalStrength:
                    return "Mental Strength"
            }

        }
    }

    // MARK: Variables
    var profileData: CoachProfile?
    var affiliateID = ""
    var totalAmt = 0.0
    var currentService = 0

    // MARK: IBOutlet
    @IBOutlet weak var wellnessOuterView: UIView!

    @IBOutlet weak var servicesCountLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var coachNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var coachingTypeLabel: UILabel!
    @IBOutlet weak var clientStatusLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        getCochProfileData()
    }

    // MARK: IBAction
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func faqTapped(_ sender: UIButton) {
        let faqVC: CoachingFAQController = UIStoryboard(storyboard: .coachingTools).initVC()
        faqVC.affiliateId = self.affiliateID
        self.navigationController?.pushViewController(faqVC, animated: true)
    }

    func getCochProfileData(){
        self.showHUDLoader()
        DIWebLayerCoachingToolsAPI().getCoachProfileData(coachID: affiliateID, success: { data in
            self.hideHUDLoader()
            self.profileData = data
            self.configureViews()
        }, failure: { error in
            self.hideHUDLoader()
        })
    }

    func configureViews(){
        addTitleLabel()
        servicesCountLabel.text = "SERVICES: \(profileData?.services.count ?? 0)"
        var coachTypes: [String]? = [""]
        if let data = profileData?.coachType{
            coachTypes = data.map({
                CoachType(rawValue: $0)?.title ?? ""
            })
        }
        if let type = coachTypes{
            coachingTypeLabel.text = type.joined(separator: ", ").uppercased()
        }
        pageControl.numberOfPages = profileData?.services.count ?? 0
        descriptionLabel.text = profileData?.description.firstCapitalized
        coachNameLabel.text = profileData?.coachName.uppercased()
        if let imageUrl = URL(string:profileData?.image ?? "") {
            self.profileImageView.kf.setImage(with: imageUrl, placeholder: #imageLiteral(resourceName: "user-dummy"))
        } else {
            self.profileImageView.image = #imageLiteral(resourceName: "user-dummy")
        }
        self.collectionView.reloadData()
    }

   
    func setClientStatusUI(index: Int){
        if profileData?.services[index].maxClients == profileData?.services[index].connectedClients {
            clientStatusLabel.text = "NOT ACCEPTING CLIENTS"
            clientStatusLabel.backgroundColor = .red

        } else{
            clientStatusLabel.text = "ACCEPTING CLIENTS"
            clientStatusLabel.backgroundColor = #colorLiteral(red: 0.1333333333, green: 0.8549019608, blue: 0.08235294118, alpha: 1)
        }

    }

    func checkoutPaymentURl() {
        self.showHUDLoader()
        let params = ["totalPrice": totalAmt,
                      "affid": affiliateID,
                      "serviceId": profileData?.services[currentService].id ?? ""
        ] as [String : Any]
        DIWebLayerCoachingToolsAPI().getCheckoutURL(params: params, success: { url in
            self.hideHUDLoader()
            self.navigateToWebView(url: url)
        }, failure: { error in
            self.hideHUDLoader()
            print(error.description)
        })
    }
    func cancelSubscription(){
        self.showHUDLoader()
        DIWebLayerCoachingToolsAPI().cancelSubscription(serviceId: profileData?.services[currentService].id ?? "", affiliateId: affiliateID, success: { message in
            self.hideHUDLoader()
            self.showAlert(withMessage: message)
            self.getCochProfileData()
        }, failure: { error in
            self.hideHUDLoader()
            print(error.description)
        })
    }
    private func addTitleLabel(){
        let myLabel = UILabel()
        let labelTitle = "DESCRIPTION"
        myLabel.text = "    " + labelTitle + "     "
        let font = UIFont(name: UIFont.avenirNextMedium, size: 12)
        let heightOfString = labelTitle.heightOfString(usingFont: font!)
        let x_cord = wellnessOuterView.frame.origin.x
        let y_cord = 2//(wellnessOuterView.frame.origin.y)

        let widthofString = labelTitle.widthOfString(usingFont: font!)
        var widthOfLabel:CGFloat = widthofString - 20
        if widthofString > wellnessOuterView.frame.width {
            widthOfLabel = widthofString
        }
        myLabel.frame = CGRect(x: x_cord, y: CGFloat(y_cord), width: widthOfLabel, height: heightOfString)
        myLabel.backgroundColor = .black
        myLabel.textColor = #colorLiteral(red: 0.01568627451, green: 0.9137254902, blue: 0.8901960784, alpha: 1)
        myLabel.font = font
        myLabel.textAlignment = .left
        myLabel.sizeToFit()
        wellnessOuterView.addSubview(myLabel)
        wellnessOuterView.clipsToBounds = false
    }
    func navigateToWebView(url:String?){
        guard let url = url else {
            return
        }
        let webView:TermsAndConditions = UIStoryboard(storyboard: .main).initVC()
        webView.urlString = url
        webView.paymentFrom = .coachingTools
        webView.navigationTitle = "Payment"
        webView.isSuccess = { sucess in
            //hit api for refreshing
            self.getCochProfileData()
        }
        self.navigationController?.pushViewController(webView, animated: true)
    }
}
extension CoachingProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profileData?.services.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: ServicesCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: ServicesCollectionCell.reuseIdentifier, for: indexPath) as? ServicesCollectionCell else{
            return UICollectionViewCell()
        }
        cell.delegate = self
        cell.hireButton.tag = indexPath.item
        if let data = profileData{
            cell.configureViews(index: indexPath.item, data: data)
        }

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageControl.currentPage = indexPath.item
        currentService = indexPath.item
//        setClientStatusUI(index: indexPath.item)
    }
}

extension CoachingProfileViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
extension CoachingProfileViewController: SubscriptionDelegate{
    func getPaymentUrl(amount: Double) {
        self.totalAmt = amount
        self.checkoutPaymentURl()
    }
    func cancelPaymentSubscription(){
        self.cancelSubscription()
    }
}
