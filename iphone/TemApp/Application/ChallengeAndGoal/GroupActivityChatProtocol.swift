//
//  GroupActivityChatProtocol.swift
//  TemApp
//
//  Created by shilpa on 01/06/20.
//

import Foundation

protocol GroupActivityChatDelegate: AnyObject {
    func updateMuteStatusInGroupActivity(newValue: CustomBool)
}
