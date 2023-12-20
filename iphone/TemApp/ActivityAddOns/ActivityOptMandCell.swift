//
//  ActivityOptMandCell.swift
//  TemApp
//
//  Created by PrabSharan on 21/07/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
class ActivityOptMandCell: UITableViewCell {
    
    @IBOutlet weak var deleteButtOut: UIButton!
    @IBOutlet weak var subCategoryLabel: UILabel!
    var activityModal:ActivityAddOns? {
        didSet {
            initialise()
        }
    }
    @IBOutlet weak var radioView: SSNeumorphicView! {
        didSet {
            setToggleShadow(radioView)
        }
    }
    var delete:IndexSelected?
    var segmentSelected:((_ index:IndexPath,_ type:Duration) -> ())?
    var mandatrySelected:IndexSelected?
    
    @IBOutlet weak var delButOut: UIButton!
    @IBOutlet weak var segmentView: UISegmentedControl!
    @IBOutlet weak var radioImgView: UIImageView!
    @IBOutlet weak var mainCatLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        initiliaseSegment()
    }
    func initialise() {
        guard let activityModal = activityModal else {
            return
        }
        radioImgView.image = activityModal.isManadatory == 1 ? UIImage.radioSel : nil
        segmentView.selectedSegmentIndex = activityModal.time ?? 0 > 0 ? 1 : 0
        mainCatLabel.text = activityModal.category_name?.capitalized
        subCategoryLabel.text = activityModal.activity_name
        timeInitialise()

    }
    func initiliaseSegment() {
        
        segmentView.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: UIFont.avenirNextMedium, size: 14) ?? UIFont.systemFont(ofSize: 14),NSAttributedString.Key.foregroundColor: UIColor.white],
                                           for: .normal)

    }
    func timeInitialise() {
        if let sec = activityModal?.time,sec > 0 {
            //Convert it into hour min sec
            segmentView.setTitle(activityModal?.visibleTime ?? getTime(sec), forSegmentAt: 1)
        }else {
            segmentView.setTitle("Duration", forSegmentAt: 1)
        }

    }
    func getTime(_ sec:Int) -> String  {
        let (h,m,s) = Utility.shared.secondsToHoursMinutesSeconds(seconds: sec)
        return "\(h)h \(m)m \(s)s"
    }
    
    func setToggleShadow(_ view:SSNeumorphicView){
        view.viewDepthType = .innerShadow
        view.viewNeumorphicMainColor = UIColor.newAppThemeColor.cgColor
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = view.frame.height / 2
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func radioAction(_ sender: Any) {
        self.delete?(IndexPath(row: self.tag, section: 0))
    }
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        segmentSelected?(IndexPath(row: self.tag, section: 0),Duration(rawValue:sender.selectedSegmentIndex ) ?? .Free)
    }
    @IBAction func mondatoryAction(_ sender: Any) {
        mandatrySelected?(IndexPath(row: self.tag, section: 0))
    }
    
}
