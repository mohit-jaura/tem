//
//  FeedAndCalendarController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 21/11/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class FeedAndCalendarController: DIBaseController {

    // MARK: IBOutlets
    @IBOutlet weak var calendarContainerView: UIView!
    @IBOutlet weak var feedsContainerView: UIView!
    @IBOutlet weak var monthlyContainerView: UIView!
    @IBOutlet weak var addPostButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var feedsView: SSNeumorphicView!
    @IBOutlet weak var calendarView: SSNeumorphicView!
    @IBOutlet weak var feedsInnerView: UIView!
    @IBOutlet weak var calendarInnerView: UIView!
    @IBOutlet weak var feedsButton: UIButton!
    @IBOutlet weak var calendarButtton: UIButton!
    @IBOutlet weak var FirstOuterView: UIView!

    // MARK: Variables
    let calendarColor = UIColor.newAppThemeColor.cgColor
    var screenFrom: Constant.ScreenFrom = .newsFeeds

    override func viewDidLoad() {
        super.viewDidLoad()
        addPostButton.isHidden = true
        monthlyContainerView.addDoubleShadow(cornerRadius: 15, shadowRadius: 3, lightShadowColor: UIColor.white.withAlphaComponent(0.3).cgColor, darkShadowColor: UIColor.darkGray.cgColor, shadowBackgroundColor: calendarColor)
        setInnerShadows(view: calendarView, mainColor: UIColor.appThemeColor.cgColor)
        setInnerShadows(view: feedsView, mainColor: calendarColor)
        feedsInnerView.backgroundColor = UIColor.newAppThemeColor
        calendarInnerView.backgroundColor = .appThemeColor
        configureView()
    }

    // MARK: IBAction
    @IBAction func feedsView(_ sender: UIButton) {
        setFeedsView()
        if children.first(where: { String(describing: $0.classForCoder) == "FeedsViewController" }) == nil {
            let feedsVc: FeedsViewController = UIStoryboard(storyboard: .post).initVC()
            activeViewController = feedsVc
        }
    }

    @IBAction func calendarTapped(_ sender: UIButton) {
        setCalendarView()
    }

    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func addPostTapped(_ sender: UIButton) {
        let createPostVC: CreatePostViewController = UIStoryboard(storyboard: .post).initVC()
                createPostVC.isForCreatePost = true
                self.navigationController?.pushViewController(createPostVC, animated: true)
    }

    private var activeViewController: UIViewController? {
        didSet {
          //  removeInactiveViewController(inactiveViewController: oldValue)
            updateActiveViewController(activeVC: activeViewController ?? UIViewController())
        }
    }
    private func configureView(){
        if screenFrom == .event{
            feedsContainerView.isHidden = true
            calendarContainerView.isHidden = false
            let calendarVc: CalendarVC = UIStoryboard(storyboard: .calendar).initVC()
            activeViewController = calendarVc
            setCalendarView()
        } else{
            feedsContainerView.isHidden = false
            calendarContainerView.isHidden = true
            let feedsVc: FeedsViewController = UIStoryboard(storyboard: .post).initVC()
            activeViewController = feedsVc
            setFeedsView()
        }
    }
    private func removeInactiveViewController(inactiveViewController: UIViewController?) {
        if let inActiveVC = inactiveViewController {
            // call before removing child view controller's view from hierarchy
            inActiveVC.willMove(toParent: nil)
            inActiveVC.view.removeFromSuperview()
            // call after removing child view controller's view from hierarchy
            inActiveVC.removeFromParent()
        }
    }

    private func updateActiveViewController(activeVC: UIViewController) {
            if let activeVC = activeViewController {
                addChild(activeVC)
                if screenFrom == .event{
                    activeVC.view.frame = calendarContainerView.bounds
                    calendarContainerView.addSubview(activeVC.view)
                } else{
                    activeVC.view.frame = feedsContainerView.bounds
                    feedsContainerView.addSubview(activeVC.view)

                }

                // call before adding child view controller's view as subview
                activeVC.didMove(toParent: self)
            }
    }
    // MARK: Helper functions
    func setCalendarView(){
        FirstOuterView.backgroundColor = UIColor.newAppThemeColor
        monthlyContainerView.addDoubleShadow(cornerRadius: 15, shadowRadius: 3, lightShadowColor: UIColor.white.withAlphaComponent(0.3).cgColor, darkShadowColor: UIColor.darkGray.cgColor, shadowBackgroundColor: calendarColor)
        calendarButtton.setTitleColor(.white, for: .normal)
        setInnerShadows(view: feedsView, mainColor: calendarColor)
        setInnerShadows(view: calendarView, mainColor: UIColor.appThemeColor.cgColor)
        feedsInnerView.backgroundColor = UIColor.newAppThemeColor
        calendarInnerView.backgroundColor = .appThemeColor
        addPostButton.isHidden = true
        calendarContainerView.isHidden = false
        feedsContainerView.isHidden = true
        feedsButton.setTitleColor(.white, for: .normal)
    }

    func setFeedsView(){
        FirstOuterView.backgroundColor = UIColor.newAppThemeColor
        monthlyContainerView.addDoubleShadow(cornerRadius: 15, shadowRadius: 3, lightShadowColor: UIColor.white.withAlphaComponent(0.3).cgColor, darkShadowColor: UIColor.darkGray.cgColor, shadowBackgroundColor:  calendarColor)
        addPostButton.isHidden = false
        calendarContainerView.isHidden = true
        feedsContainerView.isHidden = false
        calendarButtton.setTitleColor(.white, for: .normal)
        feedsButton.setTitleColor(.white, for: .normal)
        setInnerShadows(view: feedsView, mainColor: UIColor.appThemeColor.cgColor)
        setInnerShadows(view: calendarView, mainColor: calendarColor)
        calendarInnerView.backgroundColor = UIColor.newAppThemeColor
        feedsInnerView.backgroundColor = .appThemeColor
    }

    func setInnerShadows(view:SSNeumorphicView, mainColor: CGColor){
        view.viewDepthType = .innerShadow
        view.viewNeumorphicCornerRadius = 10
        view.viewNeumorphicMainColor = mainColor
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
    }
}
