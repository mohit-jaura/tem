//
//  GoalDetailPageViewController.swift
//  TemApp
//
//  Created by shilpa on 13/06/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

enum GoalDetailTab: Int {
    case progress
    case temates
    case fundraising
}

protocol GoalDetailPageControllerDelegate: AnyObject {
    func didTapOnShareButton()
}

protocol SelectGoalDetailPageDelegate {
    func select(page: GoalDetailTab)
}

class GoalDetailPageViewController: UIPageViewController {
    var goalId: String?

    var goalDetailPageDelegate: GoalDetailPageControllerDelegate?
    var selectGoalDetailPageDelegate: SelectGoalDetailPageDelegate?

    private var tabs: [GoalDetailTab] = []
    private var views: [UIViewController] = []
    private var currentIndex: Int = -1

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func initialize(_ tabs: [GoalDetailTab], _ goal: GroupActivity, _ refresh: RefreshGNCEventDelegate) {
        self.views = tabs.map({ (page) in
            var vc: UIViewController
            if let existingIndex = self.tabs.firstIndex(of: page) {
                vc = self.views[existingIndex]
                if vc.isViewLoaded, let vc = vc as? UpdateGNCEventInfoProtocol {
                    vc.use(goal)
                }
            } else {
                vc = viewController(page, goal, refresh)
            }
            return vc
        })
        self.tabs = tabs
        if currentIndex == -1 {
            self.setCurrentVisibleControllerAt(page: tabs[0])
        }
    }
    
    // MARK: Helpers
    func shareRightBarButtonItemTapped() {
        self.goalDetailPageDelegate?.didTapOnShareButton()
    }
    
    func viewController(_ page: GoalDetailTab, _ goal: GroupActivity, _ refresh: RefreshGNCEventDelegate) -> UIViewController {
        switch page {
        case .progress:
            let vc: GoalProgressViewController = UIStoryboard(storyboard: .challenge).initVC()
            vc.goalId = self.goalId
            vc.goal = goal
            vc.refresh = refresh
            return vc
        case .temates:
            let vc: GoalTematesViewController = UIStoryboard(storyboard: .challenge).initVC()
            vc.goalId = self.goalId
            vc.goal = goal
            vc.refresh = refresh
            return vc
        case .fundraising:
            let vc: FundraisingViewController = UIStoryboard(storyboard: .challenge).initVC()
            vc.eventId = self.goalId
            vc.event = goal
            vc.refresh = refresh
            return vc
        }
    }
    
    func setCurrentVisibleControllerAt(page: GoalDetailTab, animated: Bool = true) {
        if let index = tabs.firstIndex(of: page) {
            let controller = self.views[index]
            let direction: NavigationDirection = self.currentIndex < index ? .forward : .reverse
            setViewControllers([controller], direction: direction, animated: animated) { _ in self.currentIndex = index }
        }
    }
}

// MARK: UIPageViewControllerDaf2taSource
extension GoalDetailPageViewController: UIPageViewControllerDataSource {
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

extension GoalDetailPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished,
           let controller = pageViewController.viewControllers?.first,
           let index = self.views.firstIndex(of: controller) {
            let page = self.tabs[index]
            self.selectGoalDetailPageDelegate?.select(page: page)
            self.currentIndex = index
        }
    }
}

extension GoalDetailPageViewController : UpdateByTimerProtocol {
    func handleTick() {
        for vc in views {
            if vc.isViewLoaded {
                let vc = vc as! UpdateByTimerProtocol
                vc.handleTick()
            }
        }
    }
}
