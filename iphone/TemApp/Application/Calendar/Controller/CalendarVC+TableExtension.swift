//
//  CalendarVC+TableExtension.swift
//  TemApp
//
//  Created by debut_mac on 19/01/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation

// MARK: Table Methods
extension CalendarVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if selectedDayEvent == nil || selectedDayEvent?.count == 0 {
            if let noDataFound = Bundle.main.loadNibNamed("NoDataFound", owner: self, options: nil)?.first as? NoDataFound {
                noDataFound.titleGet = "No events found for this day, you can add new event using plus button"
                noDataFound.nameLabel.alpha = 0.7
                noDataFound.tapped = {
                    DispatchQueue.main.async {
                        self.openCreateEventVC()
                    }
                }
                noDataFound.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 200)
                return noDataFound
                
            }
        } else {
            let parentview = UIView(frame: CGRect(x: 0, y:0, width: tableView.frame.width, height: 40))
            let viewS = UIView(frame: CGRect(x: 0, y:40 - 0.7, width: tableView.frame.width, height: 0.7))
            viewS.backgroundColor = UIColor.newAppThemeColor.withAlphaComponent(1)
            parentview.addSubview(viewS)
            return parentview
        }
        return nil
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if selectedDayEvent == nil || selectedDayEvent?.count == 0 {
            return 200
        } else {
            return 40
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedDayEvent?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EventCell.reuseIdentifier) as? EventCell else {
            return UITableViewCell()
        }
        let modal = selectedDayEvent?[indexPath.row]
        cell.tag = indexPath.row
        cell.detailsButton.row = indexPath.row
        cell.configureCell(modal)
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let delete =  UITableViewRowAction(style: .normal, title: AppMessages.NetworkMessages.delete) {[weak self] _, indexSelected in
            DispatchQueue.main.async {
                self?.deleteEvent(eventDetail: self?.selectedDayEvent?[indexSelected.row])
            }
        }
        delete.backgroundColor = UIColor(0xFF6363)
        return [delete]
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didClickOnEventDetails(selectedDayEvent?[indexPath.row])
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let isProgramEvent = selectedDayEvent?[indexPath.row].isProgramEvent, isProgramEvent == 0 {
            return selectedDayEvent?[indexPath.row].eventType == EventType.regular
        }
        return false
    }
}
