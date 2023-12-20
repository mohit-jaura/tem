//
//  StatsViewController+Extension.swift
//  TemApp
//
//  Created by Shiwani Sharma on 14/02/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import UIKit
import Charts


// MARK: UITableViewDelegate,UITableViewDataSource

extension StatsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if statsVM.statsData?.totalActivities.value ?? 0 > 0{
            return statsVM.statsData?.activityCategory?[selectedCategory].activity?.count ?? 0
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: StatsActivitiesTableCell = tableView.dequeueReusableCell(withIdentifier: StatsActivitiesTableCell.reuseIdentifier) as? StatsActivitiesTableCell else {
            return UITableViewCell()
        }
        if statsVM.statsData?.totalActivities.value ?? 0 > 0{
            cell.activityNameLabel.text = statsVM.statsData?.activityCategory?[selectedCategory].activity?[indexPath.row].name
        } else{
            tableView.showEmptyScreen("No activities available")
        }

        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return SliceType(rawValue: selectedCategory).debugDescription
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 40))
        let label = UILabel()
        label.frame = CGRect.init(x: 0, y: 0, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.text = statsVM.statsData?.activityCategory?[selectedCategory].category
        label.textAlignment = .left
        label.font = UIFont(name:"AvenirNext-Medium", size: 24.0)
        label.textColor = .appCyanColor
        headerView.backgroundColor = .black
        headerView.addSubview(label)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if statsVM.statsData?.totalActivities.value ?? 0 > 0{
            return 40
        } else{
            return 0
        }
    }
}

// MARK: ChartViewDelegate
extension StatsViewController: ChartViewDelegate{
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {

        var sliceIndex: Int = 0
        if let dataSet = chartView.data?.dataSets[ highlight.dataSetIndex] {
        sliceIndex = dataSet.entryIndex( entry: entry)
            print( "Selected slice index: \( sliceIndex)")
        }
        let sliceType = SliceType(rawValue: Int(highlight.x) + 1)
        for _ in selectedIndexs{
                selectedCategory = selectedIndexs[sliceIndex]//sliceType?.rawValue ?? 0
        }
        tableView.reloadData()
    }
}
