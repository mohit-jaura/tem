//
//  WatchExtensions.swift
//  TemWatchApp Extension
//
//  Created by Ram on 2020-04-04.
//

import Foundation
import WatchKit

enum WatchResolution {
    case Watch38mm, Watch40mm,Watch42mm,Watch44mm, Unknown
}

extension WKInterfaceDevice {
class func currentResolution() -> WatchResolution {
    let watch38mmRect = CGRect(x: 0, y: 0, width: 136, height: 170)
    let watch40mmRect = CGRect(x: 0, y: 0, width: 162, height: 197)
    let watch42mmRect = CGRect(x: 0, y: 0, width: 156, height: 195)
    let watch44mmRect = CGRect(x: 0, y: 0, width: 184, height: 224)

    let currentBounds = WKInterfaceDevice.current().screenBounds

    switch currentBounds {
    case watch38mmRect:
        return .Watch38mm
    case watch40mmRect:
        return .Watch40mm
    case watch42mmRect:
        return .Watch42mm
    case watch44mmRect:
        return .Watch44mm
    default:
        return .Unknown
    }
  }
}

extension WKInterfaceController {
    func showLoginAlert(_ message : String, isUserLoggedIn : Bool) {
        let noAction = WKAlertAction(title: "OK", style: WKAlertActionStyle.destructive) {
            print("OK")
            if(!isUserLoggedIn) {
                self.showLoginAlert(message, isUserLoggedIn: isUserLoggedIn)
            }
        }
        DispatchQueue.main.async {
            self.presentAlert(withTitle: "", message: message, preferredStyle: WKAlertControllerStyle.alert, actions:[noAction])
        }
    }
    
    func showAlert(message: String, okTitle: String? = "OK", okAction: @escaping WKAlertActionHandler) {
        let action = WKAlertAction(title: okTitle!, style: .default, handler: okAction)
        presentAlert(withTitle: "", message: message, preferredStyle: WKAlertControllerStyle.alert, actions:[action])
    }
}

extension WKInterfaceImage {
    func loadImage(url:String, forImageView: WKInterfaceImage) {
    // load image
        let image_url:String = url
        DispatchQueue.global(qos: .default).async() {
            let url:URL = URL(string:image_url)!
            if let data:Data? = try? Data(contentsOf: url) {
                let placeholder = UIImage(data: (data ?? nil)!)

    // update ui
            DispatchQueue.main.async { [weak self] in
                // Do task in main queue
                forImageView.setImage(placeholder)
            }
        }
        }
    }
}

extension Double {
    func toInt() -> Int? {
        if self > Double(Int.min) && self < Double(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }
    
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return floor(self*divisor)/divisor
    }

    /// will return the double as formatted with zeroes.
    ///12.0 will return as 12,
    ///12.01 will return as 12.01
    var formatted: String? {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        let number = NSNumber(value: self)
        return formatter.string(from: number)
    }

}

extension String {
    func replace(_ string: String, replacement: String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    var trim: String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

}
