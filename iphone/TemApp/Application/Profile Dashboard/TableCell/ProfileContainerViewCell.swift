//
//  ProfileContainerViewCell.swift
//  TemApp
//
//  Created by Harmeet on 17/06/20.
//

import UIKit

class ProfileContainerViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func addProfileView(view: UIViewController, type: ProfileHeaderTitles,createProfileVC:EditProfile,haisView:HAISViewController?,tematesVC:NetworkViewController,temHeight:CGFloat,haisViewheight:CGFloat) {
        for subview in self.containerView.subviews {
            if subview.tag == 21 {
                subview.removeFromSuperview()
            }
        }
        switch type {
        case .profile:
            if self.containerView.subviews.isEmpty {
                // createProfileVC.delegate = self
                createProfileVC.updateTitle()
                view.addChild(createProfileVC)
                createProfileVC.view.frame = CGRect(x: 0, y: 0, width: self.containerView.frame.size.width, height: 1200)
                self.containerView.addSubview(createProfileVC.view)
                createProfileVC.didMove(toParent: view)
                view.navigationController?.navigationBar.isHidden = true
            }
        case .healthMeasures:
            if self.containerView.subviews.isEmpty {
                if let haisVC = haisView{
                    // createProfileVC.delegate = self
                    haisVC.isFromProfile = true
                    view.addChild(haisVC)
                    haisVC.view.frame = CGRect(x: 0, y: 0, width: self.containerView.frame.size.width, height: haisViewheight)
                    self.containerView.addSubview(haisVC.view)
                    haisVC.didMove(toParent: view)
                }
                view.navigationController?.navigationBar.isHidden = true
            }
        case .temates:
            if self.containerView.subviews.isEmpty {
                // createProfileVC.delegate = self
                tematesVC.isFromProfile = true
                tematesVC.isFromDashboard = false
                //                tematesVC.setDefaultsForProfileScreen()
                view.addChild(tematesVC)
                //  self.containerView.frame = CGRect(x: -30, y: 0, width: self.frame.size.width, height: 1200)
                tematesVC.view.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: temHeight + 300)
                self.containerView.addSubview(tematesVC.view)
                print(tematesVC.view.frame)
                tematesVC.didMove(toParent: view)
                view.navigationController?.navigationBar.isHidden = true
            }
        default:
            break
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}


