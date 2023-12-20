//
//  ChallengeDetailPageController.swift
//  TemApp
//
//  Created by Egor Shulga on 2.03.21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import Foundation

enum ChallengeDetailTab {
    case info
    case fundraising
}

protocol SelectChallengeDetailPageDelegate {
    func select(page: ChallengeDetailTab)
}

class ChallengeDetailPageController : UIPageViewController {
    var challengeId: String?
    var selectChallengeDetailPageDelegate: SelectChallengeDetailPageDelegate?

    private var tabs: [ChallengeDetailTab] = []
    private var views: [UIViewController] = []
    private var currentIndex: Int = -1
    var joinHandler: OnlySuccess?
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func initialize(_ tabs: [ChallengeDetailTab], _ challenge: GroupActivity, _ refresh: RefreshGNCEventDelegate) {
        self.views = tabs.map({ (page) in
            var vc: UIViewController
            if let existingIndex = self.tabs.firstIndex(of: page) {
                vc = self.views[existingIndex]
                if vc.isViewLoaded, let vc = vc as? UpdateGNCEventInfoProtocol {
                    vc.use(challenge)
                }
            } else {
                vc = viewController(page, challenge, refresh)
            }
            return vc
        })
        self.tabs = tabs
        if currentIndex == -1 {
            self.setCurrentVisibleControllerAt(page: tabs[0])
        }
    }
    
    func viewController(_ page: ChallengeDetailTab, _ challenge: GroupActivity, _ refresh: RefreshGNCEventDelegate) -> UIViewController {
        switch page {
        case .info:
            let vc: ChallengeInfoController = UIStoryboard(storyboard: .goalandchallengedetailnew).initVC()
            vc.challengeId = challengeId
            vc.challenge = challenge
            vc.refresh = refresh
            vc.joinHandler = { [weak self] in
                if let joinHandler = self?.joinHandler {
                    joinHandler()
                }
            }
            return vc
        case .fundraising:
            let vc: FundraisingViewController = UIStoryboard(storyboard: .goalandchallengedetailnew).initVC()
            vc.eventId = self.challengeId
            vc.event = challenge
            vc.refresh = refresh
            return vc
        }
    }
    
    func setCurrentVisibleControllerAt(page: ChallengeDetailTab, animated: Bool = true) {
        if let index = tabs.firstIndex(of: page) {
            let controller = self.views[index]
            let direction: NavigationDirection = self.currentIndex < index ? .forward : .reverse
            setViewControllers([controller], direction: direction, animated: animated) { _ in self.currentIndex = index }
        }
    }
}

extension ChallengeDetailPageController : UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = views.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        guard tabs.count > previousIndex else {
            return nil
        }
        return views[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = views.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = tabs.count
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        return views[nextIndex]
    }
}

extension ChallengeDetailPageController : UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished,
           let controller = pageViewController.viewControllers?.first,
           let index = self.views.firstIndex(of: controller) {
            let page = self.tabs[index]
            self.selectChallengeDetailPageDelegate?.select(page: page)
            self.currentIndex = index
        }
    }
}

extension ChallengeDetailPageController : UpdateByTimerProtocol {
    func handleTick() {
        for vc in views {
            if vc.isViewLoaded {
                let vc = vc as! UpdateByTimerProtocol
                vc.handleTick()
            }
        }
    }
}
