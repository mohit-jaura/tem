//
//  HomeScreenShortcut.swift
//  TemApp
//
//  Created by shilpa on 13/11/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
enum HomeScreenShortCutType: Int, Codable {
    case tem = 1
    case goal = 2
    case challenge = 3
}

struct HomeScreenShortcut: Codable {
    var type: HomeScreenShortCutType?
    var id: String?
    var name: String?
    var status: CustomBool?
    var goalPercent: Double?
    
    static func saveEncodedData(shortcutsArray: [HomeScreenShortcut]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(shortcutsArray) {
            Defaults.shared.set(value: encoded, forKey: .shortcuts)
        }
    }
    
    static func getEncodedData() -> [HomeScreenShortcut]? {
        if let data = Defaults.shared.get(forKey: .shortcuts) as? Data {
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode([HomeScreenShortcut].self, from: data) {
                return decodedData
            }
        }
        return nil
    }
}


/// This protocol is responsible for adding the shortcut button on the screens which confirm to it
@objc protocol ShortCutButtonConfigurable: AnyObject {
    func updateToHomeScreenShortcut(sender: UIButton)
}

extension ShortCutButtonConfigurable where Self: UIViewController {
    func setNavigationItems(statusValue: CustomBool) {
        let groupIcon = UIButton(type: .custom)
        var iconImage = #imageLiteral(resourceName: "honeyUnselected")
        var selectedIconImage = #imageLiteral(resourceName: "honeyUnselected")
        if statusValue == .yes {
            //already added as shortcut
            iconImage = #imageLiteral(resourceName: "honeySelected")
        } else {
            //not added as shortcut
            selectedIconImage = #imageLiteral(resourceName: "honeySelected")
        }
        groupIcon.setImage(iconImage, for: .normal)
        groupIcon.setImage(selectedIconImage, for: .highlighted)
        groupIcon.setImage(selectedIconImage, for: .selected)
        groupIcon.frame = CGRect(x: 0, y: 0, width: 30, height: 44)
        groupIcon.addTarget(self, action: #selector(updateToHomeScreenShortcut(sender:)), for: .touchUpInside)
        let rightBarButtonItem = UIBarButtonItem(customView: groupIcon)
        groupIcon.tag = 1003 //this is just to check if this item is already added or not, in order to prevent duplicacy
        if self.navigationItem.rightBarButtonItems == nil {
            self.navigationItem.rightBarButtonItems = []
        }
        var isItemAlreadyAdded = false
        if let rightButtons = self.navigationItem.rightBarButtonItems {
            for barButton in rightButtons {
                if let customView = barButton.customView as? UIButton,
                    customView.tag == 1003 {
                    //donot add the item again
                    isItemAlreadyAdded = true
                }
            }
        }
        if isItemAlreadyAdded == false {
            self.navigationItem.rightBarButtonItems?.append(rightBarButtonItem)
        }
    }
}


/// This protocol is responsible for handling the action taken on the short cut button on controller
protocol AddToHomeScreenViewable: ShortCutButtonConfigurable {
    var isAddedAsShortcutOnHomeScreen: CustomBool { get set }
    func addOrRemoveFromHomeScreen()
}

extension AddToHomeScreenViewable where Self: DIBaseController {
    func onClickOfShortcut() {
        var confirmationMessage = AppMessages.NetworkMessages.addToHomeScreen
        if isAddedAsShortcutOnHomeScreen == .yes {
            confirmationMessage = AppMessages.NetworkMessages.removeFromHomeScreen
        } else {
            if HomePageViewController.totalShortcutsAdded == 6 {
                self.showAlert(message: AppMessages.NetworkMessages.maximumShortcutsAdded)
                return
            }
        }
        self.showAlert(withTitle: "", message: confirmationMessage, okayTitle: AppMessages.AlertTitles.Yes, cancelTitle: AppMessages.AlertTitles.No, okStyle: .default, okCall: {
            self.addOrRemoveFromHomeScreen()
        }) {
        }
    }
    
    func updateShortCutView() {
        self.isAddedAsShortcutOnHomeScreen = self.isAddedAsShortcutOnHomeScreen.toggle()
        if let barButtonItem = self.navigationItem.rightBarButtonItems?.last,
            let customView = barButtonItem.customView as? UIButton {
            if isAddedAsShortcutOnHomeScreen == .yes {
                customView.setImage(#imageLiteral(resourceName: "honeySelected"), for: .normal)
                customView.setImage(#imageLiteral(resourceName: "honeyUnselected"), for: .highlighted)
                HomePageViewController.totalShortcutsAdded += 1
            } else {
                customView.setImage(#imageLiteral(resourceName: "honeyUnselected"), for: .normal)
                customView.setImage(#imageLiteral(resourceName: "honeySelected"), for: .highlighted)
                if HomePageViewController.totalShortcutsAdded > 0 {
                    HomePageViewController.totalShortcutsAdded -= 1
                }
            }
            NotificationCenter.default.post(name: .homeViewRefresh, object: nil)
        }
    }
}
