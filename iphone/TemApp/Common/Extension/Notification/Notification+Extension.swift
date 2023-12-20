//
//  Notification+Extension.swift
//  TemApp
//
//  Created by shilpa on 26/02/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
extension Notification.Name {
    static let postUploaded = Notification.Name("postUploaded")
    static let postUploadingError = Notification.Name("postUploadingError")
    static let postUploadInProgress = Notification.Name("postUploadInProgress")
    static let goalCompleted = Notification.Name("goalCompleted")
    static let chatCleared = Notification.Name("chatCleared")
    static let removeFirestoreListeners = Notification.Name("removeFirestoreListeners")
    static let outputVolumeChanged = Notification.Name("outputVolumeChanged")
    static let stopStepsUpdateTimer = Notification.Name("stopStepsUpdateTimer")
    static let exitedFromGroup = Notification.Name("exitedFromGroup")
    static let joinedGroup = Notification.Name("joinedGroup")
    static let groupDeleted = Notification.Name("groupDeleted")
    static let goalAsPostUpload = Notification.Name("goalAsPostUpload")
    static let activityJoined = Notification.Name("activityJoined")
    //    static let newPushArrived = Notification.Name("newPushArrived")
    static let notificationChange = Notification.Name("notificationChange")
    static let applicationEnteredFromBackground = Notification.Name("applicationEnteredFromBackground")
    static let challengeEdited = Notification.Name("challengeEdited")
    static let goalEdited = Notification.Name("goalEdited")
    static let cartItemsDidChange = Notification.Name("cartItemsDidChange")

    //watch and iphone connectivity notifications
    static let activityInfoUpdated = Notification.Name("activityInfoUpdated")
    static let activityHasBeenStoppedOnDevice = Notification.Name("activityHasBeenStoppedOnDevice")
    static let additionalActivityAddedOnWatchApp = Notification.Name("additionalActivityAddedOnWatchApp")
    
    //watch internal notifications
    static let watchActivityPausedTapped = Notification.Name("activityPausedTapped")
    static let watchActivityStateChanged = Notification.Name("watchActivityStateChanged")
    static let watchActivityStopButtonTapped = Notification.Name("watchActivityStopButtonTapped")
    static let watchStopActivity = Notification.Name("watchStopActivity")
    static let watchDontStopActivity = Notification.Name("watchDontStopActivity")
    static let watchErrorInCompleteActivity = Notification.Name("watchErrorInCompleteActivity")
    static let watchCompleteActivityApiSucceeded = Notification.Name("watchCompleteActivityApiSucceeded")
    static let watchActivityAddNewButtonTapped = Notification.Name("watchActivityAddNewButtonTapped")
    static let watchActivityAddNewActivityFromInProgressScreen = Notification.Name("watchActivityAddNewActivityFromInProgressScreen")
    
    static let editProfileNavigate = Notification.Name("editProfileNavigate")
    static let workoutFailed = Notification.Name("workoutFailed")
    static let closePopup = Notification.Name("closePopUp")
    static let showStreamButton = Notification.Name("showStreamButton")
}

