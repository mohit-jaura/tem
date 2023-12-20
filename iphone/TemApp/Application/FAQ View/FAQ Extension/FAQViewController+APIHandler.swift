//
//  FAQViewController+APIHandler.swift
//  TemApp
//
//  Created by Mac Test on 27/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
extension FAQViewController{
    
    //This function will fetch all FAQ's from server
    func getFaqs(){
        guard Reachability.isConnectedToNetwork() else {
            faQTableView.showEmptyScreen(AppMessages.AlertTitles.noInternet)
            return
        }
        refreshControl.endRefreshing()
        self.hideLoader()
        SettingsAPI().getFaqs(success: { (data) in
            self.refreshControl.endRefreshing()
            self.faqArray = data
            self.faQTableView.reloadData()
        }) { (error) in
            self.hideLoader()
            self.refreshControl.endRefreshing()
            self.showAlert(message:error.message)
        }
        
    }
}

