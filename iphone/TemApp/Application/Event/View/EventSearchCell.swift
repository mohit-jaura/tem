//
//  EventCell.swift
//  TemApp
//
//  Created by Egor Shulga on 26.04.21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import Foundation
import SwiftDate

class EventSearchCell : UITableViewCell {
    private var item: EventDetail?
    private var delegate: EventSearchDelegate?
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var endDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        content.addGestureRecognizer(tap)
    }

    @objc func onTap(_ sender: Any) {
        guard let item = item else { return }
        let vc: EventDetailViewController = UIStoryboard(storyboard: .calendar).initVC()
        vc.delegate = self
        vc.eventDetail = item
        vc.eventId = item.id ?? ""
        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func use(_ item: EventDetail, _ delegate: EventSearchDelegate) {
        self.delegate = delegate
        use(item)
    }

    private func use(_ item: EventDetail) {
        self.item = item
        title.text = item.title
        startDate.text = DateInRegion(item.eventStartDate).convertTo(calendar: nil, timezone: TimeZone.current, locale: nil).toString(.dateTimeMixed(dateStyle: .medium, timeStyle: .short))
        endDate.text = DateInRegion(item.eventEndDate).convertTo(calendar: nil, timezone: TimeZone.current, locale: nil).toString(.dateTimeMixed(dateStyle: .medium, timeStyle: .short))
        if item.eventType != .signupSheet {
            icon.image = #imageLiteral(resourceName: "act")
        } else {
            icon.image = #imageLiteral(resourceName: "TaskStroke")
        }
    }
}

extension EventSearchCell : EventDelegate {
    func backTapped() {
    }
    
    func updateEvent(editMode: EditRecurringEventMode, eventDetail: EventDetail?, section: Int) {
        guard let item = eventDetail else { return }
        use(item)
        delegate?.eventListUpdated()
    }
    
    func updateEventList(section: Int, eventID: String) {
        delegate?.eventListUpdated()
    }
    
    func deleteEvent(section: Int, eventId: String, deleteType: DeleteEventType) {
        delegate?.deleteEvent(id: eventId)
    }
}
