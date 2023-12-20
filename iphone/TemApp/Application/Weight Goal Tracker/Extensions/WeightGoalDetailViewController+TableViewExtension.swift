//
//  WeightGoalDetailViewController+TableViewExtension.swift
//  TemApp
//
//  Created by Mohit Soni on 25/04/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation

extension WeightGoalDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isHealthInfo{
            return viewModal?.modal?.healthLogs?.count ?? 0
        }
        return viewModal?.modal?.weightLogs?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WeightGoalLogTableViewCell = tableView.dequeueReusableCell(withIdentifier: WeightGoalLogTableViewCell.reuseIdentifier, for: indexPath) as? WeightGoalLogTableViewCell else { return UITableViewCell() }
        if isHealthInfo{
            if let data =  viewModal?.modal?.healthLogs {
                cell.setData(data: data[indexPath.row],isHealthGoal: isHealthInfo)
            }
        } else{
            if let data = viewModal?.modal?.weightLogs {
                cell.setData(data: data[indexPath.row],isHealthGoal: isHealthInfo)
            }
        }
        return cell
    }
}
