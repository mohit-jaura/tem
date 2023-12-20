//
//  EventSlotsTableViewCell.swift
//  TemApp
//
//  Created by dhiraj on 23/07/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
protocol EventSlotsCellDelegate: AnyObject {
    func eventSelect(eventDetail: EventDetail, section: Int)
    func deleteEvent(eventDetail: EventDetail, section: Int)
}

class EventSlotsTableViewCell: UITableViewCell {
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: OwnTableView!
    var slots: [WeekSlot] = []
   weak var delegate: EventSlotsCellDelegate?
    var mainSection = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
extension EventSlotsTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        var height: CGFloat = 0
        for value in self.slots {
            if value.eventList.count > 0 {
                height += CGFloat( value.eventList.count * 85) + 40
            } else {
                height += CGFloat(40)
            }
        }
        self.tableViewHeightConstraint.constant = height
        return self.slots.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WeeklyCell.reuseIdentifier) as? WeeklyCell else {
            return UIView()
        }
        if self.slots.count <= section {
            return nil
        }
        let weekSlots = self.slots[section]
        cell.configureCell(slot: weekSlots, section: section)
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
        view.backgroundColor = .white
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let weekSlots = self.slots[section]
        return weekSlots.eventList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EventCell.reuseIdentifier) as? EventCell else {
            return UITableViewCell()
        }
        if self.slots.count > indexPath.section {
            let slot = self.slots[indexPath.section]
            if slot.eventList.count > indexPath.row {
                let eventDetail = slot.eventList[indexPath.row]
                cell.configureCell(eventDetail)
                cell.dateHeightConstraint.constant = eventDetail.dateNumber == 1 ? 54 : 0
                cell.dateContainerView.isHidden = eventDetail.dateNumber == 1 ? false : true
                cell.dayHeightConstraint.constant =  eventDetail.dateNumber == 1 ? 17 : 0
                cell.dayLbl.isHidden = eventDetail.dateNumber == 1 ? false : true
                cell.seperatorView.isHidden = eventDetail.dateNumber == 1 ? true : false
            }
        }
        cell.layoutIfNeeded()
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.slots.count > indexPath.section {
            let slot = self.slots[indexPath.section]
            if slot.eventList.count > indexPath.row {
                let eventDetail = slot.eventList[indexPath.row]
                delegate?.eventSelect(eventDetail: eventDetail, section: mainSection)
            }
        }
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: AppMessages.NetworkMessages.delete) { _, _ in
            if self.slots.count > editActionsForRowAt.section {
                let slot = self.slots[editActionsForRowAt.section]
                if slot.eventList.count > editActionsForRowAt.row {
                    let eventDetail = slot.eventList[editActionsForRowAt.row]
                    self.delegate?.deleteEvent(eventDetail: eventDetail, section: self.mainSection)
                }
            }
        }
        delete.backgroundColor = UIColor(0xFF6363)
        return [delete]
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if self.slots.count > indexPath.section {
            let slot = self.slots[indexPath.section]
            if slot.eventList.count > indexPath.row {
                let eventDetail = slot.eventList[indexPath.row]
                return eventDetail.eventType == EventType.regular ? true : false
            }
        }
        return false
    }
}
