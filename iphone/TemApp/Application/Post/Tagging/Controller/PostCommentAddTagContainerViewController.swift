//
//  PostCommentAddTagContainerViewController.swift
//  TemApp
//
//  Created by shilpa on 22/01/20.
//

import UIKit
import IQKeyboardManagerSwift

protocol PostCommentAddTagDelegate: AnyObject {
    func updateCommentOnPost(indexPath: IndexPath, isDecrease: Bool, commentInfo: Comments)
    func hideCommentView()
    func resetTableOffsetToBottom(indexPath: IndexPath)
}

class PostCommentAddTagContainerViewController: DIBaseController {

    // MARK: Properties
    weak var delegate: PostCommentAddTagDelegate?
    private let minimumHeight: CGFloat = 33
    private var currentTaggedIds: [UserTag]?
    private var tagUsersListViewController: TagUsersListViewController?
    var indexPath: IndexPath?
    var postId: String?
    //this will track the status when the post comment api will call to avoid duplicacy
    private var isPostingComment = false
    
    // MARK: IBOutlets
    @IBOutlet weak var tagListContainerView: UIView!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var commentTextView: IQTextView!
    @IBOutlet weak var commentTextViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: IBActions
    @IBAction func postButtonTapped(_ sender: UIButton) {
        if self.isPostingComment == false {
            self.postComment()
        }
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isPostingComment = false
        self.setUserProfilePicture()
        self.commentTextView.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneTappedOnKeyboard(sender:)))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touch began")
        if let touchedLoc = touches.first?.location(in: self.tagListContainerView),
            tagListContainerView.bounds.contains(touchedLoc) {
            self.resetEditingMode()
            self.delegate?.hideCommentView()
        }
    }
    
    // MARK: Helpers
    private func updateHeightOfTextView(textView: UITextView) {
        self.commentTextViewHeightConstraint.constant = textView.contentSize.height
        if self.commentTextViewHeightConstraint.constant > 67 {
            self.commentTextViewHeightConstraint.constant = 67
        }
    }
    
    private func setUserProfilePicture() {
        if let imageUrl = URL(string:User.sharedInstance.profilePicUrl ?? "") {
            self.userProfileImageView.kf.setImage(with: imageUrl, placeholder:#imageLiteral(resourceName: "user-dummy"))
        }else{
            self.userProfileImageView.image = #imageLiteral(resourceName: "user-dummy")
        }
    }
    
    func setFirstResponder() {
        self.tagUsersListViewController?.setTaggingDataSource()
        self.tagUsersListViewController?.removePreviousMatches()
        self.tagUsersListViewController?.screenFrom = .newsFeeds
        tagListContainerView.isHidden = true
        self.setPostButton(enable: false)
        commentTextViewHeightConstraint.constant = minimumHeight
        self.commentTextView.text = ""
        self.commentTextView.becomeFirstResponder()
    }
    
    func resetEditingMode() {
        self.commentTextView.resignFirstResponder()
        self.setPostButton(enable: false)
        self.commentTextView.text = ""
    }
    
    private func setPostButton(enable: Bool) {
        if enable {
            self.postButton.setTitleColor(.white, for: .normal)
            self.postButton.isUserInteractionEnabled = true
        } else {
            self.postButton.setTitleColor(UIColor(red: 148/255, green: 199/255, blue: 240/255, alpha: 1.0), for: .normal)
            self.postButton.isUserInteractionEnabled = false
        }
    }
    
    @objc func doneTappedOnKeyboard(sender: UIBarButtonItem) {
        print("done tapped on keyboard")
        //call the post comment api
        if self.isPostingComment == false {
            self.postComment(isDoneOnKeyboardToolbarTapped: true)
        }
    }
    
    private func showError(message: String, isDoneOnKeyboardToolbarTapped: Bool) {
        if isDoneOnKeyboardToolbarTapped {
            //self.showAlert(message: message)
            self.showAlert(withTitle: "", message: message, okayTitle: AppMessages.AlertTitles.Ok, okCall: {
            })
        } else {
            //present alert on window, so that the keyboard is not dismissed
            let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: AppMessages.AlertTitles.Ok, style: .default, handler: nil)
            alert.addAction(action)
            UIApplication.shared.windows.last?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: Api Call
    private func postComment(isDoneOnKeyboardToolbarTapped: Bool? = false) {
        if isDoneOnKeyboardToolbarTapped! == false {
            if commentTextView.text.isBlank {
                self.isPostingComment = false
                self.showError(message: AppMessages.Comments.enterComment, isDoneOnKeyboardToolbarTapped: isDoneOnKeyboardToolbarTapped!)
                return
            }
        } else {
            //if keyboard done button was tapped, and the textview is empty, just dismiss the keyboard without calling the api
            if commentTextView.text.isBlank {
                self.isPostingComment = false
                return
            }
        }
        if !(Reachability.isConnectedToNetwork()) {
            self.isPostingComment = false
            self.showError(message: AppMessages.AlertTitles.noInternet, isDoneOnKeyboardToolbarTapped: isDoneOnKeyboardToolbarTapped!)
            return
        }
        var objComment = Comment()
        objComment.postId = self.postId ?? ""
        objComment.comment = commentTextView.text.trim
        if let taggedIds = self.currentTaggedIds,
            !taggedIds.isEmpty {
            objComment.taggedIds = taggedIds
        }
        currentTaggedIds = nil
        self.commentTextView.text = ""
        self.postButton.isUserInteractionEnabled = false
        self.commentTextViewHeightConstraint.constant = 33
        
        self.tagUsersListViewController?.resetTagList()
        self.showLoader()
        self.isPostingComment = true
        DIWebLayerUserAPI().addcomment(parameters: objComment.getDictionary(), success: { (data) in
            self.isPostingComment = false
            self.hideLoader()
            self.commentTextView.resignFirstResponder()
            if let path = self.indexPath {
                //setting the comment data
                let commentInformation = Comments()
                commentInformation.comment = objComment.comment
                let userInformation = UserId()
                userInformation.userName = UserManager.getCurrentUser()?.userName
                userInformation.firstName = UserManager.getCurrentUser()?.firstName
                userInformation.lastName = UserManager.getCurrentUser()?.lastName
                userInformation.id = UserManager.getCurrentUser()?.id
                commentInformation.userId = userInformation
                commentInformation.taggedIds = []
                if let taggedIds = data["commentTagIds"] as? [Parameters] {
                    commentInformation.taggedIds = taggedIds.map({ (data) -> UserTag in
                        return UserTag(dict: data)
                    })
                }
                self.delegate?.updateCommentOnPost(indexPath: path, isDecrease: false, commentInfo: commentInformation)
                self.delegate?.hideCommentView()
            }
        }) { (error) in
            self.isPostingComment = false
            self.hideLoader()
//            self.showAlert(message:error.message)
            self.showError(message: error.message ?? "", isDoneOnKeyboardToolbarTapped: isDoneOnKeyboardToolbarTapped!)
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTagListView",
            let destinationController = segue.destination as? TagUsersListViewController {
            self.tagUsersListViewController = destinationController
            destinationController.delegate = self
            destinationController.listType = .commentTagging
        }
    }
}

// MARK: UITextViewDelegate
extension PostCommentAddTagContainerViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.updateHeightOfTextView(textView: textView)
        var hidebutton = false
        if (textView.text.count == 1 && text.count == 0) {
            hidebutton = true
        }
        if (textView.text.count + text.count) >= 1 && (hidebutton == false){
            self.setPostButton(enable: true)
        }else{
            self.setPostButton(enable: false)
        }
        if textView.text.count + text.count > 2000 {
            return false
        }
        
        Tagging.sharedInstance.updateTaggedList(range: range, textCount: text.utf16.count)
        
        //self.postData?.commentText = textView.text
        //self.setCommentText(text: textView.text)
        commentTextView.textColor = .white
        self.commentTextView.attributedText = NSAttributedString(string: commentTextView.attributedText.string, attributes: [.foregroundColor: UIColor.white])
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        Tagging.sharedInstance.tagging(textView: textView)
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        //Tagging
        //tagging text view if changed
        Tagging.sharedInstance.tagging(textView: textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let indexPath = indexPath {
            self.delegate?.resetTableOffsetToBottom(indexPath: indexPath)
        }
    }
}

// MARK: TagUsersListViewDelegate
extension PostCommentAddTagContainerViewController: TagUsersListViewDelegate {
    func didChangeTaggedList(taggedList: [TaggingModel]) {
        self.currentTaggedIds = taggedList.map({ $0.toUserTagModel() })
    }
    
    func didChangeTaggableList(isEmpty: Bool) {
        self.tagListContainerView.isHidden = isEmpty
    }
    
    func didSelectUserFromTagList(tagText: String, userId: String) {
        Tagging.sharedInstance.updateTaggedList(allText: commentTextView.text, tagText: tagText, id: userId)
    }
    
    func updateAttributedTextOnTagSelect(attributedValue: (NSMutableAttributedString, NSRange)) {
        self.commentTextView.attributedText = attributedValue.0
        self.commentTextView.selectedRange = attributedValue.1
        self.updateHeightOfTextView(textView: commentTextView)
        self.commentTextView.attributedText = NSAttributedString(string: commentTextView.attributedText.string, attributes: [.foregroundColor: UIColor.white])
    }
}

