//
//  JournalListingTableViewCell.swift
//  TemApp
//
//  Created by Mohit Soni on 01/02/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class JournalListingTableViewCell: UITableViewCell {

    
    // MARK: - IBOutlets

    @IBOutlet weak var journalDateLabel:UILabel!
    @IBOutlet weak var journalRateLabel:UILabel!
    // MARK: - Properties
    
    // MARK: - Nib Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    // MARK: - Methods

    func configureCell(journalData: JournalList){
        let timeStamp = journalData.date
        let date = timeStamp.toDate
        self.journalDateLabel.text = date.toString(inFormat: .displayDate)
    }

    func configureCellforHistoryNotes(date: Date) {
        self.journalDateLabel.text = Utility.timeZoneDateFormatter(format: .ratingDate, timeZone: utcTimezone).string(from: date)
    }
}
