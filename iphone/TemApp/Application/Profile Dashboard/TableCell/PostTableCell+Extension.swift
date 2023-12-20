//
//  PostTableCell+Extension.swift
//  TemApp
//
//  Created by Harpreet_kaur on 07/06/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit


// MARK: UIScrollViewDelegate
extension PostTableCell: UIScrollViewDelegate {
    
    // MARK: This delegate will be called to adjust the postion of dots accroding to selected Collection cell.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == mediaCollectionView {
            pageControl.currentPage = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
            self.delegate?.collectionViewDidScroll(newContentOffset: scrollView.contentOffset, scrollView: scrollView)
        }
    }
    
    // MARK: This delegate will Play/Pause the video on call
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == mediaCollectionView,
            !decelerate {
            self.postTableVideoMediaDelegate?.mediaCollectionScrollDidEnd()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == mediaCollectionView {
            self.postTableVideoMediaDelegate?.mediaCollectionScrollDidEnd()
        }
    }
}


// MARK: UICollectionViewDelegate&UICollectionViewDataSource.
extension PostTableCell : UICollectionViewDelegate , UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.postData?.media?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell:GridCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: GridCollectionCell.reuseIdentifier, for: indexPath) as? GridCollectionCell else {
            return UICollectionViewCell()
        }
        cell.soundButton.section = collectionView.tag
        cell.soundButton.row = indexPath.item
        cell.delegate = self
        if self.postData?.media?.count ?? 0 > indexPath.item {
            if let media = self.postData?.media?[indexPath.item] {
                cell.setData(data: media, postType: self.postData?.type ?? PostType.normal)
                cell.checkForAnyTagInMedia(media: media)
                cell.taggedButton.section = collectionView.tag
                cell.taggedButton.row = indexPath.item
            }
        }
    //  cell.mediaImageView.contentMode = .scaleToFill // OR .scaleAspectFill
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? GridCollectionCell {
            cell.setViewForMuteButton()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let media = self.postData?.media,
            let height = media.first?.height,
            height != 0 {
            //setting the cell size equal to the media height, if media height is not nil
            return CGSize(width: Constant.ScreenSize.SCREEN_WIDTH - 18 , height: CGFloat(height))
        }
        let width = Constant.ScreenSize.SCREEN_WIDTH//UserDefaults.standard.float(forKey: "Height")
        return CGSize(width: (CGFloat(width) - 18), height: mediaCollectionView.frame.height)
    }


    // MARK: View posts in large view.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //For viewers.....
        self.viewableArr.removeAll()
        getViewableObject()
        guard let collectionView = self.mediaCollectionView else { return }
        
        self.viewerController = ViewerController(initialIndexPath: indexPath, collectionView: collectionView)
        self.viewerController!.dataSource = self
        self.viewerController!.delegate = self
        self.viewerController?.autoplayVideos = true
        self.viewerController?.currentDuration = 4.0
        let headerView = HeaderView()
        headerView.viewDelegate = self
        self.viewerController?.headerView = headerView
        UIApplication.topViewController()?.navigationController?.present(viewerController!, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
      
        //remove tagged views if any
        if let cell = cell as? GridCollectionCell {
            cell.removeTaggedViews()
        }
    }
}


extension PostTableCell:ViewerControllerDataSource {
    func numberOfItemsInViewerController(_: ViewerController) -> Int {
        return self.viewableArr.count
    }
    func viewerController(_: ViewerController, viewableAt indexPath: IndexPath) -> Viewable {
        let viewable = self.viewableArr[indexPath.row]
        return viewable
    }
}


extension PostTableCell: HeaderViewDelegate {
    func headerView(_: HeaderView, didPressClearButton _: UIButton) {
        self.viewerController?.dismiss(nil)
    }
}

extension PostTableCell: ViewerControllerDelegate {
    func viewerController(_: ViewerController, didChangeFocusTo _: IndexPath) {}
    
    func viewerControllerDidDismiss(_: ViewerController) {
        #if os(tvOS)
        // Used to refocus after swiping a few items in fullscreen.
        self.setNeedsFocusUpdate()
        self.updateFocusIfNeeded()
        #endif
        self.postTableVideoMediaDelegate?.didDismissFullScreenPreview()
    }
    
    func viewerController(_: ViewerController, didFailDisplayingViewableAt _: IndexPath, error _: NSError) {}
    
    func viewerController(_ viewerController: ViewerController, didLongPressViewableAt indexPath: IndexPath) {
        print("didLongPressViewableAt: \(indexPath)")
    }
}


// MARK: UITextViewDelegate
// MARK: Adjust the height of textview according to content.
extension PostTableCell :UITextViewDelegate {
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        print(textView.contentSize.height)
//        self.commwntViewHeightConstraint.constant = textView.contentSize.height
//        if self.commwntViewHeightConstraint.constant > 67 {
//            self.commwntViewHeightConstraint.constant = 67
//        }
//        var hidebutton = false
//        if (textView.text.count == 1 && text.count == 0) {
//            hidebutton = true
//        }
//        if (textView.text.count + text.count) >= 1 && (hidebutton == false){
//            self.postButton.setTitleColor(appThemeColor, for: .normal)
//            self.postButton.isUserInteractionEnabled = true
//        }else{
//            self.postButton.setTitleColor(UIColor(red: 148/255, green: 199/255, blue: 240/255, alpha: 1.0), for: .normal)
//            self.postButton.isUserInteractionEnabled = false
//        }
//        if textView.text.count + text.count > 2000 {
//            return false
//        }
//
//        Tagging.sharedInstance.updateTaggedList(range: range, textCount: text.utf16.count)
//
//        //self.postData?.commentText = textView.text
//        self.setCommentText(text: textView.text)
//
//        return true
//    }
    
    // MARK: This function will adjust the height of tablecell according to content.
//    func textViewDidChange(_ textView: UITextView) {
//        Tagging.sharedInstance.tagging(textView: textView)
//        self.delegate?.adjustTableHeight(scrollToTp: false)
//    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
            self.delegate?.didBeginEdit(textView: textView)
    }
    
//    func textViewDidChangeSelection(_ textView: UITextView) {
//        //Tagging
//        //tagging text view if changed
//        Tagging.sharedInstance.tagging(textView: textView)
//    }
    
//    func textViewDidEndEditing(_ textView: UITextView) {
//        self.setCommentText(text: textView.text)
//    }
}

// MARK: GridCollectionCellDelegate(Method will mute/unmute the video sound according to user action)
extension PostTableCell: GridCollectionCellDelegate {
    func didTapOnTaggedButton(sender: CustomButton) {
        if let media = self.postData?.media?[sender.row],
            let mediaType = media.type {
            switch mediaType {
            case .photo:
                let indexPath = IndexPath(item: sender.row, section: 0)
                if let cell = mediaCollectionView.cellForItem(at: indexPath) as? GridCollectionCell {
                    if let _ = cell.contentView.subviews.last as? PopTipCustomView {
                        cell.removeTaggedViews()
                    } else {
                        cell.showTaggedPeopleOnImage(taggedPeople: media.taggedPeople)
                        self.delegate?.didTapOnViewTaggedPeople(sender: sender)
                    }
                }
            case .video:
                self.delegate?.didTapOnViewTaggedPeople(sender: sender)
            case .pdf:
                break
            }
        }
    }
    
    func didTapOnSoundButton(sender: CustomButton) {
        self.postTableVideoMediaDelegate?.didTapOnMuteButton(sender: sender)
    }
}

// MARK: CommomentsDelegate(Method will increase/decrease the comment count by one according to user action.)
extension PostTableCell: CommomentsDelegate {
    func updateCount(indexPath: IndexPath,isDecrease:Bool, dataInfo: Any?) {
        self.delegate?.UserActions(indexPath: indexPath , isDecrease: isDecrease, action: .comment, actionInformation: dataInfo)
    }
}
