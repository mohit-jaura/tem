//
//  CoachingViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 17/02/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import UIKit

class CoachingViewController: UIViewController,LoaderProtocol {


    // MARK: IBOutlets
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet var shadowViews: [UIView]!{
        didSet{
            for view in shadowViews{
                view.cornerRadius = view.frame.height / 2
                view.borderWidth = 2
                view.borderColor = UIColor.appCyanColor
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initializer()
    }

    private func initializer(){
        currentDateLabel.text =  Date().UTCToLocalString(inFormat: .coachingTools).uppercased()
    }


    // MARK: IBActions

    @IBAction func myCoachesTapped(_ sender: UIButton) {
        let myCoachVC: MyCoachViewController = UIStoryboard(storyboard: .coachingTools).initVC()
        self.navigationController?.pushViewController(myCoachVC, animated: true)
    }
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func notificationTapped(_ sender: UIButton){
        let selectedVC:NotificationsController = UIStoryboard(storyboard: .notification).initVC()
        self.navigationController?.pushViewController(selectedVC, animated: true)
    }


}
