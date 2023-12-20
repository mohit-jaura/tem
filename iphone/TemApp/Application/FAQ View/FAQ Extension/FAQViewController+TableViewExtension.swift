//
//  FAQViewController+TableViewExtension.swift
//  TemApp
//
//  Created by Mac Test on 27/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit

extension FAQViewController:UITableViewDelegate,UITableViewDataSource {
    
    // MARK: TableView Delegates and Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return faqArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let selectedIndex = selectedQuestion , selectedIndex == section{
            return 1
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let str:[String] = faqArray[indexPath.section].image
        if str.count > 0 {
            return 300
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell:FaqTableViewCell = (faQTableView.dequeueReusableCell(withIdentifier: FaqTableViewCell.reuseIdentifier) as! FaqTableViewCell)
        cell.title.text = faqArray[section].heading
        cell.tag = section
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hideShowCell(sender:)))
        cell.addGestureRecognizer(gesture)
        
        if selectedQuestion != nil{
            if selectedQuestion == section{
                cell.footerView.isHidden = true
                cell.dropDounButton.image =  #imageLiteral(resourceName: "right-arrow-up")
                cell.title.textColor = appThemeColor
            }else{
                cell.title.textColor = .black
                cell.dropDounButton.image =  #imageLiteral(resourceName: "arrowDown")
            }
        }else{
            cell.dropDounButton.image = #imageLiteral(resourceName: "arrowDown")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell:FaqAnswerTableViewCell = faQTableView.dequeueReusableCell(withIdentifier: FaqAnswerTableViewCell.reuseIdentifier) as? FaqAnswerTableViewCell else {
            return UITableViewCell()
        }
        
        let str:[String] = faqArray[indexPath.section].image
        
        if str.count > 0 {
            print("======12 ",str[0])
            if let imageUrl = URL(string:str[0] ) {
                cell.imagView.kf.setImage(with: imageUrl, placeholder:#imageLiteral(resourceName: "user-dummy"))
            }
        } else {
            cell.imagView?.image = nil
        }
        let modifiedFont = String(format:"<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: \(cell.answerLabel.font!.pointSize)\">%@</span>", faqArray[indexPath.section].desc ?? "")
        cell.answerLabel.attributedText = modifiedFont.html2String
        return cell
    }
}

