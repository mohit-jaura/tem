//
//  ActivitySheetTableCell.swift
//  TemApp
//
//  Created by Harpreet_kaur on 22/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

class ActivitySheetTableCell: UITableViewCell {
    
    
    // MARK: IBOutlets.
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var lineView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: Methos to set data for Metric.
    func setMetricData(data:ActivityMetric) {
        itemName.text = data.title
        self.hideImageView()
    }
    
    // MARK: Methos to set data for activities.
    func setActivityData(data:ActivityData) {
        self.backgroundColor = .black
        self.itemName.textColor = .white
        self.itemName.text = data.name?.firstUppercased
        if let imageUrl = URL(string:data.image ?? "") {
            self.itemImageView.kf.setImage(with: imageUrl, placeholder:#imageLiteral(resourceName: "activity"),completionHandler:  { (image, error, cacheType, imageUrl) in
                self.tintColor = .white
                self.itemImageView.image = self.itemImageView.image?.withRenderingMode(.alwaysTemplate)
            })
        } else {
            self.itemImageView.image = #imageLiteral(resourceName: "activity")
        }
    }
    func setActivityCategory(data: Category){
        self.itemName.text = data.name.firstUppercased
    }
    func setRateActivityData(data: RateActivityData){
        self.itemName.text = data.name.firstUppercased
    }
    func setCoachList(data:CoachList){
        self.itemName.text = data.fullName
        if let url = URL(string: data.profilePic ?? ""){
            itemImageView.kf.setImage(with: url)
        }

    }
    // MARK: Methos to set data for MetricValue.
    func setForMetricValue(data:MetricValue) {
        if let value = data.value {
            if value == 0 {
                itemName.text = "\(data.unit ?? "")"
            }else if value == 6 {
                itemName.text = "5+ \(data.unit ?? "")"
            }else if value == 100 {
                itemName.text = "90+ \(data.unit ?? "")"
            }else{
                let finalValue = "\(value)"
                itemName.text = "\(finalValue.replace(".0", replacement: "")) \(data.unit ?? "")"
            }
        }
        self.hideImageView()
    }
    
    func setDataWith(value: String) {
        self.hideImageView()
        self.itemName.text = value
    }
    
    // MARK: Function to Hide imageview
    func hideImageView() {
        self.imageViewWidthConstraint.constant = 0
    }
}
