//
//  AlertBar.swift
//  TemApp
//
//  Created by shilpa on 08/02/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit
public enum AlertBarType {
    case success
    case error
    case notice
    case warning
    case info
    case custom(UIColor, UIColor)
    
    var backgroundColor: UIColor {
        get {
            switch self {
            case .success:
                return UIColor.appThemeColor//UIColor("4CD964")
            case .error:
                return UIColor.red//UIColor("FF3B30")
            case .notice:
                return UIColor.blue//UIColor("2196F3")
            case .warning:
                return UIColor.red//UIColor("FFCC00")
            case .info:
                return UIColor.green//UIColor("009688")
            case .custom(let backgroundColor, _):
                return backgroundColor
            }
        }
    }
    var textColor: UIColor {
        get {
            switch self {
            case .custom(_, let textColor):
                return textColor
            default:
                return UIColor.white
            }
        }
    }
}

class AlertBar: UIView {
    
    static let alertBar = AlertBar()
    public static var textAlignment: NSTextAlignment = .center
    static var alertBars: [AlertBar] = []
    
    let messageLabel = UILabel()
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        messageLabel.frame = CGRect(x: 2, y: 2, width: frame.width - 4, height: frame.height - 4)
        messageLabel.font = UIFont.systemFont(ofSize: 12)
        self.addSubview(messageLabel)
        //NotificationCenter.default.addObserver(self, selector: #selector(self.handleRotate(_:)), name: NSNotification.Name.UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    deinit {
        //NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc dynamic private func handleRotate(_ notification: Notification) {
        self.removeFromSuperview()
        AlertBar.alertBars = []
    }
    class func show(_ type: AlertBarType, message: DIErrorMessage? = .unknown , duration: Double? = 3, completion: (() -> Void)? = nil) {
        AlertBar.show(type, message: message!.rawValue.localized , duration: duration!, completion: completion)
    }
    
    class func unknown() {
        AlertBar.show(.error, message: .unknown, duration: 3, completion: nil)
    }
    
    open class func show(_ type: AlertBarType, message: String? = ErrorMessage.Unknown.message, duration: Double? = 6, completion: (() -> Void)? = nil) {
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60))
        label.numberOfLines = 0
        label.text = message
        label.sizeToFit()
        let statusBarHeight = label.frame.height
        let alertBar = AlertBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: statusBarHeight))
        alertBar.messageLabel.text = message
        alertBar.messageLabel.textAlignment = AlertBar.textAlignment
        alertBar.backgroundColor = type.backgroundColor
        alertBar.messageLabel.numberOfLines = 0
        alertBar.messageLabel.textColor = type.textColor
        AlertBar.alertBars.append(alertBar)
        
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
        let baseView = UIView(frame: UIScreen.main.bounds)
        baseView.isUserInteractionEnabled = false
        baseView.backgroundColor = .clear
        baseView.addSubview(alertBar)
        
        let window: UIWindow
        let orientation = UIApplication.shared.statusBarOrientation
        if orientation.isLandscape {
            window = UIWindow(frame: CGRect(x: 0, y: 0, width: height, height: width))
            let sign: CGFloat = orientation == .landscapeLeft ? -1 : 1
            let d = abs(width - height) / 2
            baseView.transform = CGAffineTransform(rotationAngle: sign * CGFloat.pi / 2).translatedBy(x: sign * d, y: sign * d)
        } else {
            let mainWindow = UIApplication.shared.keyWindow
            var topPadding: CGFloat = 0
            if #available(iOS 11.0, *) {
                topPadding = mainWindow?.safeAreaInsets.bottom ?? 0
                print("top padding ---------- \(topPadding)")
            } else {
                // Fallback on earlier versions
            }
            
//            if mainWindow?.frame.height == 812 {
//                window = UIWindow(frame: CGRect(x:0, y:30, width: width, height: height))
//            }else{
//                window = UIWindow(frame: CGRect(x:0, y:0, width: width, height: height))
//            }
            window = UIWindow(frame: CGRect(x:0, y: topPadding, width: width, height: height))
            if orientation == .portraitUpsideDown {
                baseView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            }
        }
        window.isUserInteractionEnabled = true
        window.windowLevel = UIWindow.Level.statusBar + 1 + CGFloat(AlertBar.alertBars.count)
        window.addSubview(baseView)
        window.makeKeyAndVisible()
        
        alertBar.transform = CGAffineTransform(translationX: 0, y: -statusBarHeight)
        UIView.animate(withDuration: 0.2,
                       animations: { () -> Void in
                        alertBar.transform = CGAffineTransform.identity
        }, completion: { _ in
            UIView.animate(withDuration: 0.2,
                           delay: 3,
                           options: UIView.AnimationOptions(),
                           animations: { () -> Void in
                            alertBar.transform = CGAffineTransform(translationX: 0, y: -statusBarHeight)
            },
                           completion: { (animated: Bool) -> Void in
                            alertBar.removeFromSuperview()
                            if let index = AlertBar.alertBars.firstIndex(of: alertBar) {
                                AlertBar.alertBars.remove(at: index)
                            }
                            // To hold window instance
                            window.isHidden = true
                            completion?()
            })
        })
    }
    
    
    class func getStatusBarLabel(msg: String) {
        if let alertBar = AlertBar.alertBars.last {
            alertBar.messageLabel.text = msg
        }
    }
    
    class func removeStatusBarLabel() {
        for (_, alertBar) in AlertBar.alertBars.enumerated() {
            alertBar.removeFromSuperview()
        }
    }
    
    
    open class func show(error: Error, duration: Double = 4, completion: (() -> Void)? = nil) {
        let code = (error as NSError).code
        let localizedDescription = error.localizedDescription
        self.show(.error, message: "(\(code)) " + localizedDescription, duration: duration, completion: completion)
    }
}
