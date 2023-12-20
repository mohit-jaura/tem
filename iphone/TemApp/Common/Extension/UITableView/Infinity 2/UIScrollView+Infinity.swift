//
//  UIScrollView+Infinity.swift
//  InfinitySample
//
//  Created by Danis on 15/12/21.
//  Copyright © 2015 Capovela LLC. All rights reserved.
//

import UIKit

private var associatedPullToRefresherKey: String  = "InfinityPullToRefresherKey"
private var associatedInfiniteScrollerKey: String = "InfinityInfiniteScrollerKey"

private var associatedEnablePullToRefreshKey: String = "InfinityEnablePullToRefreshKey"
private var associatedEnableInfiniteScrollKey: String = "InfinityEnableInfiniteScrollKey"

// MARK: - PullToRefresh
extension UIScrollView {

    public func addPullToRefresh(_ height: CGFloat = 60.0, animator: CustomPullToRefreshAnimator, action:(() -> Void)?) {
        
        bindPullToRefresh(height, toAnimator: animator, action: action)
        self.pullToRefresher?.scrollbackImmediately = false
        
        if let animatorView = animator as? UIView {
            self.pullToRefresher?.containerView.addSubview(animatorView)
        }
        
    }
    public func bindPullToRefresh(_ height: CGFloat = 60.0, toAnimator: CustomPullToRefreshAnimator, action:(() -> Void)?) {
        removePullToRefresh()
        
        self.pullToRefresher = PullToRefresher(height: height, animator: toAnimator)
        self.pullToRefresher?.scrollView = self
        self.pullToRefresher?.action = action
    }
    public func removePullToRefresh() {
        self.pullToRefresher?.scrollView = nil
        self.pullToRefresher = nil
    }
    public func beginRefreshing() {
        self.pullToRefresher?.beginRefreshing()
    }
    public func endRefreshing() {
        self.pullToRefresher?.endRefreshing()
    }
    
    // MARK: - Properties
    var pullToRefresher: PullToRefresher? {
        get {
            return objc_getAssociatedObject(self, &associatedPullToRefresherKey) as? PullToRefresher
        }
        set {
            objc_setAssociatedObject(self, &associatedPullToRefresherKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    public var enablePullToRefresh: Bool? {
        get {
            return pullToRefresher?.enable
        }
        set {
            if let newValue = newValue {
                pullToRefresher?.enable = newValue
            }
        }
    }
    public var scrollToTopImmediately: Bool? {
        get {
            return pullToRefresher?.scrollbackImmediately
        }
        set {
            if let newValue = newValue {
                pullToRefresher?.scrollbackImmediately = newValue
            }
        }
    }
}

// MARK: - InfiniteScroll
extension UIScrollView {
    
    public func addInfiniteScroll(_ height: CGFloat = 80.0, animator: CustomInfiniteScrollAnimator, action: (() -> Void)?) {
        
        bindInfiniteScroll(height, toAnimator: animator, action: action)
        
        if let animatorView = animator as? UIView {
            self.infiniteScroller?.containerView.addSubview(animatorView)
        }
    }
    public func bindInfiniteScroll(_ height: CGFloat = 80.0, toAnimator: CustomInfiniteScrollAnimator, action: (() -> Void)?) {
        removeInfiniteScroll()
        
        self.infiniteScroller = InfiniteScroller(height: height, animator: toAnimator)
        self.infiniteScroller?.scrollView = self
        self.infiniteScroller?.action = action
    }
    public func removeInfiniteScroll() {
        self.infiniteScroller?.scrollView = nil
        self.infiniteScroller = nil
    }
    public func beginInfiniteScrolling() {
        self.infiniteScroller?.beginInfiniteScrolling()
    }
    public func endInfiniteScrolling() {
        self.infiniteScroller?.endInfiniteScrolling()
    }
    
    // MARK: - Properties
    var infiniteScroller: InfiniteScroller? {
        get {
            return objc_getAssociatedObject(self, &associatedInfiniteScrollerKey) as? InfiniteScroller
        }
        set {
            objc_setAssociatedObject(self, &associatedInfiniteScrollerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var infiniteStickToContent: Bool? {
        get {
            return self.infiniteScroller?.stickToContent
        }
        set {
            if let newValue = newValue {
                self.infiniteScroller?.stickToContent = newValue
            }
        }
    }
    public var enableInfiniteScroll: Bool? {
        get {
            return infiniteScroller?.enable
        }
        set {
            if let newValue = newValue {
                infiniteScroller?.enable = newValue
            }
        }
    }
}

private let NavigationBarHeight: CGFloat = 64
private let StatusBarHeight: CGFloat = 20
private let TabBarHeight: CGFloat = 49

public enum InfinityInsetTopType {
    case none
    case navigationBar
    case statusBar
    case custom(height: CGFloat)
}
public enum InfinityInsetBottomType {
    case none
    case tabBar
    case custom(height: CGFloat)
}

extension UIScrollView {
    public func setInsetType(withTop top: InfinityInsetTopType, bottom: InfinityInsetBottomType) {
        var insetTop: CGFloat = 0
        var insetBottom: CGFloat = 0
        
        switch top {
        case .none:
            break
        case .statusBar:
            insetTop = StatusBarHeight
        case .navigationBar:
            insetTop = NavigationBarHeight
        case .custom(let height):
            insetTop = height
        }
        switch bottom {
        case .none:
            break
        case .tabBar:
            insetBottom = TabBarHeight
        case .custom(let height):
            insetBottom = height
        }
        self.contentInset = UIEdgeInsets(top: insetTop, left: 0, bottom: insetBottom, right: 0)
    }
}

private var associatedSupportSpringBouncesKey:String = "InfinitySupportSpringBouncesKey"
private var associatedLockInsetKey: String           = "InfinityLockInsetKey"

extension UIScrollView {
    public var supportSpringBounces: Bool {
        get {
             let support = objc_getAssociatedObject(self, &associatedSupportSpringBouncesKey) as? Bool
            if support == nil {
                return false
            }
            return support!
        }
        set {
            objc_setAssociatedObject(self, &associatedSupportSpringBouncesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var lockInset: Bool {
        get {
            let locked = objc_getAssociatedObject(self, &associatedLockInsetKey) as? Bool
            if locked == nil {
                return false
            }
            return locked!
        }
        set {
            objc_setAssociatedObject(self, &associatedLockInsetKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    func setContentInset(_ inset: UIEdgeInsets, completion: ((Bool) -> Void)?) {
        if self.supportSpringBounces {
            
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: { () -> Void in
                
                self.lockInset = true
                self.contentInset = inset
                self.lockInset = false
                
                }, completion: completion)
            
        }else {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: { () -> Void in
                
                self.lockInset = true
                self.contentInset = inset
                self.lockInset = false

                }, completion: { (finished) -> Void in
                    
                    completion?(finished)
            })
        }
    }
}
