//
//  ContentMarketPageViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 11/04/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//
import UIKit

protocol UpdateViewsDelegate{
    func updateViews(index: Int)
}

class ContentMarketPageViewController: UIPageViewController {
    
    // MARK: Variables
    var id = ""
    weak var tutorialDelegate: TutorialPageViewControllerDelegate?
    var prevIndex: Int = 1
    var updateViewsDelegate: UpdateViewsDelegate?
    var pageControl = CustomPageControl()
    var affiliateId = ""
    var isPlanAdded = 0
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        // The view controllers will be shown in this order
        if isPlanAdded == 0{ // Content is free
            return [self.newViewController("AffiliateLanding"),
                self.newViewController("AffilativeContentVC"),
                self.newViewController("AffilativeCommunityVC")
                ]
        } // Content is not free
        return [self.newViewController("AffiliateLanding"),
            self.newViewController("AffilativeContentVC"),
            self.newViewController("AffilativeCommunityVC"),
                self.newViewController("ActivePaymentViewController")]

    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        if let initialViewController = orderedViewControllers.first {
            scrollToViewController(viewController: initialViewController)
        }
        tutorialDelegate?.tutorialPageViewController(tutorialPageViewController: self, didUpdatePageCount: orderedViewControllers.count)
        configurePageControl()
        checkHostLive()
    }

    func checkHostLive(){
        Stream.connect.toServer(affiliateId, false, nil, {[weak self] isStreamOn, modal in
            DispatchQueue.main.async {
                Stream.connect.showHeader(modal: modal)
            }
        })
    }
    
    func scrollToNextViewController(controllerIndex: Int) {
        var controller = orderedViewControllers[0]
        for value in 0 ... orderedViewControllers.count{
            if value == controllerIndex{
                controller = orderedViewControllers[value]
            }
        }
        switch controllerIndex{
        case 0:
            scrollToViewController(viewController: controller,direction: self.direction(for: 0))
            self.prevIndex = 0
        case 1:
            scrollToViewController(viewController: controller,direction: self.direction(for: 1))
            self.prevIndex = 1
        case 2:
            scrollToViewController(viewController: controller,direction: self.direction(for: 2))
            self.prevIndex = 2
        default:
            break
            
        }
    }
    private func direction(for index: Int) -> UIPageViewController.NavigationDirection {
        return index > self.prevIndex ? .forward : .reverse
    }
    
    func scrollToViewController(index newIndex: Int) {
        if let firstViewController = viewControllers?.first,
           let currentIndex = orderedViewControllers.firstIndex(of: firstViewController) {
            let direction: UIPageViewController.NavigationDirection = newIndex >= currentIndex ? .forward : .reverse
            let nextViewController = orderedViewControllers[newIndex]
            scrollToViewController(viewController: nextViewController, direction: direction)
        }
    }
    
    
    func newViewController(_ name: String) -> UIViewController {
        if name == "AffiliateLanding" {
            let vc = UIStoryboard(name: "ContentMarket", bundle: nil) .
            instantiateViewController(withIdentifier: "\(name)ViewController")
            if vc.restorationIdentifier == "AffiliateLandingViewController" {
                let newVC:AffiliateLandingViewController = UIStoryboard(storyboard: .contentMarket).initVC()
                newVC.marketPlaceId = self.id
                newVC.affiliateId = self.affiliateId
                return newVC
            }
            return vc
        } else if name == "AffilativeContentVC" {
            let vc = UIStoryboard(name: "AffilativeContentBranch", bundle: nil) .
            instantiateViewController(withIdentifier: "AffilativeContentVC")
            if vc.restorationIdentifier == "AffilativeContentVC" {
                let newVC:AffilativeContentVC = UIStoryboard(storyboard: .affilativeContentBranch).initVC()
                newVC.marketPlaceId = self.id
                return newVC
            }
            return vc
        } else if name == "AffilativeCommunityVC" {
            let vc = UIStoryboard(name: "AffilativeContentBranch", bundle: nil) .
            instantiateViewController(withIdentifier: "AffilativeCommunityVC")
            if vc.restorationIdentifier == "AffilativeCommunityVC" {
                let newVC:AffilativeCommunityVC = UIStoryboard(storyboard: .affilativeContentBranch).initVC()
                newVC.marketPlaceId = self.affiliateId
                return newVC
            }
            return vc
        }else {
            let vc = UIStoryboard(name: "Payment", bundle: nil) .
            instantiateViewController(withIdentifier: "\(name)")
            let newVC:ActivePaymentViewController = UIStoryboard(storyboard: .payment).initVC()
            newVC.affiliateID = self.affiliateId
            return newVC
        }
    }
    
    private func scrollToViewController(viewController: UIViewController,
                                        direction: UIPageViewController.NavigationDirection = .forward) {
        setViewControllers([viewController],
                           direction: direction,
                           animated: true,
                           completion: { (_) -> Void in
           self.notifyTutorialDelegateOfNewIndex()
        })
    }
    
    private func notifyTutorialDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first,
           let index = orderedViewControllers.firstIndex(of: firstViewController) {
            tutorialDelegate?.tutorialPageViewController(tutorialPageViewController: self, didUpdatePageIndex: index)
        }
    }
    func configurePageControl() {
        pageControl = CustomPageControl(frame: CGRect(x: 0,y: 100,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.currentPage = 0
        pageControl.isEnabled = false
        self.view.addSubview(pageControl)
    }
}

// MARK: UIPageViewControllerDataSource

extension ContentMarketPageViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = orderedViewControllers.firstIndex(of: pageContentViewController)!
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
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
        
        updateViewsDelegate?.updateViews(index: previousIndex)
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
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
        updateViewsDelegate?.updateViews(index: nextIndex)
        return orderedViewControllers[nextIndex]
    }
    
}

extension ContentMarketPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        notifyTutorialDelegateOfNewIndex()
    }
}

protocol TutorialPageViewControllerDelegate: AnyObject {
    
    /**
     Called when the number of pages is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter count: the total number of pages.
     */
    func tutorialPageViewController(tutorialPageViewController: ContentMarketPageViewController,
                                    didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func tutorialPageViewController(tutorialPageViewController: ContentMarketPageViewController,
                                    didUpdatePageIndex index: Int)
    
}

class CustomPageControl: UIPageControl {
    var currentPageImage: UIImage {
        return UIImage(named: "Oval Copy 12")!// Image you want to replace with dots
    }
    var otherPagesImage: UIImage {
        
        return UIImage(named: "Oval Copy 14")! //Default Image
    }
    
    override var numberOfPages: Int {
        didSet {
            updateDots()
        }
    }
    
    override var currentPage: Int {
        didSet {
            updateDots()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if #available(iOS 14.0, *) {
            defaultConfigurationForiOS14AndAbove()
        } else {
            pageIndicatorTintColor = .clear
            currentPageIndicatorTintColor = .clear
            clipsToBounds = false
        }
    }
    private func defaultConfigurationForiOS14AndAbove() {
        if #available(iOS 14.0, *) {
            for index in 0..<numberOfPages {
                let image = index == currentPage ? currentPageImage : otherPagesImage
                setIndicatorImage(image, forPage: index)
            }
            
            pageIndicatorTintColor = #colorLiteral(red: 0.5333333333, green: 0.5294117647, blue: 0.5294117647, alpha: 1)
            currentPageIndicatorTintColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
            
        }
    }
    private func updateDots() {
        if #available(iOS 14.0, *) {
            defaultConfigurationForiOS14AndAbove()
        } else {
            for (index, subview) in subviews.enumerated() {
                subview.frame = CGRect(x: 0, y: 0, width: CGFloat(numberOfPages * 4), height: CGFloat(numberOfPages * 4))
                subview.layer.backgroundColor = currentPage == index ? #colorLiteral(red: 0, green: 0.1490196078, blue: 0.2509803922, alpha: 1) : #colorLiteral(red: 0.5333333333, green: 0.5294117647, blue: 0.5294117647, alpha: 1)
                subview.layer.cornerRadius = subview.frame.height / 2
                subview.clipsToBounds = false
            }
        }
    }
    
    private func getImageView(forSubview view: UIView) -> UIImageView? {
        if let imageView = view as? UIImageView {
            return imageView
        } else {
            let view = view.subviews.first { (view) -> Bool in
                return view is UIImageView
            } as? UIImageView
            
            return view
        }
    }
}
