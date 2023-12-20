//
//  DashboardViewController.swift
//  TemApp
//
//  Created by Sourav on 4/19/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

enum PageController:String{
    case activity = "ActivityContoller",homePage = "HomePageViewController",network = "ChatListingViewController"
}

class DashboardViewController: UIPageViewController {
    
    
    // MARK: Variables.....
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [viewController(type: .activity),
                viewController(type: .homePage),
                viewController(type: .network)]
    }()
    
    // MARK: App life Cycle.....
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        dataSource = self
        delegate = self
        setViewControllers([orderedViewControllers[1]],
                           direction: .forward,
                           animated: true,
                           completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateNewDeviceTokenToServer()
        self.navigationController?.navigationBar.isHidden = true
        Defaults.shared.remove(.isActivityRemoved)

    }
    
    // MARK: Private methods.....
    private func viewController(type:PageController) -> UIViewController {
        switch type {
        case .activity:
            let controller:ActivityContoller = UIStoryboard(storyboard: .activity).initVC()
            return controller
        case .homePage:
            let controller:HomePageViewController = UIStoryboard(storyboard: .dashboard).initVC()
            return controller
        case .network:
            let controller:ChatListingViewController = UIStoryboard(storyboard: .chatListing).initVC()
            return controller
        }
    }
    
    func updateNewDeviceTokenToServer() {
        if let token = Defaults.shared.get(forKey: DefaultKey.fcmToken) as? String,
            token != "" {
            //update the new device token to the server
            let params: Parameters = ["device_token": token]
            print("update device token: \(token)")
            DIWebLayerUserAPI().updateDeviceToken(parameters: params)
        }
    }
    
    
}//Class....

extension DashboardViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        return orderedViewControllers[nextIndex]
    }
    
}//Extension....

// MARK: UIPageViewControllerDelegate
extension DashboardViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let controller = pageViewController.viewControllers?.first {
            if let activityController = controller as? ActivityContoller {
                self.handleTabBarForController(vc: activityController, isHidden: true)
            }else if let temsController = controller as? TemsViewController {
                self.handleTabBarForController(vc: temsController, isHidden: true)
            } else if let homeController = controller as? HomePageViewController {
                self.handleTabBarForController(vc: homeController, isHidden: false)
            }
        }
    }
    
    func handleTabBarForController(vc: UIViewController, isHidden: Bool) {
        if let tabBarController = self.tabBarController as? TabBarViewController {
            tabBarController.tabbarHandling(isHidden: isHidden, controller: vc)
        }
    }
} 
