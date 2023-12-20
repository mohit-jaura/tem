//
//  ServicesCollectionCell.swift
//  TemApp
//
//  Created by Shiwani Sharma on 17/04/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import UIKit

protocol SubscriptionDelegate{
    func cancelPaymentSubscription()
    func getPaymentUrl(amount: Double)
}
class ServicesCollectionCell: UICollectionViewCell {
    var profileData: CoachProfile?
    var delegate: SubscriptionDelegate?
    var totalAmt = 0.0

    @IBOutlet weak var descriptionTxtView: UITextView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var billingFrequencyLabel: UILabel!
    @IBOutlet weak var hireButton: UIButton!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var serviceNameabel: UILabel!


    @IBAction func hireButtonTapped(_ sender: UIButton) {
        if profileData?.services[sender.tag].isSubscribed == 1 { // For cancelling the current running subscription
            delegate?.cancelPaymentSubscription()

        } else if profileData?.services[sender.tag].isSubscribed == 0{
            delegate?.getPaymentUrl(amount: totalAmt) // For purchasing the subscription
        } else{
            hireButton.isUserInteractionEnabled = false
        }

    }
    func configureViews(index: Int, data: CoachProfile){
        self.profileData = data
        setHireButtonUI(at: index)
        addTitleLabel()
        let monthlyCost = ((Double((profileData?.services[index].monthlyCost ?? 0)) / 0.97) + 0.30)
        let calculatedAmt = (monthlyCost - Double((profileData?.services[index].monthlyCost ?? 0))).rounded(toPlaces: 2) // formula given by client
         totalAmt = (calculatedAmt + Double(profileData?.services[index].monthlyCost ?? 0)).rounded(toPlaces: 2)
        costLabel.text = "COST: $\(totalAmt)"//(Including processing fees: $\(calculatedAmt))"
        serviceNameabel.text = "NAME: \(data.services[index].name.uppercased())"
        billingFrequencyLabel.text = "BILLING FREQUENCY: \(data.services[index].frequencyName)"
        descriptionTxtView.text = profileData?.services[index].description ?? ""
    }


    func setHireButtonUI(at index: Int){
        if profileData?.services[index].isSubscribed == 0  { // not subscribed and expired
            hireButton.setBackgroundColor(UIColor.red, forState: .normal)
            if profileData?.services[index].maxClients == profileData?.services[index].connectedClients {
                hireButton.setTitle("UNAVAILABLE", for: .normal)
                hireButton.isUserInteractionEnabled = false
            } else{
                hireButton.isUserInteractionEnabled = true
                hireButton.setTitle("SELECT", for: .normal)
                hireButton.setBackgroundColor(#colorLiteral(red: 0.1333333333, green: 0.8549019608, blue: 0.08235294118, alpha: 1), forState: .normal)
            }
        } else if profileData?.services[index].isSubscribed == 1 { // subscribed but not cancelled
            hireButton.setTitle("CANCEL SUBSCRIPTION", for: .normal)
        } else if profileData?.services[index].isSubscribed == 2{ // subscribed, cancelled and not expired
            hireButton.setTitle( "SUBSCRIPTION CANCELLED", for: .normal)
        }
    }
    private func addTitleLabel(){
        let myLabel = UILabel()
        let labelTitle = "DESCRIPTION"
        myLabel.text = "    " + labelTitle + "     "
        let font = UIFont(name: UIFont.avenirNextMedium, size: 12)
        let heightOfString = labelTitle.heightOfString(usingFont: font!)
        let x_cord = 25
        let y_cord = 1//(wellnessOuterView.frame.origin.y)

        let widthofString = labelTitle.widthOfString(usingFont: font!)
        var widthOfLabel:CGFloat = widthofString - 20
        if widthofString > descriptionView.frame.width {
            widthOfLabel = widthofString
        }
        myLabel.frame = CGRect(x: CGFloat(x_cord), y: CGFloat(y_cord), width: widthOfLabel, height: heightOfString)
        myLabel.backgroundColor = .black
        myLabel.textColor = #colorLiteral(red: 0.01568627451, green: 0.9137254902, blue: 0.8901960784, alpha: 1)
        myLabel.font = font
        myLabel.textAlignment = .left
        myLabel.sizeToFit()
        descriptionView.addSubview(myLabel)
        descriptionView.clipsToBounds = false
    }

}
