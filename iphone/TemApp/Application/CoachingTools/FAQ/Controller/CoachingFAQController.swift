//
//  CoachingFAQController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 06/03/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import UIKit

class CoachingFAQController: UIViewController,LoaderProtocol,NSAlertProtocol {

    // MARK: Variables and Constants
    var selectedQuestion:Int!
    var faqsVM = FaqsViewModel()
    var refreshControl: UIRefreshControl!
    var affiliateId = ""

    // MARK: IBOutlets
    @IBOutlet weak var faQTableView: UITableView!

    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showHUDLoader()
        getFaqList()
        faQTableView.tableFooterView = UIView()
        faQTableView.registerNibs(nibNames: [CoachingFAQTableCell.reuseIdentifier])
        faQTableView.registerHeaderFooter(nibNames: [FaqHeaderView.reuseIdentifier])
    }

    // MARK: ViewWillAppear.
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(true)
    }



    // MARK: Functions
    @objc func hideShowCell(sender: UITapGestureRecognizer) {
        selectedQuestion = selectedQuestion == sender.view?.tag ? nil : sender.view?.tag
            faQTableView.reloadData()
    }


    // MARK: Function To Refresh News Tableview Data.
    @objc func refreshTableView(sender:AnyObject) {
        faQTableView.viewWithTag(100)?.removeFromSuperview()
     getFaqList()
    }
    
    private func getFaqList() {
        showHUDLoader()
        faqsVM.getFaqsList(affID: affiliateId, completion: { [weak self] in
            self?.hideHUDLoader()
            if let error = self?.faqsVM.error {
                print(error)
                return
            }
            if self?.faqsVM.faqsList?.count == 0{
                self?.faQTableView.showEmptyScreen("No FAQs added!")
            }
            self?.faQTableView.reloadData()
        })
    }
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}


