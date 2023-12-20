//
//  AboutController.swift
//  TemApp
//
//  Created by Harpreet_kaur on 21/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
enum AboutSections: Int, CaseIterable {
    
    case aboutUs = 0
    case termsAndCondition = 1
    case privacyPolicy = 2
    
    var title: String {
        switch self {
        case .aboutUs:
            return "About Us"
        case .termsAndCondition:
            return "Terms & Conditions"
        case .privacyPolicy:
            return "Privacy Policy"
            
        }
    }
}

class AboutController: DIBaseController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    // MARK: ViewWillAppear.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
        self.configureNavigation()
    }
    
    // MARK: Set Navigation
    func configureNavigation() {
        let leftBarButtonItem = UIBarButtonItem(customView: getBackButton())
        self.setNavigationController(titleName: Constant.ScreenFrom.about.title, leftBarButton: [leftBarButtonItem], rightBarButtom: nil, backGroundColor: UIColor.white, translucent: true)
        self.navigationController?.setDefaultNavigationBar()
    }
    
}
extension AboutController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AboutSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let currentSection = AboutSections(rawValue: indexPath.row) {
            guard let cell:AboutTableCell = tableView.dequeueReusableCell(withIdentifier: AboutTableCell.reuseIdentifier, for: indexPath) as? AboutTableCell else {
                return UITableViewCell()
            }
            cell.headingLabel.text = currentSection.title
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let currentSection = AboutSections(rawValue: indexPath.row) {
            switch currentSection {
            case .aboutUs:
                let selectedVC:TermsAndConditions = UIStoryboard(storyboard: .main).initVC()
                selectedVC.urlString = Constant.WebViewsLink.aboutUs
                selectedVC.navigationTitle = Constant.ScreenFrom.aboutUs.title
                self.navigationController?.pushViewController(selectedVC, animated: true)
            case .termsAndCondition:
                let selectedVC:TermsAndConditions = UIStoryboard(storyboard: .main).initVC()
                selectedVC.urlString = Constant.WebViewsLink.termsAndConditions
                selectedVC.navigationTitle = Constant.ScreenFrom.termsOfService.title
                self.navigationController?.pushViewController(selectedVC, animated: true)
            case .privacyPolicy:
                let selectedVC:TermsAndConditions = UIStoryboard(storyboard: .main).initVC()
                selectedVC.urlString=Constant.WebViewsLink.privacyPolicy
                selectedVC.navigationTitle=Constant.ScreenFrom.privacyPolicy.title
                self.navigationController?.pushViewController(selectedVC, animated: true)
            }
        }
    }
}

