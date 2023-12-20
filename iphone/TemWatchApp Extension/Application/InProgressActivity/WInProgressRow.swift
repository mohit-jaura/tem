//
//  WInProgressRow.swift
//  TemWatchApp Extension
//
//  Created by Ram on 2020-03-30.
//

import UIKit
import WatchKit

class WInProgressRow: NSObject {
    @IBOutlet weak var cellImageView: WKInterfaceImage!
    @IBOutlet weak var cellTitleLabel: WKInterfaceLabel!
    @IBOutlet weak var cellTimeLabel: WKInterfaceLabel!
}

class WInProgressTimerRow: NSObject {
    @IBOutlet weak var cellImageView: WKInterfaceImage!
    @IBOutlet weak var cellTitleLabel: WKInterfaceLabel!
    @IBOutlet weak var cellTmer: WKInterfaceTimer!
}
