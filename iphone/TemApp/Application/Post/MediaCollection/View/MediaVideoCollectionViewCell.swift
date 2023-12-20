//
//  MediaVideoCollectionViewCell.swift
//  TemApp
//
//  Created by shilpa on 12/02/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
protocol MediaVideoCollectionCellDelegate: AnyObject {
    func didTapOnSoundButton(button: UIButton)
}
class MediaVideoCollectionViewCell: UICollectionViewCell {
    
    // MARK: Properties
    weak var delegate: MediaVideoCollectionCellDelegate?
    var playCallBack: ((IndexPath?) -> Swift.Void)?
    var indexPath: IndexPath?
    
    // MARK: IBOutlets
    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: IBActions
    @IBAction func soundButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapOnSoundButton(button: sender)
    }
    
    // MARK: Initalizer
    func initialize() {
        self.setViewForMuteButton()
    }
    
    func playVideo() {
        if let callBack = playCallBack {
            callBack(indexPath)
        }
    }
    
    func setViewForMuteButton() {
        self.soundButton.isHidden = true
        if let muteStatus = Defaults.shared.get(forKey: .muteStatus) as? Bool {
            print("video is muted ----------> \(muteStatus)")
            if muteStatus == true {
                self.soundButton.setImage(#imageLiteral(resourceName: "volume-off-indicator"), for: .normal)
            } else {
                self.soundButton.setImage(#imageLiteral(resourceName: "speaker-filled-audio-tool"), for: .normal)
            }
        }
    }
    
    // MARK: Helpers
    func startActivityIndicator() {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator() {
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
    }
}
