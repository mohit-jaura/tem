//
//  ActivityTableViewCell.swift
//  TemApp
//
//  Created by shilpa on 01/07/20.
//

import UIKit
import SSNeumorphicView
protocol ActivityTableCellDelegate: AnyObject {
    func didTapOnActivity(sender: UIButton)
}
class ActivityTableViewCell: UITableViewCell {

    // MARK: Properties
    weak var delegate: ActivityTableCellDelegate?
    
    // MARK: IBOutlets
    @IBOutlet weak var outerShadowView:  SSNeumorphicView! {
        didSet {
            outerShadowView.viewDepthType = .outerShadow
            outerShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.6).cgColor
           outerShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.1).cgColor
            outerShadowView.viewNeumorphicMainColor = UIColor.black.cgColor
            outerShadowView.viewNeumorphicCornerRadius = 4.0
            outerShadowView.viewNeumorphicShadowOpacity = 1
        }
    }
    
    @IBOutlet weak var activityIconImageView: UIImageView!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var activityButton: UIButton!
    
    // MARK: IBActions
    @IBAction func activityButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapOnActivity(sender: sender)
    }
    
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      //  self.activityIconImageView.setImageColor(color: UIColor.appThemeColor)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: Initializer
    func initializeWith(activityData: ActivityData, indexPath: IndexPath) {
        self.activityButton.tag = indexPath.row
        self.activityNameLabel.text = activityData.name?.uppercased()
        
        //set image url and change tint color
   /*     if let imageUrl = URL(string: activityData.image ?? "") {
            self.activityIconImageView.kf.setImage(with: imageUrl, placeholder: #imageLiteral(resourceName: "activity"), options: nil, progressBlock: nil) { (result) in
                self.activityIconImageView.setImageColor(color: UIColor.appThemeColor)
            }
        } else {
            self.activityIconImageView.image = #imageLiteral(resourceName: "activity")
            self.activityIconImageView.setImageColor(color: UIColor.appThemeColor)
        }*/
    }
}
