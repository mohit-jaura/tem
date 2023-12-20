//
//  MediaCollectionViewController.swift
//  TemApp
//
//  Created by shilpa on 12/02/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
class MediaCollectionViewController: DIBaseController {
    
    // MARK: IBOutlets
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Properties
    var media = [Media]()
    var player : VGPlayer!
    var playerView : VGEmbedPlayerView!
    var playerViewSize : CGSize?
    var currentPlayIndexPath : IndexPath?
    var currentIndex = 0
    
    @IBAction func dismissTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSwipeDownGesture()
        let value = UIInterfaceOrientationMask.landscape.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.listenVolumeButton()
        NotificationCenter.default.addObserver(self, selector: #selector(outputVolumeChanged), name: Notification.Name.outputVolumeChanged, object: nil)
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at:IndexPath(item: self.currentIndex, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //self.removeVolumeListeners()
        NotificationCenter.default.removeObserver(self, name: Notification.Name.outputVolumeChanged, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let value = UIInterfaceOrientationMask.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        guard player != nil else {
            return
        }
        player.pause()
        player.remove()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    // MARK: Helpers
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
        if currentIndex < self.media.count {
            DispatchQueue.main.async {
                self.collectionView.scrollToItem(at:IndexPath(item: self.currentIndex, section: 0), at: .centeredHorizontally, animated: false)
                
            }
        }
     //   self.collectionView.reloadData()
    }
    
    func addSwipeDownGesture() {
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(gestureSwiped(recognizer:)))
        swipeDownGesture.direction = .down
        self.view.addGestureRecognizer(swipeDownGesture)
    }
    
    @objc func gestureSwiped(recognizer: UISwipeGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func outputVolumeChanged() {
        self.updateSoundButtonOnChangingSoundStatus()
    }
    
    // MARK: VGPLayer Video player helpers
    func configurePlayer() {
        playerView = VGEmbedPlayerView()
        playerView.sizeToFit()
        player = VGPlayer(playerView: playerView)
        if let muteStatus = Defaults.shared.get(forKey: .muteStatus) as? Bool {
            self.player.setSound(toValue: muteStatus)
        }
        player.displayView.displayUIControls()
        player.displayView.delegate = self
        player.delegate = self
        player.backgroundMode = .suspend
    }
    
    func addPlayer(_ cell: MediaVideoCollectionViewCell, indexPath: IndexPath) {
        guard let url = self.media[indexPath.item].url else {
            return
        }
        if player != nil {
            player.cleanPlayer()
        }
        configurePlayer()
        cell.videoView.addSubview(player.displayView)
        cell.soundButton.layer.zPosition = 1
        //        cell.contentView.addSubview(player.displayView)
        /*player.displayView.snp.makeConstraints { (make) in
         //$0.edges.equalTo(cell)
         make.top.left.height.width.right.equalToSuperview()
         } */
        self.player.displayView.snp.makeConstraints { [weak self] (make) in
            guard let _ = self else { return }
            //make.top.left.right.equalToSuperview()
            //make.height.equalTo(strongSelf.view.snp.width)//.multipliedBy(3.0/4.0) // you can 9.0/16.0
            make.top.left.height.width.right.equalToSuperview()
        }
        player.replaceVideo(URL(string: url)!)
        //player.play()
    }
    
    ///call this function whenevr the user changes the sound status of the video
    private func updateSoundButtonOnChangingSoundStatus() {
        if let visibleCells = collectionView.visibleCells as? [MediaVideoCollectionViewCell],
            let firstCell = visibleCells.first {
            firstCell.setViewForMuteButton()
        }
    }
}

// MARK: UICollectionViewDataSource
extension MediaCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.media.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch self.media[indexPath.item].type! {
        case .photo:
            return imageCollectionCell(atIndexPath: indexPath)
        default:
            return videoCollectionCell(atIndexPath: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        /*if let cell = cell as? MediaImageCollectionViewCell,
         let mediaType = self.media[indexPath.item].type {
         switch mediaType {
         case .video:
         if let urlString = self.media[indexPath.item].url,
         let url = URL(string: urlString) {
         cell.playVideo(withUrl: url)
         }
         case .photo:
         cell.removePlayer()
         }
         } */
        if let cell = cell as? MediaVideoCollectionViewCell {
            if let urlString = self.media[indexPath.item].url,
                let _ = URL(string: urlString) {
                //cell.playVideo(withUrl: url)
                cell.playVideo()
            }
        }
        /*if let cell = cell as? MediaVideoCollectionViewCell {
         // cell.playVideo()
         //BMPlayer implementation
         self.configurePlayer(cell: cell, indexPath: indexPath)
         } */
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let _ = cell as? MediaVideoCollectionViewCell,
            self.player != nil {
            self.player.pause()
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension MediaCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.view.frame.size
    }
}

extension MediaCollectionViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int(ceil(scrollView.contentOffset.x / scrollView.frame.size.width))
        currentIndex = currentPage
    }
}

// MARK: MediaImageCollectionViewCellDelegate
extension MediaCollectionViewController: MediaImageCollectionViewCellDelegate {
    func mediaCollectionCellTapped(recognizer: UITapGestureRecognizer) {
        
    }
    
    func mediaCollectionSetScrollTo(status: Bool) {
        self.collectionView.isScrollEnabled = status
    }
}

extension MediaCollectionViewController {
    func imageCollectionCell(atIndexPath indexPath: IndexPath) -> MediaImageCollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaImageCollectionViewCell.reuseIdentifier, for: indexPath) as! MediaImageCollectionViewCell
        cell.delegate = self
        /*if indexPath.item % 2 == 0 {
         cell.backView.backgroundColor = UIColor.red
         } else {
         cell.backView.backgroundColor = UIColor.blue
         } */
        cell.initialize(atIndexPath: indexPath, withMediaItem: self.media[indexPath.item])
        return cell
    }
    
    func videoCollectionCell(atIndexPath indexPath: IndexPath) -> MediaVideoCollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaVideoCollectionViewCell.reuseIdentifier, for: indexPath) as! MediaVideoCollectionViewCell
        cell.indexPath = indexPath
        cell.initialize()
        cell.delegate = self
        //VGPlayer implementation
        cell.playCallBack = ({ [weak self] (indexPath: IndexPath?) -> Void in
            guard let strongSelf = self else { return }
            strongSelf.playerViewSize = cell.contentView.bounds.size
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Code you want to be delayed
                /*if self?.player == nil {
                 strongSelf.addPlayer(cell, indexPath: indexPath!)
                 } else {
                 if let url = self?.media[indexPath!.row].url {
                 strongSelf.player.replaceVideo(URL(string: url)!)
                 }
                 } */
                strongSelf.addPlayer(cell, indexPath: indexPath!)
                
            }
            //            strongSelf.currentPlayIndexPath = indexPath
        })
        
        return cell
    }
}

// MARK: VGPlayerViewDelegate
extension MediaCollectionViewController: VGPlayerDelegate {
    func vgPlayer(_ player: VGPlayer, stateDidChange state: VGPlayerState) {
        if state == .playFinished {
            if let url = player.contentURL {
                self.player.replaceVideo(url)
                self.player.play()
            }
        }
        if state == .error {
            print("error in VGPlayer state\n")
            let type = AlertBarType.custom(UIColor.lightGray, UIColor.white)
            AlertBar.show(type, message: AppMessages.AlertTitles.noInternet, completion: nil)
            
            //try to play again the video
            self.player.play()
        }
    }
    
    func vgPlayer(_ player: VGPlayer, bufferStateDidChange state: VGPlayerBufferstate) {
        switch state {
        case .buffering:
            if let cell = collectionView.visibleCells.first as? MediaVideoCollectionViewCell {
                print("state: buffering")
                cell.startActivityIndicator()
            }
        case .readyToPlay:
            if let cell = collectionView.visibleCells.first as? MediaVideoCollectionViewCell {
                print("state: buffer finished")
                cell.stopActivityIndicator()
                self.player.play()
            }
        default:
            break
        }
    }
}

// MARK: VGPlayerViewDelegate
extension MediaCollectionViewController: VGPlayerViewDelegate {
    func vgPlayerView(_ playerView: VGPlayerView, willFullscreen fullscreen: Bool) {
        print("player entered full screen")
        if let currentCell = collectionView.visibleCells.first as? MediaVideoCollectionViewCell {
            currentCell.videoView.bringSubviewToFront(currentCell.soundButton)
        }
    }
}

// MARK: MediaVideoCollectionCellDelegate
extension MediaCollectionViewController: MediaVideoCollectionCellDelegate {
    func didTapOnSoundButton(button: UIButton) {
        if let muteStatus = Defaults.shared.get(forKey: .muteStatus) as? Bool {
            if muteStatus == true {
                Defaults.shared.set(value: false, forKey: .muteStatus)
            } else {
                Defaults.shared.set(value: true, forKey: .muteStatus)
            }
            self.player.setSound(toValue: !muteStatus)
        }
        self.updateSoundButtonOnChangingSoundStatus()
    }
}
