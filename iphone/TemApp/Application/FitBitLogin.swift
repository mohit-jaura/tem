//
//  FitBitLogin.swift
//  TemApp
//
//  Created by Harpreet_kaur on 01/07/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import WebKit
@objc class FitBitLogin: DIBaseController {

    // MARK: Variables.
    var urlString:String?
    var activityView:UIActivityIndicatorView?
    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    // MARK: IBOutlets
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var webBackgroudView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityView = UIActivityIndicatorView(style: .whiteLarge)
        self.activityView?.center = self.view.center
        self.activityView?.color = .gray
        self.activityView?.startAnimating()
        self.view.addSubview(activityView ?? UIActivityIndicatorView())
        self.addWebView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigation()
        self.navigationController?.navigationBar.isHidden = false
        if let tabBarController = self.tabBarController as? TabBarViewController {
            tabBarController.tabbarHandling(isHidden: true, controller: self)
        }
    }
    
    // MARK: Helpers
    func configureNavigation() {
        let leftBarButtonItem = UIBarButtonItem(customView: getBackButton())
        self.setNavigationController(titleName: Constant.ScreenFrom.fitbitLogin.title, leftBarButton: [leftBarButtonItem], rightBarButtom: nil, backGroundColor: UIColor.white, translucent: true)
        self.navigationController?.setDefaultNavigationBar()
    }
    
    private func addWebView() {
        self.webBackgroudView.translatesAutoresizingMaskIntoConstraints = false
        self.webBackgroudView.addSubview(webView)
        LayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: self.webBackgroudView.topAnchor),
            webView.bottomAnchor.constraint(equalTo: self.webBackgroudView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: self.webBackgroudView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: self.webBackgroudView.trailingAnchor)
        ])
        self.view.setNeedsLayout()
        self.showcontent()
    }
    
    func showcontent(){
        if let urlStr = urlString {
            guard let url = URL(string: urlStr) else {return}
            let requestObj = URLRequest(url: url)
            webView.load(requestObj)
        }
    }
}

extension FitBitLogin : SFSafariViewControllerDelegate {
    
}

// MARK: WKNavigationDelegate
extension FitBitLogin: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityView?.removeFromSuperview()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.activityView?.removeFromSuperview()
    }
}
