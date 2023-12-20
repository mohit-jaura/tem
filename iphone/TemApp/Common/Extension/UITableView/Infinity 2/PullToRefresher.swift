//
//  PullToRefresher.swift
//  InfinitySample
//
//  Created by Danis on 15/12/21.
//  Copyright © 2015 Capovela LLC. All rights reserved.
//

import UIKit

public protocol CustomPullToRefreshAnimator {
    func animateState(_ state: PullToRefreshState)
}

public enum PullToRefreshState: Equatable, CustomStringConvertible {
    case none
    case releasing(progress:CGFloat)
    case loading
    
    public var description: String {
        switch self {
        case .none: return "None"
        case .releasing(let progress): return "Releasing: \(progress)"
        case .loading: return "Loading"
        }
    }
}
public func == (left: PullToRefreshState, right: PullToRefreshState) -> Bool {
    switch (left, right) {
    case (.none, .none): return true
    case (.releasing, .releasing): return true
    case (.loading, .loading): return true
    default:
        return false
    }
}

class PullToRefresher: NSObject {
    weak var scrollView: UIScrollView? {
        willSet {
            removeScrollViewObserving(scrollView)
            self.containerView.removeFromSuperview()
        }
        didSet {
            addScrollViewObserving(scrollView)
            if let scrollView = scrollView {
                defaultContentInset = scrollView.contentInset
                
                containerView.scrollView = scrollView
                scrollView.addSubview(containerView)
                containerView.frame = CGRect(x: 0, y: -defaultHeightToTrigger, width: scrollView.frame.width, height: defaultHeightToTrigger)
            }
        }
    }
    var animator: CustomPullToRefreshAnimator
    var containerView: HeaderContainerView
    var action:(() -> Void)?
    var enable = true
    
    // Values
    var defaultContentInset: UIEdgeInsets = UIEdgeInsets()
    var defaultHeightToTrigger: CGFloat = 0
    var scrollbackImmediately = true
    
    init(height: CGFloat, animator: CustomPullToRefreshAnimator) {
        self.defaultHeightToTrigger = height
        self.animator = animator
        self.containerView = HeaderContainerView()
    }
    // MARK: - Observe Scroll View
    var KVOContext = "PullToRefreshKVOContext"
    func addScrollViewObserving(_ scrollView: UIScrollView?) {
        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: .new, context: &KVOContext)
        scrollView?.addObserver(self, forKeyPath: "contentInset", options: .new, context: &KVOContext)
        
    }
    func removeScrollViewObserving(_ scrollView: UIScrollView?) {
        scrollView?.removeObserver(self, forKeyPath: "contentOffset", context: &KVOContext)
        scrollView?.removeObserver(self, forKeyPath: "contentInset", context: &KVOContext)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &KVOContext {
            if keyPath == "contentOffset" {
                guard !updatingState && enable else {
                    return
                }
                let point = (change![NSKeyValueChangeKey.newKey]! as AnyObject).cgPointValue
                let offsetY = (point?.y)! + defaultContentInset.top
                switch offsetY {
                case 0 where state != .loading:
                    state = .none
                case -defaultHeightToTrigger...0 where state != .loading:
                    state = .releasing(progress: min(-offsetY / defaultHeightToTrigger, 1.0))
                case (-CGFloat.greatestFiniteMagnitude)...(-defaultHeightToTrigger) where state == .releasing(progress:1):
                    if scrollView!.isDragging {
                        state = .releasing(progress: 1.0)
                    }else {
                        state = .loading
                    }
                default:
                    break
                }
            }
            else if keyPath == "contentInset" {
                guard !self.scrollView!.lockInset else {
                    return
                }
                self.defaultContentInset = (change![NSKeyValueChangeKey.newKey]! as AnyObject).uiEdgeInsetsValue
            }
            
        }else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    var updatingState = false
    var state: PullToRefreshState = .none {
        didSet {
            self.animator.animateState(state)
            
            switch state {
            case .none where oldValue == .loading:
                if !self.scrollbackImmediately {
                    self.updatingState = true
                    self.scrollView?.setContentInset(self.defaultContentInset, completion: { (_) -> Void in
                        self.updatingState = false
                    })
                }
                
            case .loading where oldValue != .loading:
                
                if !self.scrollbackImmediately {
                    self.updatingState = true
                    var inset = self.defaultContentInset
                    inset.top += self.defaultHeightToTrigger
                    self.scrollView?.setContentInset(inset, completion: { (_) -> Void in
                        self.updatingState = false
                    })
                }
                self.action?()
            default:
                break
            }
        }
    }
    // MARK: - Refresh
    func beginRefreshing() {
        self.scrollView?.setContentOffset(CGPoint(x: 0, y: -(defaultHeightToTrigger + defaultContentInset.top + 1)), animated: true)
    }
    func endRefreshing() {
        self.state = .none
    }
}


class HeaderContainerView: UIView {
    
    var scrollView: UIScrollView?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for view in subviews {
            if UIScreen.main.bounds.width > 320 {
                view.center = CGPoint(x: UIScreen.main.bounds.width/2 - 12 , y: self.bounds.midY)
            }else {
                view.center = CGPoint(x: UIScreen.main.bounds.width/2,  y: self.bounds.midY)
            }
            //view.center = CGPoint(x: UIScreen.main.bounds.width/2, y: self.bounds.midY)
        }
    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.firstResponderViewController()?.automaticallyAdjustsScrollViewInsets = false
    }
}

extension UIView {
    func firstResponderViewController() -> UIViewController? {
        var responder: UIResponder? = self as UIResponder
        while responder != nil {
            if responder!.isKind(of: UIViewController.self) {
                return responder as? UIViewController
            }
            responder = responder?.next
        }
        return nil
    }
}

