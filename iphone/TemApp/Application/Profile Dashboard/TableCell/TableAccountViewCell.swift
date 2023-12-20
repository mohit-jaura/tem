//
//  TableAccountViewCell.swift
//  TemApp
//
//  Created by Harmeet on 18/06/20.
//

import UIKit

class TableAccountViewCell: UITableViewCell {
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var viewHeight:NSLayoutConstraint!
    var vc : UIViewController?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setVc(vcc: UIViewController) {
        vc = vcc
    }
    @IBAction func backButtonAction(_ sender: UIButton) {
        view.isHidden = false
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.layer.add(transition, forKey: kCATransition)
        view.isHidden = true
        for subview in self.view.subviews {
            if subview.tag == 22 {
                subview.removeFromSuperview()
            }
        }
        
    }
    @IBAction func action(_ sender: UIButton) {
        
        for subview in self.view.subviews {
            if subview.tag == 22 {
                subview.removeFromSuperview()
            }
        }
        
        var selectedVC: UIViewController?
        let selectedIndex = AccountSettingSection(rawValue: sender.tag)
        switch selectedIndex {
        case .account:
            let accountVC:AccountController = UIStoryboard(storyboard: .settings).initVC()
            selectedVC = accountVC
        case .linkDevice:
            let deviceController:DeviceController = UIStoryboard(storyboard: .sidemenu).initVC()
            selectedVC = deviceController
        case .linkApps:
            let appsController:AppsController = UIStoryboard(storyboard: .settings).initVC()
            self.viewHeight.constant = 569
            selectedVC = appsController
        case .notiifications:
            let deviceController:NotificationSettingController = UIStoryboard(storyboard: .settings).initVC()
            selectedVC = deviceController
        case .privacy:
            let privacyController:PrivacyAndSecurityController = UIStoryboard(storyboard: .privacy).initVC()
            selectedVC = privacyController
            
        case .none:
            break
        }
        
        selectedVC?.view.tag = 22
        /// if self.view.subviews.isEmpty {
        // let createProfileVC:NotificationSettingController = UIStoryboard(storyboard: .settings).initVC()
        // createProfileVC.delegate = self
        view.isHidden = false
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.layer.add(transition, forKey: kCATransition)
        
        selectedVC?.view.frame = self.view.bounds 
        vc?.addChild(selectedVC ?? UIViewController())
        self.view.addSubview(selectedVC?.view ?? UIView())
        self.view.backgroundColor = .clear
        selectedVC?.didMove(toParent: vc)
        selectedVC?.view.layoutIfNeeded()
        selectedVC?.view.frame = CGRect(x: 0, y: 30, width: self.view.frame.size.width, height: 569)
        selectedVC?.navigationController?.navigationBar.isHidden = true
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
