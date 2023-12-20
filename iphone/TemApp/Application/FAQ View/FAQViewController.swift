//
//  FAQViewController.swift
//  TemApp
//
//  Created by Mac Test on 27/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit

class FAQViewController: DIBaseController {
    
    // MARK: Variables and Constants
    var selectedQuestion:Int!
    var faqArray:[FaqData] = []
    var refreshControl: UIRefreshControl!
    
    // MARK: IBOutlets
    @IBOutlet weak var faQTableView: UITableView!
    @IBOutlet weak var navigationBarView: UIView!
    
    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addRefreshController()
        self.showLoader()
        getFaqs()
        faQTableView.tableFooterView = UIView()
    }
    
    // MARK: ViewWillAppear.
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
        self.configureNavigation()
    }
    
    // MARK: PrivateFunction.
    // MARK: Set Navigation
    func configureNavigation() {
        self.faQTableView.tableFooterView = UIView()
        let leftBarButtonItem = UIBarButtonItem(customView: getBackButton())
        self.setNavigationController(titleName: Constant.ScreenFrom.faqs.title, leftBarButton: [leftBarButtonItem], rightBarButtom: nil, backGroundColor: UIColor.white, translucent: true)
        self.navigationController?.setDefaultNavigationBar()
    }
    
    // MARK: Functions
    @objc func hideShowCell(sender: UITapGestureRecognizer) {
        selectedQuestion = selectedQuestion == sender.view?.tag ? nil : sender.view?.tag
        if selectedQuestion == 0 {
            showTutorial()
        } else {
            faQTableView.reloadData()
        }
    }
    
    func manageFaqBackground(count:Int) {
        count == 0 ? faQTableView.showEmptyScreen("noFaq".localized) : faQTableView.showEmptyScreen("")
    }
    
    // MARK: AddRefreshController To TableView.
    private func addRefreshController() {
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = appThemeColor
        refreshControl.addTarget(self, action: #selector(refreshTableView(sender:)) , for: .valueChanged)
        faQTableView.addSubview(refreshControl)
    }
    
    // MARK: Function To Refresh News Tableview Data.
    @objc func refreshTableView(sender:AnyObject) {
        faQTableView.viewWithTag(100)?.removeFromSuperview()
        getFaqs()
    }
    
    func showTutorial() {
        let storyboard = UIStoryboard(name: "Tutorial", bundle: nil)
        let controller: UIViewController = storyboard.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
        controller.view.backgroundColor = .clear
        controller.modalPresentationStyle = .overFullScreen
        self.present(controller, animated: false, completion: nil)
    }
}
