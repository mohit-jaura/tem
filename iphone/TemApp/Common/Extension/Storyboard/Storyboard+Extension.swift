//
//  Storyboard+Extension.swift
//  BaseProject
//
//  Created by Aj Mehra on 09/03/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import Foundation

import UIKit
protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}

extension StoryboardIdentifiable where Self: UIViewController {
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
}

extension UIViewController : StoryboardIdentifiable { }

var appDelegate:AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}

extension Data {
    var hexString: String {
        return map { String(format: "%02.2hhx", arguments: [$0]) }.joined()
    }
}

extension UIStoryboard {
    /// The uniform place where we state all the storyboard we have in our application
    enum Storyboard:String {
        case main
        case dashboard
        case activity
        case network
        case profile
        case settings
        case post
        case activitysummary
        case activityedit
        case challenge
        case sidemenu
        case notification
        case calendar
        case reports
        case search
        case chat
        case chatListing
        case creategoalorchallengenew
        case privacy
        case temTv
        case journal
        case foodTrek
        case createevent
        case goalandchallengedetailnew
        case contentMarket
        case affilativeContentBranch
        case payment
        case managecards
        case manageaddress
        case shopping
        case calendarActivity
        case liveStreaming
        case coachingTools
        case todo
        case weightgoaltracker
        var filename:String{
            switch self {
            default: return rawValue.firstCapitalized
            }
        }
    }

    // MARK: - Convenience Initializers

    convenience init(storyboard: Storyboard, bundle: Bundle? = nil) {
        self.init(name: storyboard.filename, bundle: bundle)
    }

    // MARK: - View Controller Instantiation from Generics

    func initVC<T: UIViewController>() -> T {
        guard let vc = self.instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
            fatalError("Couldn't instantiate view controller with identifier \(T.storyboardIdentifier) ")
        }
        return vc
    }
}
