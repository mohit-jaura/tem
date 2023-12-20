//
//  CoachingFAQController+Extension.swift
//  TemApp
//
//  Created by Shiwani Sharma on 06/03/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation

import Foundation
import UIKit

extension CoachingFAQController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return faqsVM.faqsList?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let selectedIndex = selectedQuestion , selectedIndex == section{
            return 1
        }else{
            return 0
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: FaqHeaderView.reuseIdentifier) as? FaqHeaderView else{
            return UITableViewHeaderFooterView()
        }
        headerView.tag = section
        if let list = faqsVM.faqsList{
            headerView.setData(data: list[section])
        }
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hideShowCell(sender:)))
        headerView.addGestureRecognizer(gesture)

        if selectedQuestion != nil{
            if selectedQuestion == section{
               // headerView.footerView.isHidden = true
                headerView.arrowImageView.image = #imageLiteral(resourceName: "UpArrowWhite")
                headerView.questionLabel.textColor = appThemeColor
            }else{
                headerView.questionLabel.textColor = .white
             headerView.arrowImageView.image = #imageLiteral(resourceName: "downarrowWhite")
            }
        }else{
            headerView.questionLabel.textColor = .white
          headerView.arrowImageView.image = #imageLiteral(resourceName: "downarrowWhite")
        }
        return headerView

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell: CoachingFAQTableCell = tableView.dequeueReusableCell(withIdentifier: CoachingFAQTableCell.reuseIdentifier) as? CoachingFAQTableCell else{
            return UITableViewCell()
        }
        if let list = faqsVM.faqsList{
            cell.setData(data: list[indexPath.section])
        }
        return cell
    }
}

