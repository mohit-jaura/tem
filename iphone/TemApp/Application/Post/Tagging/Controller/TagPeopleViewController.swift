//
//  TagPeopleViewController.swift
//  TemApp
//
//  Created by shilpa on 17/12/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
protocol TagPeopleOnMediaControllerDelegate: AnyObject {
    func didTapDoneOnScreen(updatedMedia: [Media], taggedCount: Int)
}

class TagPeopleViewController: DIBaseController {

    // MARK: Properties
    weak var delegate: TagPeopleOnMediaControllerDelegate?
    enum VideoSection: Int {
        case emptyTag = 0, taggedPeople
    }
    
    var postId: String = ""
    var media = [Media]()
    //var taggedPeople = [Friends]()
    var currentMediaDisplayed = Media()
    var currentMediaIndex = 0
    /// this will hold the total tagged people count, and will be passed back to the controller
    var totalTaggedCount = 0
    var currentTappedLocation: (centerX: CGFloat?, centerY: CGFloat)?
    var hasLoaded = false
    private let maximumTagLimit: Int = 75
    var screenFrom: Constant.ScreenFrom = .createGoal
    // MARK: IBOutlets
    @IBOutlet weak var taggedUsersTableView: UITableView!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
    }
    
    // MARK: Initializer
    private func setUpView() {
        self.configureNavigationBar()
        self.taggedUsersTableView.registerHeaderFooter(nibNames: [TagAnotherPersonSectionView.reuseIdentifier])
        self.taggedUsersTableView.registerNibs(nibNames: [TaggedUserTableViewCell.reuseIdentifier])
        self.currentMediaDisplayed = self.media.first ?? Media()
        self.imagesCollectionView.dataSource = self
        self.imagesCollectionView.delegate = self
        self.imagesCollectionView.reloadData()
        self.taggedUsersTableView.reloadData()
        
        if self.media.count == 1,
            let height = media.first?.height,
            height != 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.hasLoaded = true
                self.imagesCollectionView.reloadData()
            }
        }
    }
    
    private func configureNavigationBar() {
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped(sender:)))
        rightBarButtonItem.tintColor = UIColor.appThemeColor
        self.setNavigationController(titleName: "Tag People", leftBarButton: nil, rightBarButtom: [rightBarButtonItem], backGroundColor: UIColor.white, translucent: true)
        self.navigationController?.setDefaultNavigationBar()
    }

    @objc private func doneTapped(sender: UIBarButtonItem) {
        self.delegate?.didTapDoneOnScreen(updatedMedia: self.media, taggedCount: totalTaggedCount)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Helpers
    func presentUsersListingToTag() {
        if let taggedPeople = self.media[currentMediaIndex].taggedPeople,
            taggedPeople.count == maximumTagLimit { // maximum 75 can be tagged
            self.currentTappedLocation = nil
            self.showAlert(message: "You can tag upto \(maximumTagLimit) people per picture or video.".localized)
            return
        }
        let tagUsersController: TagUsersContainerViewController = UIStoryboard(storyboard: .post).initVC()
        tagUsersController.delegate = self
        tagUsersController.screenFrom = self.screenFrom
        self.present(tagUsersController, animated: true, completion: nil)
    }
}

// MARK: UIScrollViewDelegate
extension TagPeopleViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == imagesCollectionView {
            let x = scrollView.contentOffset.x
            let w = scrollView.bounds.size.width
            let currentPage = Int(ceil(x/w))
            if currentPage < media.count {
                self.currentMediaDisplayed = self.media[currentPage]
                self.currentMediaIndex = currentPage
                self.taggedUsersTableView.reloadData()
            }
        }
    }
}

// MARK: TagUsersContainerViewDelegate
extension TagPeopleViewController: TagUsersContainerViewDelegate {
    func didAddNewTaggedUser(user: Friends) {
        if self.media[currentMediaIndex].taggedPeople == nil {
            media[currentMediaIndex].taggedPeople = []
        }
        // user_id or _id
        var newTagged = UserTag()//PhotoTag(centerX: nil, centerY: nil, taggedUser: user)
        newTagged.taggedUser = user
        newTagged.id = user.user_id
        newTagged.text = user.fullName.replace(" ", replacement: "")
        newTagged.centerX = currentTappedLocation?.centerX
        newTagged.centerY = currentTappedLocation?.centerY
        newTagged.firstName = user.firstName
        newTagged.lastName = user.lastName
        newTagged.profilePic = user.profilePic
        currentTappedLocation = nil //reset last tapped location
        
        if let newUserId = user.user_id {
            //the user is already present in the tagged list, then remove it first and then add it at the first
            if let indexOfAlreadyPresent = media[currentMediaIndex].taggedPeople?.firstIndex(where: { (tag) -> Bool in
                return tag.taggedUser?.user_id == newUserId
            }) {
                media[currentMediaIndex].taggedPeople?.remove(at: indexOfAlreadyPresent)
                totalTaggedCount -= 1
            }
        }
//        self.media[currentMediaIndex].taggedPeople?.append(newTagged)
        
        //for image media type, add the new tagged at the end and for the video media type, insert the new tagged at first
        if let mediaType = self.media[currentMediaIndex].type {
            switch mediaType {
            case .photo:
                self.media[currentMediaIndex].taggedPeople?.append(newTagged)
            case .video:
                self.media[currentMediaIndex].taggedPeople?.insert(newTagged, at: 0)
            case .pdf:
                break
            }
        }
        totalTaggedCount += 1
        
        if let type = media[currentMediaIndex].type {
            switch type {
            case .photo:
                let indexPath = IndexPath(item: currentMediaIndex, section: 0)
                if let cell = imagesCollectionView.cellForItem(at: indexPath) as? TagPhotoCollectionViewCell {
                    cell.removeAlreadyAddedOrAddNewView(tagInfo: newTagged, indexPath: indexPath)
                }
                //self.imagesCollectionView.reloadData()
            case .video:
                self.taggedUsersTableView.reloadData()
                
            case .pdf:
                break
            }
        }
    }
}
