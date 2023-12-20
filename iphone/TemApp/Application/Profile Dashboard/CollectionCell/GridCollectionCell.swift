//
//  GridCollectionCell.swift
//  TemApp
//
//  Created by Harpreet_kaur on 26/03/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import Kingfisher
import AMPopTip
import AVFoundation
protocol GridCollectionCellDelegate: AnyObject {
    func didTapOnSoundButton(sender: CustomButton)
    func didTapOnTaggedButton(sender: CustomButton)
}
class GridCollectionCell: UICollectionViewCell {
    
    // MARK: Properties
    weak var delegate: GridCollectionCellDelegate?
    private var media: Media?
    var screenFrom: Constant.ScreenFrom?
    
    // MARK: IBOutlets.
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var placeHolderImageView: UIImageView!
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var videoIconImageView: UIImageView!
    @IBOutlet weak var videoPlayIcon: UIImageView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var soundButton: CustomButton!
    @IBOutlet weak var taggedButton: CustomButton!
    @IBOutlet weak var taggedButtonView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK: IBActions
    @IBAction func taggedButtonTapped(_ sender: CustomButton) {
        if let media = media,
            let type = media.type,
            type == .photo,
            mediaImageView.image == nil {
            return
        }
        self.delegate?.didTapOnTaggedButton(sender: sender)
    }
    @IBAction func soundButtonTapped(_ sender: CustomButton) {
        self.delegate?.didTapOnSoundButton(sender: sender)
    }
    
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    // MARK: Function will be used to set the value of cell properties.
    func setData(data:Media,postType:PostType) {
        
        self.media = data
        if let mediaHeight = data.height,
            mediaHeight != 0 {

      //      if screenFrom == .createPost{
                mediaImageView.contentMode = .scaleAspectFit
//            }else{
//                mediaImageView.contentMode = .scaleAspectFit
//            }

        } else {
         //   if screenFrom == .createPost{
                mediaImageView.contentMode = .scaleAspectFill
//            }else{
//                mediaImageView.contentMode = .scaleAspectFit
//            }
            mediaImageView.clipsToBounds = true
        }
        mediaImageView.fillContainer()
        
        self.setViewForMuteButton()
        //        let resizingProcessor = ResizingImageProcessor(referenceSize: CGSize(width: size.width, height: size.height+50))
        //let placeholder = UIImage(named: "ImagePlaceHolder")
        if data.type == .video {
            self.soundButton.isHidden = false
            self.videoView.isHidden = false
            if let imageUrl = URL(string:data.previewImageUrl ?? "") {
                self.mediaImageView.kf.setImage(with: imageUrl, placeholder: nil, options: nil, progressBlock: nil) { (_) in
                    //                    let resizedImage = result.value?.image.resizedImageWithinRect(rectSize: self.mediaImageView.frame.size)
                    //                    self.mediaImageView.image = resizedImage
                }
            }
        } else {
            self.soundButton.isHidden = true
            self.videoView.isHidden = true
            if let imageUrl = URL(string:data.url ?? "") {
                self.mediaImageView.kf.setImage(with: imageUrl, placeholder: nil, options: nil, progressBlock: nil) { (result) in
                    do {
                        let image =  try result.get().image
                        if let mediaHeight = data.height,
                        mediaHeight != 0 && UIScreen.main.bounds.width < Constant.ScreenSize.IPHONE_MAX_WIDTH {
                            let size = CGSize(width: Double(image.size.width), height: Double(image.size.height+(image.size.height*0.10)))
                            self.mediaImageView.image = self.resizedImage(at: image, for: size)
                        } else {
                            self.mediaImageView.image =  image
                        }
                    } catch let error {
                        print("error---->\(error)")
                    }
                }
            }
        }
        videoIconImageView.isHidden =  data.type == .video ? false : true
        videoPlayIcon.isHidden = true
        self.setNeedsLayout()
    }
    
    func resizedImage(at image: UIImage, for size: CGSize) -> UIImage? {
           let renderer = UIGraphicsImageRenderer(size: size)
           return renderer.image { (_) in
               image.draw(in: CGRect(origin: .zero, size: size))
           }
       }

    func checkForAnyTagInMedia(media: Media) {
        self.taggedButton.isHidden = true
        //self.taggedButtonView.isHidden = true
        if let taggedIds = media.taggedPeople,
            !taggedIds.isEmpty {
            self.taggedButton.isHidden = false
            //self.taggedButtonView.isHidden = false
        }
    }
    
    func setViewForMuteButton() {
        if let muteStatus = Defaults.shared.get(forKey: .muteStatus) as? Bool {
            if muteStatus == true {
                self.soundButton.setImage(#imageLiteral(resourceName: "volume-off-indicator"), for: .normal)
            } else {
                self.soundButton.setImage(#imageLiteral(resourceName: "speaker-filled-audio-tool"), for: .normal)
            }
        }
    }

    func showTaggedPeopleOnImage(taggedPeople: [UserTag]?) {
        if let taggedList = taggedPeople,
            !taggedList.isEmpty {
            _ = taggedList.map { (userTag) -> UserTag in
                //add popovers at the postions
                self.addPopTipAt(userTag: userTag)
                return userTag
            }
        }
    }
    
    func removeTaggedViews() {
        self.contentView.subviews.forEach { (view) in
            if view as? PopTipCustomView != nil {
                view.removeFromSuperview()
            }
        }
    }

    private func addPopTipAt(userTag: UserTag) {
        guard let view = TaggedUserView.loadNib(frame: CGRect.zero) else {
            return
        }
        let pointX = userTag.centerX ?? 0
        let pointY = userTag.centerY ?? 0
        let popTip = PopTipCustomView()
        popTip.arrowSize = CGSize(width: 10, height: 10)
        popTip.arrowRadius = 2.0
        popTip.bubbleColor = UIColor.black.withAlphaComponent(0.8)//UIColor(0x38393A).withAlphaComponent(0.8)
        popTip.shouldDismissOnTap = false
        popTip.shouldDismissOnTapOutside = false
        popTip.tapHandler = { _ in
        }
        //correct
        let name = userTag.text ?? ""
        let widthToShow = name.width(withConstrainedHeight: 30.0, font: UIFont.init(name: UIFont.robotoRegular, size: 13.0)!)
        view.delegate = self
        view.userNameLabel.text = name
        view.crossButton.isHidden = true
        view.frame = CGRect(x: 0, y: 0, width: widthToShow + 15, height: 23)
        view.taggedUserId = userTag.id ?? ""
        popTip.customView = view
        //popTip.tag = indexPath.row + 1 //setting the tag of poptips corresponding to which cell it lies
        
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
        
        let w = mediaImageView.frame.size.width
        let h = mediaImageView.frame.size.height
        
        popTip.lastLocation = CGPoint(x: pointX * w, y: pointY * h)
        popTip.entranceAnimation = .none
        
        let photoFrame = self.mediaImageView.frameForPhoto()
        let normalizedPoint = CGPoint(x: pointX, y: pointY)
        
        let tagLocation = CGPoint(x: photoFrame.origin.x + (photoFrame.size.width * normalizedPoint.x), y: photoFrame.origin.y + (photoFrame.size.height * normalizedPoint.y))
        
        DispatchQueue.main.async {
//            popTip.show(customView: view, direction: popTipDirection, in: self.contentView, from: CGRect(x: pointX * w, y: pointY * h, width: 0, height: 0))
            popTip.show(customView: view, direction: popTipDirection, in: self.contentView, from: CGRect(x: tagLocation.x, y: tagLocation.y, width: 0, height: 0))
        }
    }
    
    private func redirectToUserProfile(withId userId: String) {
        guard let currentUserId = UserManager.getCurrentUser()?.id else {
            return
        }
        let profileController: ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
        if userId != currentUserId {
            //if this is not my profile
            profileController.otherUserId = userId
        }
        UIApplication.topViewController()?.navigationController?.pushViewController(profileController, animated: true)
    }
}

// MARK: TaggedUserViewDelegate
extension GridCollectionCell: TaggedUserViewDelegate {
    func didTapOnNameView(sender: UIButton) {
        guard let popTip = sender.superview?.superview as? PopTipCustomView else {
            return
        }
        if let userId = popTip.customView?.taggedUserId {
            self.redirectToUserProfile(withId: userId)
        }
    }
}
