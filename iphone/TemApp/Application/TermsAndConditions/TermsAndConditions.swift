//
//  TermsAndConditions.swift
//  Noah
//
//  Created by Harpreet on 03/14/18.
//  Copyright © 2017 Capovela LLC. All rights reserved.

import UIKit
import WebKit
enum PaymentFrom {
    case Content
    case Product
    case Event
    case Stream
    case coachingTools
}
class TermsAndConditions: DIBaseController {
    // MARK: Variables
    var urlString:String = ""
    var navigationTitle:String = ""
    var paymentFrom:PaymentFrom = .Content
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButtonOut: UIButton!
    var isSuccess:BoolCompletion?
    lazy var termsAndConditionsWebView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    // MARK: IBOutlets.
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var webviewBackgroundView: UIView!
    @IBOutlet weak var navigationBarView: UIView!
    
    // MARK: ViewLifeCycle.
    // MARK: ViewDidLoad.
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        self.activityIndicatorView.startAnimating()
        self.addWebView()
        termsAndConditionsWebView.navigationDelegate = self
        
    }
    // MARK: ViewWillAppear.
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func backButAction(_ sender: Any) {
        self.dismiss(animated: true) {
            self.isSuccess?(false)
        }
    }
    
    // MARK: Private Function.
    private func addWebView() {
        self.webviewBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.webviewBackgroundView.addSubview(termsAndConditionsWebView)
        LayoutConstraint.activate([
            termsAndConditionsWebView.topAnchor.constraint(equalTo: self.webviewBackgroundView.topAnchor),
            termsAndConditionsWebView.bottomAnchor.constraint(equalTo: self.webviewBackgroundView.bottomAnchor),
            termsAndConditionsWebView.leadingAnchor.constraint(equalTo: self.webviewBackgroundView.leadingAnchor),
            termsAndConditionsWebView.trailingAnchor.constraint(equalTo: self.webviewBackgroundView.trailingAnchor)
        ])
        self.view.setNeedsLayout()
        self.showcontent()
    }
    
    func showcontent(){
        guard let url = URL(string: urlString) else {return}
        let requestObj = URLRequest(url: url)
        termsAndConditionsWebView.load(requestObj)
    }
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        webView.evaluateJavaScript("document.body.innerText") { result, error in
//            if let resultString = result as? String,
//                resultString.contains("order_id") {
//                    print(resultString)
//                }
//            }
//        }
   
    
    // MARK: Function to set Navigation Bar.
    private func initUI() {
        switch paymentFrom {
        case .Stream:
            backButtonOut.isHidden = false
            titleLabel.isHidden = false
        default:
            _ = configureNavigtion(onView: navigationBarView, title: navigationTitle)
        }
    }
}

// MARK: WKNavigationDelegate


/**
 
 {
     showLoader(status: false)
     webView.evaluateJavaScript("document.body.innerText") { result, error in
             if let resultString = result as? String,
                 resultString.contains("erfolgreich") {
                 self.navigationController?.popToRootViewController(animated: true)
                 }
             }
         }
 
 */

extension TermsAndConditions: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicatorView.stopAnimating()
        webView.evaluateJavaScript("document.body.innerText") { result, error in
            if let resultString = result as? String {
                if resultString.contains("Successfully") || resultString.contains("successfully") {
                    switch self.paymentFrom {
                        case .Product:
                            for controller in self.navigationController!.viewControllers as Array {
                                if controller.isKind(of: ProductListingViewController.self) {
                                    self.navigationController!.popToViewController(controller, animated: true)
                                    break
                                }
                            }

                        case .Event:
                            for controller in self.navigationController!.viewControllers as Array {
                                if controller.isKind(of: EventDetailViewController.self) {
                                    self.navigationController!.popToViewController(controller, animated: true)
                                    break
                                }
                            }
                        case .Stream:
                            self.dismiss(animated: true) {
                                self.isSuccess?(true)
                            }
                        case .Content:
                            self.navigationController?.popToRootViewController(animated: true)

                        case .coachingTools:
                            for controller in self.navigationController!.viewControllers as Array {
                                if controller.isKind(of: CoachingProfileViewController.self) {
                                    self.isSuccess?(true)
                                    self.navigationController!.popToViewController(controller, animated: true)
                                    break
                                }
                            }
                    }
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.activityIndicatorView.stopAnimating()
    }
}
