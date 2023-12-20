//
//  TagPhotoCollectionViewCell.swift
//  TemApp
//
//  Created by shilpa on 17/12/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import AMPopTip
import AVFoundation
open class PopTipCustomView: PopTip {
    var customView: TaggedUserView?
    var lastLocation = CGPoint(x: 0, y: 0)
}

protocol TagPhotoCollectionCellDelegate: AnyObject {
    func didTapOnPhotoAtPosition(position: CGPoint, atItem item: Int)
    func updateTagListAt(index: Int)
    func updateTagPoint(newPoint: CGPoint, taggedUserId: String)
}


class TagPhotoCollectionViewCell: UICollectionViewCell {
    
    // MARK: Properties
    enum PanDirection {
        case left, right, up, down, none, extremeLeft, extremeRight
    }
    
    var panDirection: PanDirection = .none
    weak var delegate: TagPhotoCollectionCellDelegate?
    /// This array will hold the views added on tapped locations for the cell
    private var taggedViews: [PopTipCustomView]?
    private var popTipWithCrossEnabled: PopTipCustomView?
    private let crossViewWidth: CGFloat = 30
//    private var lastLocation = CGPoint(x: 0, y: 0)
    
    // MARK: IBOutlets
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var cornerRounImageView: UIImageView!
    
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addGesturesToImage()
    }
    
//    override func prepareForReuse() {
//        print("prepare for reuse 1")
//        self.contentView.subviews.forEach { (view) in
//            print("prepare for reuse 2")
//            if let _ = view as? PopTipCustomView {
//                print("reuse remove")
//                view.removeFromSuperview()
//            }
//        }
//    }
    
    // MARK: Initializer
    func initializeAt(indexPath: IndexPath, media: Media, hasLoaded: Bool) {
        self.mediaImageView.tag = indexPath.item
        self.cornerRounImageView.isHidden = true
        if let height = media.height,
            height != 0 {
            mediaImageView.contentMode = .scaleAspectFit
            self.mediaImageView.image = media.image
            if hasLoaded {
                //self.setTagViewsFor(media: media, indexPath: indexPath)
                self.loadTags(media: media, indexPath: indexPath)
            }
        } else {
            mediaImageView.contentMode = .scaleAspectFill
            self.mediaImageView.image = media.image
            //self.setTagViewsFor(media: media, indexPath: indexPath)
            self.loadTags(media: media, indexPath: indexPath)
        }
    }
    
    private func loadTags(media: Media, indexPath: IndexPath) {
        if let mediaType = media.type,
            mediaType == .photo {
            self.setTagViewsFor(media: media, indexPath: indexPath)
        } else {
            //removing views to prevent reusing
            self.contentView.subviews.forEach { (view) in
                if view as? PopTipCustomView != nil {
                    view.removeFromSuperview()
                }
            }
        }
        if let taggedPeople = media.taggedPeople {
            if taggedPeople.isEmpty {
                self.cornerRounImageView.isHidden = true
            } else {
                self.cornerRounImageView.isHidden = false
            }
        } else {
            self.cornerRounImageView.isHidden = true
        }
        self.contentView.bringSubviewToFront(cornerRounImageView)
    }
    
    func setTagViewsFor(media: Media, indexPath: IndexPath) {
        if let tagInfo = media.taggedPeople,
            !tagInfo.isEmpty {
            setTaggedPeopleOnView(tagInfo: tagInfo, indexPath: indexPath)
        } else {
            self.contentView.subviews.forEach { (view) in
                if view as? PopTipCustomView != nil {
                    view.removeFromSuperview()
                }
            }
        }
    }
    
    func addGesturesToImage() {
        self.mediaImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(gestureTapped(recognizer:)))
        tapGesture.numberOfTapsRequired = 1
        self.mediaImageView.addGestureRecognizer(tapGesture)
    }
    
    
    private func setTaggedPeopleOnView(tagInfo: [UserTag], indexPath: IndexPath) {
        _ = tagInfo.map({ (tag) -> UserTag in
            
            removeAlreadyAddedOrAddNewView(tagInfo: tag, indexPath: indexPath)
            
            //self.addPopTipViewAt(pointX: tag.centerX ?? 0, pointY: tag.centerY ?? 0, withName: tag.text ?? "TagTag", userId: tag.taggedUser?.user_id ?? "")
            return tag
        })
    }
    
    func removeAlreadyAddedOrAddNewView(tagInfo: UserTag, indexPath: IndexPath) {
        if let taggedViews = self.taggedViews {
            let index = taggedViews.firstIndex { (popTipView) -> Bool in
                if let customView = popTipView.customView,
                    customView.taggedUserId == (tagInfo.taggedUser?.user_id ?? "") {
                    //this means the view is already added for this user, remove it first and then add it at new position
                    return true
                }
                return false
            }
            //remove
            if let index = index {
                print("removed already added")
                taggedViews[index].removeFromSuperview()
                self.taggedViews?.remove(at: index)
            }
            for subview in self.contentView.subviews {
                if subview is PopTipCustomView,
                    subview.tag != (indexPath.item + 1) {
                    subview.removeFromSuperview()
                }
            }
        }
        //add
        self.addPopTipViewAt(pointX: tagInfo.centerX ?? 0, pointY: tagInfo.centerY ?? 0, withName: tagInfo.text ?? "", userId: tagInfo.taggedUser?.user_id ?? "", indexPath: indexPath)
    }
    
    private func addPopTipViewAt(pointX: CGFloat, pointY: CGFloat, withName name: String, userId: String, indexPath: IndexPath) {
        guard let view = TaggedUserView.loadNib(frame: CGRect.zero) else {
            return
        }
        let popTip = PopTipCustomView()
        popTip.arrowSize = CGSize(width: 10, height: 10)
        popTip.arrowRadius = 2.0
        popTip.bubbleColor = UIColor.black.withAlphaComponent(0.8)//UIColor(0x38393A).withAlphaComponent(0.8)
        popTip.shouldDismissOnTap = false
        popTip.tapHandler = { _ in
            
        }
        let widthToShow = name.width(withConstrainedHeight: 30.0, font: UIFont.init(name: UIFont.robotoRegular, size: 13.0) ?? UIFont())
        view.delegate = self
        view.userNameLabel.text = name
        view.crossButton.isHidden = true
        view.frame = CGRect(x: 0, y: 0, width: widthToShow + 10, height: 23)
        view.taggedUserId = userId
        popTip.customView = view
        popTip.tag = indexPath.row + 1 //setting the tag of poptips corresponding to which cell it lies
        
        var popTipDirection: PopTipDirection = .down //default
        
        if pointX < 0.125 { // to extreme left
            print("Left ")
            popTip.arrowOffset = -10.0
        }
        
        if pointX > 0.75 { //to extreme right
            print("Right ")
            popTip.arrowOffset = 10.0
        }
        
        if pointY > 0.8 { //if the tap point is near the bottom of the imageview
            print("up ")
            popTipDirection = .up
        }
        var photoFrame = self.contentView.superview?.frame ?? CGRect.zero //frame of collectionview
        if mediaImageView.contentMode == .scaleAspectFit { //this would be for actvity, challenge or goal post
            photoFrame = self.mediaImageView.frameForPhoto()
        } else {
            photoFrame.origin.x = 0 //setting it to start
        }
        let normalizedPoint = CGPoint(x: pointX, y: pointY)
        let tagLocation = CGPoint(x: photoFrame.origin.x + (photoFrame.size.width * normalizedPoint.x), y: photoFrame.origin.y + (photoFrame.size.height * normalizedPoint.y))
        
        // last location needs to be corrected
        popTip.lastLocation = CGPoint(x: pointX, y: pointY)
        self.addPanGesture(popTip: popTip)
        DispatchQueue.main.async {
            popTip.show(customView: view, direction: popTipDirection, in: self.contentView, from: CGRect(x: tagLocation.x, y: tagLocation.y, width: 0, height: 0))
        }
        self.cornerRounImageView.isHidden = false
        self.contentView.bringSubviewToFront(cornerRounImageView)
        if self.taggedViews == nil {
            self.taggedViews = []
        }
        self.taggedViews?.append(popTip)
    }
    
    func addPanGesture(popTip: PopTipCustomView) {
        popTip.isUserInteractionEnabled = true
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panDetected(recognizer:)))
        popTip.addGestureRecognizer(panGesture)
    }
    
    @objc func panDetected(recognizer: UIPanGestureRecognizer) {
        if let popTipView = recognizer.view as? PopTipCustomView {
            let translation = recognizer.translation(in: popTipView.superview)
            if recognizer.state == .began {
                //print("begin gesture")
                popTipView.lastLocation = popTipView.center
            }
            var newPoint = CGPoint(x: popTipView.lastLocation.x + translation.x, y: popTipView.lastLocation.y + translation.y)
            
            //limit the boundary
            //print("origin y: \(popTipView.frame.origin.y)")
            //print("translation y: \(translation.y)")
            
            let yLowerBounds = (popTipView.superview?.frame.size.height ?? 0) - 43
            //print("yLowrerBounds: \(yLowerBounds)")
            //250
            if ((recognizer.view!.frame.origin.y>yLowerBounds && translation.y > 0)) {
                if popTipView.direction == .down {
                   // print("change direction")
                    //self.panDirection = .up
                    popTipView.entranceAnimation = .none
                    popTipView.show(customView: popTipView.customView!, direction: .up, in: self.contentView, from: CGRect(x: popTipView.center.x, y: popTipView.center.y, width: 0, height: 0))
                }
                
                newPoint.y = popTipView.center.y
            }
//            print("origin x: \(recognizer.view!.frame.origin.x)")
//            print("translation x: \(translation.x)")
            /*if ((recognizer.view!.frame.origin.x < 0 && translation.x < 0)) {
                //to extreme left
                if popTipView.arrowOffset == 0 {
                    print("to extreme left")
                    popTipView.arrowOffset = -10
                    popTipView.show(customView: popTipView.customView!, direction: .down, in: self.contentView, from: CGRect(x: popTipView.center.x, y: popTipView.center.y, width: 0, height: 0))
                }
                newPoint.x = popTipView.center.x
            } */
            
            let imageWidth = mediaImageView.frame.size.width
            if popTipView.frame.origin.x <= -(popTipView.frame.width/2 - 15) && translation.x < 0 {
                print("to extreme left")
                self.panDirection = .left
                newPoint.x = popTipView.center.x
            }
//            print("new x; \(popTipView.frame.origin.x)")
//            print("new width; \(popTipView.frame.width/2 + 15)")
//            print("imageWidth; \(imageWidth)")
            if popTipView.frame.origin.x >= (imageWidth - (popTipView.frame.size.width/2 + 15)) && translation.x > 0 {
                //print("to extreme right")
                self.panDirection = .right
                newPoint.x = popTipView.center.x
            }
            
            
            //NEW
//            print("arrow position: \(popTipView.arrowPosition.x)")
//            print("popTipView.frame.origin.x: \(popTipView.frame.origin.x)")
            if translation.x < 0 && popTipView.frame.origin.x <= 0 && popTipView.arrowPosition.x <= 24 { //15
                print("Stop moving ********")
                self.panDirection = .extremeLeft
                newPoint.x = popTipView.center.x
            }
            print("arrow position: \(popTipView.arrowPosition.x)")
            print("popTipView.frame.origin.x: \(popTipView.frame.origin.x)")
            if translation.x > 0 && popTipView.frame.maxX >= imageWidth && popTipView.arrowPosition.x >= (popTipView.frame.width - 24) { //15
                print("Stop moving ********")
                self.panDirection = .extremeRight
                newPoint.x = popTipView.center.x
            }
            //
            
            if recognizer.view!.frame.origin.y < 0 && translation.y < 0 {
                //to top
                newPoint.y = popTipView.center.y
            }
//            print("y: \(recognizer.view!.frame.origin.y)")
//            print("yLowerBounds \(yLowerBounds)")
            if recognizer.view!.frame.origin.y >= 0 && recognizer.view!.frame.origin.y < (popTipView.superview!.frame.size.height/2) {
                //print("in middle somewher")
                if popTipView.direction == .up {
                    //print("change direction")
                    //self.panDirection = .down
                    popTipView.entranceAnimation = .none
                    popTipView.show(customView: popTipView.customView!, direction: .down, in: self.contentView, from: CGRect(x: popTipView.center.x, y: popTipView.center.y, width: 0, height: 0))
                }
            }
            
            
            //print("last location: \(popTipView.lastLocation)")
            popTipView.center = newPoint//CGPoint(x: popTipView.lastLocation.x + translation.x, y: popTipView.lastLocation.y + translation.y)
            //print("poptip size: \(popTipView.frame)")
            //print("poptip center: \(popTipView.center)")
            if recognizer.state == .ended {
                //print("pan end")
                
                if self.panDirection == .left {
                    //popTipView.arrowOffset = -10
                    /*if popTipView.frame.origin.x <= 8 {
                        popTipView.bubbleOffset = 20
                    } */
                    popTipView.entranceAnimation = .none
                    popTipView.show(customView: popTipView.customView!, direction: popTipView.direction, in: self.contentView, from: CGRect(x: popTipView.center.x, y: popTipView.center.y, width: 0, height: 0))
                } else if panDirection == .right {
                    //popTipView.arrowOffset = 10
                    popTipView.entranceAnimation = .none
                    popTipView.show(customView: popTipView.customView!, direction: popTipView.direction, in: self.contentView, from: CGRect(x: popTipView.center.x, y: popTipView.center.y, width: 0, height: 0))
                } else if panDirection == .extremeLeft || panDirection == .extremeRight {
                    //do nothing
                }
//                else {
//                    popTipView.entranceAnimation = .none
//                    popTipView.show(customView: popTipView.customView!, direction: popTipView.direction, in: self.contentView, from: CGRect(x: popTipView.center.x, y: popTipView.center.y, width: 0, height: 0))
//                }
                
                if let userId = popTipView.customView?.taggedUserId {
                    let normalizedPoint = self.contentView.normalizedPosition(for: popTipView.center, inFrame: mediaImageView.frameForPhoto())
//                    self.delegate?.updateTagPoint(newPoint: popTipView.center, taggedUserId: userId)
                    self.delegate?.updateTagPoint(newPoint: normalizedPoint, taggedUserId: userId)
                }
              //  panDirection = .none
            }
        }
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        //save last location
//        if let touch = touches.first,
//            let view = touch.view as? PopTipCustomView {
//            print("touches began")
//            //view.lastLocation = view.center
//            //lastLocation = view.center
//        }
//    }
    
    /// hide the last cross button enabled on a tagged view
    func removeLastCrossEnabled() {
        if self.popTipWithCrossEnabled != nil {
            let width = self.popTipWithCrossEnabled?.customView?.frame.size.width ?? 0
            self.popTipWithCrossEnabled?.customView?.frame.size.width = width - crossViewWidth
            if let customView = self.popTipWithCrossEnabled?.customView {
                customView.crossButton.isHidden = true
                if let popTip = self.popTipWithCrossEnabled {
                    self.popTipWithCrossEnabled?.from = CGRect(x: popTip.center.x, y: popTip.center.y, width: 0, height: 0)
                }
                self.popTipWithCrossEnabled?.update(customView: customView)
            }
            //reset
            self.popTipWithCrossEnabled = nil
        }
    }
    
    @objc func gestureTapped(recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: mediaImageView)
        let normalizedPoint = self.contentView.normalizedPosition(for: point, inFrame: mediaImageView.frameForPhoto())
        print("touched point: \(point)")
        print("normalized point: \(normalizedPoint)")
        
        guard normalizedPoint.x >= 0 && normalizedPoint.x <= 1.0 && normalizedPoint.y >= 0 && normalizedPoint.y <= 1.0 else {
            print("trying to add tag out of image bounds!!!")
            return
        }
        
        if let touchedViewTag = recognizer.view?.tag {
//            self.delegate?.didTapOnPhotoAtPosition(position: newPoint, atItem: touchedViewTag)
            self.delegate?.didTapOnPhotoAtPosition(position: normalizedPoint, atItem: touchedViewTag)
        }
    }
}

// MARK: TaggedUserViewDelegate
extension TagPhotoCollectionViewCell: TaggedUserViewDelegate {
    func didTapOnNameView(sender: UIButton) {
        
        guard let view = sender.superview as? TaggedUserView,
            let popTip = view.superview as? PopTipCustomView else {
                return
        }
        
        //if the tap is done on the pop tip with cross enabled, then just hide that cross
        if let lastPoptip = self.popTipWithCrossEnabled,
            let customView = lastPoptip.customView,
            let tappedUserId = popTip.customView?.taggedUserId,
            tappedUserId == customView.taggedUserId {
            self.removeLastCrossEnabled()
            return
        }
        
        self.removeLastCrossEnabled()
        let width = view.frame.size.width
        view.frame.size.width = width + (self.crossViewWidth)
        view.crossButton.isHidden = false
        
        popTip.from = CGRect(x: popTip.center.x, y: popTip.center.y, width: 0, height: 0)
        popTip.update(customView: view)
        view.crossButton.isUserInteractionEnabled = true
        self.contentView.bringSubviewToFront(popTip)
        self.popTipWithCrossEnabled = popTip
    }
    
    func didTapOnCrossOnTaggedView(sender: UIButton) {
        print("button")
//        if let popTip = popTipWithCrossEnabled,
           if let customView = popTipWithCrossEnabled?.customView {
            popTipWithCrossEnabled?.removeFromSuperview()
            if let index = self.taggedViews?.firstIndex(where: { (view) -> Bool in
                if let innerCustomView = view.customView {
                    return innerCustomView.taggedUserId == customView.taggedUserId
                }
                return false
            }) {
                self.delegate?.updateTagListAt(index: index)
                self.taggedViews?.remove(at: index)
                if let views = self.taggedViews {
                    if views.isEmpty {
                        cornerRounImageView.isHidden = true
                    } else {
                        cornerRounImageView.isHidden = false
                    }
                } else {
                    cornerRounImageView.isHidden = true
                }
                contentView.bringSubviewToFront(cornerRounImageView)
            }
        }
    }
}

