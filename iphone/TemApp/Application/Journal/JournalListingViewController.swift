//
//  JournalListingViewController.swift
//  TemApp
//
//  Created by Mohit Soni on 01/02/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

class JournalListingViewController: DIBaseController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var shadowView: UIView!
    
    // MARK: - Properties
    
    var journalsList:[JournalList] = [JournalList]()
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initUI()
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(true)
        self.initUI()
    }
    
    // MARK: - IBActions
    @IBAction func backButtonTapped(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func todayBtnTapped(_ sender:UIButton){
        let createJournalVC:CreateJournalViewController = UIStoryboard(storyboard: .journal).initVC()
        createJournalVC.journalList = self.sortJournalByDate(journals: self.journalsList)
        self.navigationController?.pushViewController(createJournalVC, animated: true)
    }
    
    // MARK: - Methods
    
    private func initUI(){
        self.tableView.isSkeletonable = true
        self.getJournalsData()
        shadowView.addShadowToView()
        self.navigationController?.navigationBar.isHidden = true
    }
    

    
    private func getJournalsData(){
        let isNetworkAvailable = self.isConnectedToNetwork()
        if isNetworkAvailable{
            self.showLoader()
            DIWebLayerJournalAPI().getJournalListing { (data) in
                self.hideLoader()
                let fileredData = data.filter({$0.rating == 0}) // Only show the journal data not rating data
                self.journalsList = self.sortAllJournalByDate(journals: fileredData)
                self.tableView.reloadData()
            } failure: { (error) in
                self.hideLoader()
                print("error\(error)")
            }
        }
        else{
            self.showAlert(message: AppMessages.AlertTitles.noInternet)
        }
    }
    
    private func isConnectedToNetwork() -> Bool {
        if !Reachability.isConnectedToNetwork() {
            AlertBar.show(.error, message: AppMessages.AlertTitles.noInternet, duration: 2.0) {
                print("alert displayed")
            }
            return false
        }
        return true
    }

    private func sortJournalByDate(journals: [JournalList]) -> JournalList?{
        if journals.count > 0{
            let sortedData = journals.sorted(by: {$0.date.toDate > $1.date.toDate })
                return sortedData[0]
        }
        else{
            return nil
        }
    }
    
    private func sortAllJournalByDate(journals: [JournalList]) -> [JournalList]{
        if journals.count > 0{
            let sortedData = journals.sorted(by: {$0.date.toDate > $1.date.toDate })
                return sortedData
        }
        else{
            return journals
        }
    }
}

// MARK: - Extensions

extension JournalListingViewController:UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.journalsList.count > 0{
            return journalsList.count
        }
            return 0

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: JournalListingTableViewCell.reuseIdentifier, for: indexPath) as! JournalListingTableViewCell
        if self.journalsList.count > 0{
            cell.configureCell(journalData: self.journalsList[indexPath.row])
            cell.isUserInteractionEnabled = true
            self.tableView.showEmptyScreen("")
        }else{
            self.tableView.showEmptyScreen("No journals added yet!",isWhiteBackground: true)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let createJournalVC:CreateJournalViewController = UIStoryboard(storyboard: .journal).initVC()
        createJournalVC.journalList = self.journalsList[indexPath.row]
        createJournalVC.isForDetail = true
        self.navigationController?.pushViewController(createJournalVC, animated: true)
    }
}
