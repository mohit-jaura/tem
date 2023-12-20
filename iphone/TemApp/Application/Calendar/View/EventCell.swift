//
//  EventCell.swift
//  TemApp
//
//  Created by dhiraj on 10/07/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
protocol EventCellDelegate: AnyObject {
    func didClickOnEventDetails(sender: CustomButton)
}
class EventCell: UITableViewCell {
    // MARK: Properties
    weak var delegate: EventCellDelegate?
    // MARK: IBOutlets
    @IBOutlet weak var programEventLabel: UILabel!
    @IBOutlet weak var dateHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateContainerView: UIView!
    @IBOutlet weak var dayHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var timeSlotLbl: UILabel!
    @IBOutlet weak var activityTypeImgVw: UIImageView!
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var eventView: UIView!
    @IBOutlet weak var outerShadowView: SSNeumorphicView! {
        didSet {
            outerShadowView.viewDepthType = .outerShadow
            outerShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.6).cgColor
            outerShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.1).cgColor
            outerShadowView.viewNeumorphicMainColor = UIColor.newAppThemeColor.cgColor
            outerShadowView.viewNeumorphicCornerRadius = 4.0
            outerShadowView.viewNeumorphicShadowOpacity = 1
        }
    }
    @IBOutlet weak var detailsButton: CustomButton!
    // MARK: IBActions
    @IBAction func eventDetailsTapped(sender: CustomButton) {
        self.delegate?.didClickOnEventDetails(sender: sender)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    func dayDifference(start:Date,end:Date) -> Int {
        if let day = Calendar.current.dateComponents([.day], from: start, to: end).day {
            return day
        }
        return 0
    }
    func configureCell(_ eventDetail: EventDetail?) {
        guard let eventDetail = eventDetail else {return}
        var title = ""
        let eventDuration = dayDifference(start: eventDetail.eventStartDate.startOfDay, end: eventDetail.eventEndDate.startOfDay)
        let dayGap = eventDetail.dateNumber

        if eventDuration > 1 {
            title = " (Day \(dayGap+1)/\(eventDuration+1))"
        }
        var eventTitle = eventDetail.name ?? ""
        
        if (eventDetail.eventType == .regular || eventDetail.eventType == .signupSheet) {
            eventTitle = eventDetail.title ?? ""
        }
        
        let timeSlotText = getEventDates(eventDetail)
        
        dateLbl.text = "\(self.tag + 1)"
        
        DispatchQueue.main.async {
            let memberInfo = eventDetail.members?.first(where: ({($0.userId == User.sharedInstance.id || $0.memberId == User.sharedInstance.id)}))
            
            self.setUpViewColor(color: UIColor.white, bgColor: UIColor.white)
            self.timeSlotLbl.text = timeSlotText
            
            let createdDate = eventDetail.startsOn?.toDate(dateFormat: .displayDate)
            let startDate = eventDetail.eventStartDate.date
           
            let dayDifference = abs(self.dayDifference(start: createdDate?.dateTruncated(from: .hour) ?? Date(),end: startDate.dateTruncated(from: .hour) ?? Date()) )
            if eventDetail.reccurEvent ?? 0 > 0{
              self.titleLbl.text = "\(eventTitle) (Day: \(eventDetail.currentRecurringDay ?? 0))".capitalized
          }
            else{
                self.titleLbl.text = eventTitle.capitalized
            }
            self.activityTypeImgVw.image = eventDetail.eventType?.getImages().white
            if eventDetail.isProgramEvent == 1 { // 1 indicates the program event
                self.programEventLabel.isHidden = false
                self.activityTypeImgVw.image = UIImage(named: "eventProgram")
                self.timeSlotLbl.text = String(timeSlotText.prefix(8))
            } else{
                self.programEventLabel.isHidden = true
            }
        }
    }
    private func setUpViewColor(color: UIColor, bgColor: UIColor) {
        titleLbl.textColor = color
        timeSlotLbl.textColor = color
    }
    private func getEventSlots(_ eventDetail: EventDetail) -> (startDate: Date?, endDate: Date?) {
        let utcFormatter = Utility.timeZoneDateFormatter(format: .utcDate, timeZone: utcTimezone)
        let startDate = utcFormatter.date(from: eventDetail.sDateTime ?? "")
        let endDate = utcFormatter.date(from: eventDetail.eDateTime ?? "")
        return (startDate, endDate)
    }
    private func getEventDates(_ eventDetail: EventDetail) -> String {
        let startDate = eventDetail.eventStartDate
        let endDate = eventDetail.eventEndDate
        let localFormatter = Utility.timeZoneDateFormatter(format: .timeHM)
        let startDateString = localFormatter.string(from: startDate )
        let endDateString = localFormatter.string(from: endDate )
        return startDateString + " - " + endDateString
    }
}
extension String {
    func strikeThrough() -> NSAttributedString {
        let attributeString =  NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributeString.length))
        return attributeString
    }
}
