//
//  StoryViewCollectionViewCell.swift
//  VIZU
//
//  Created by dhiraj on 05/10/18.
//  Copyright © 2018 Capovela LLC. All rights reserved.
//

import UIKit
import AVKit
import Kingfisher
protocol MediaItemCollectionViewCellDelegate: AnyObject {
//    func gestureLongPressed(state: UIGestureRecognizer.State)
    func mediaCollectionCellTapped(recognizer: UITapGestureRecognizer)
//    func storyCollectionCellScrollDidScroll()   //call when scroll view is scrolled
//    func storyCollectionCellScrollDidEndDecelerate()    //call when fingers are lifted off scroll view
    func mediaCollectionSetScrollTo(status: Bool)
}
class MediaItemCollectionViewCell: UICollectionViewCell {
    
    // MARK: Properties
    weak var delegate: MediaItemCollectionViewCellDelegate?
    var player: AVPlayer?
    
    // MARK: IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 6.0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(gestureTapped(recognizer:)))
        tapGesture.numberOfTapsRequired = 2
        self.addGestureRecognizer(tapGesture)
    }
    
    // MARK: Helpers
    @objc func gestureTapped(recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale != 1.0 {
            self.scrollView.setZoomScale(1.0, animated: true)
        } else {
            self.scrollView.setZoomScale(2.0, animated: true)
        }
        self.delegate?.mediaCollectionCellTapped(recognizer: recognizer)
    }
    
    func playVideo(withUrl url: URL) {
        guard self.player == nil else {
            self.player?.play()
            return
        }
        self.player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.bounds
        self.layer.addSublayer(playerLayer)
        self.player?.play()
    }
    
    func removePlayer() {
        guard player != nil else {
            return
        }
        self.player?.pause()
        //self.player = nil
    }
    
    // MARK: Initializer
    func initialize(atIndexPath indexPath: IndexPath, withMediaItem media: Media) {
        if let type = media.type,
            let urlString = media.url,
            let url = URL(string: urlString) {
            switch type {
            case .photo:
                self.imageView.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: { (receivedSize, totalSize) in
                    print("image downloading in progress")
                }) { (result) in
                    print("Kingfisher image downloaded")
                }
            case .video:
                self.imageView.image = nil
                self.removePlayer()
            case .pdf:
                break
            }
        }
    }
}

// MARK: UIScrollViewDelegate
extension MediaItemCollectionViewCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        print("zoomed")
        return backView
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        print("end zooming")
        if scrollView.zoomScale != 1.0 {    //initial
            //disable collectionview scrolling
            self.delegate?.mediaCollectionSetScrollTo(status: false)
        } else {
            //enable collection scrolling
            self.delegate?.mediaCollectionSetScrollTo(status: true)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("didscroll called")
       // self.delegate?.storyCollectionCellScrollDidScroll()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("decelerate")
        //self.scrollView.setZoomScale(1.0, animated: true)
        //self.delegate?.storyCollectionCellScrollDidEndDecelerate()
    }
}

// MARK: UIGestureRecognizerDelegate
extension MediaItemCollectionViewCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
