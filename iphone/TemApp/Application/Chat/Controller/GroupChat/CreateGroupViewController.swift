//
//  CreateGroupViewController.swift
//  TemApp
//
//  Created by shilpa on 12/09/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

/// The section for the create group screen
enum GroupInfoSection: Int, CaseIterable {
    case groupName = 0, groupDescription, members, interests, visibility, editableByMembers

    var title: String? {
        switch self {
        case .groupName:
            return "Name".localized
        case .groupDescription:
            return "Description".localized
        case .members:
            return "Participants".localized
        case .interests:
            return "Interests".localized
        case .visibility:
            return "Visibility".localized
        default:
            return nil
        }
    }

    var fieldLeftImage: UIImage? {
        switch self {
        case .groupName, .groupDescription:
            return #imageLiteral(resourceName: "TaskStroke")
        case .members:
            return UIImage(named: "temsWhite")
        case .interests:
            return #imageLiteral(resourceName: "act")
        default:
            return nil
        }
    }
}
protocol EditGroupViewDelegate: AnyObject {
    func didUpdateGroupInformation(updatedGroup: ChatRoom)
}
class CreateGroupViewController: DIBaseController {

    // MARK: Properties
    weak var delegate: EditGroupViewDelegate?
    private var fieldsDataArray = [InputFieldTableCellViewModel]()
    var photoManager: PhotoManager!
    var groupIconChanged: Bool = false
    var chatGroup = ChatRoom()
    private let chatNetworkLayer = DIWebLayerChatApi()
    private var interests: [Activity]?
    var selectedFriends:[Friends]?

    /// this will hold the selected row numbers of the interests activity sheet
    private var selectedActivitySheetIndices: [Int]?

    var screenFrom = Constant.ScreenFrom.createGroup

    // MARK: IBOutlets
    @IBOutlet weak var saveButton: UIButton!{
        didSet{
            saveButton.cornerRadius = saveButton.frame.height / 2
        }
    }
    @IBOutlet weak var groupImageView: UIImageView!{
        didSet{
            groupImageView.cornerRadius = groupImageView.frame.height / 2
        }
    }
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var groupImageGradientView:GradientDashedLineCircularView!{
        didSet{
            groupImageGradientView.configureViewProperties(colors: [ #colorLiteral(red: 0.8862745098, green: 0.6784313725, blue: 0.3921568627, alpha: 1),#colorLiteral(red: 0.7294117647, green: 0.3647058824, blue: 0.7176470588, alpha: 1),UIColor.gray.withAlphaComponent(0.4),UIColor.white.withAlphaComponent(0.4)], gradientLocations: [0, 0])
            groupImageGradientView.instanceWidth = 2.0
            groupImageGradientView.instanceHeight = 6.0
            groupImageGradientView.extraInstanceCount = 1
            groupImageGradientView.lineColor = UIColor.gray
            groupImageGradientView.updateGradientLocation(newLocations: [NSNumber(value: 0.35),NSNumber(value: 0.60),NSNumber(value: 0.89),NSNumber(value: 0.99)], addAnimation: false)
        }
    }
    
    @IBOutlet weak var saveButtonGradientView:GradientDashedLineCircularView!{
        didSet{
            self.createGradientView(view: saveButtonGradientView, colors:[UIColor.cyan.withAlphaComponent(1),UIColor.cyan.withAlphaComponent(0.5), UIColor.gray.withAlphaComponent(0.4),UIColor.white.withAlphaComponent(0.4)])
        }
    }
    
    @IBOutlet weak var saveButtonShadowView:SSNeumorphicView!{
        didSet{
            self.createShadowView(view: saveButtonShadowView, shadowType: .outerShadow, cornerRadius: saveButtonShadowView.frame.height / 2, shadowRadius: 5)
        }
    }
    
    @IBOutlet weak var clearButton:SSNeumorphicButton!{
        didSet{
            clearButton.btnNeumorphicCornerRadius = clearButton.frame.width / 2
            clearButton.btnNeumorphicShadowRadius = 0.8
            clearButton.btnDepthType = .outerShadow
            clearButton.btnNeumorphicLayerMainColor = UIColor.white.cgColor
            clearButton.btnNeumorphicShadowOpacity = 0.25
            clearButton.btnNeumorphicDarkShadowColor = #colorLiteral(red: 0.6392156863, green: 0.6941176471, blue: 0.7764705882, alpha: 0.7)
            clearButton.btnNeumorphicShadowOffset = CGSize(width: -2, height: -2)
            clearButton.btnNeumorphicLightShadowColor = UIColor.black.cgColor
        }
    }
    
    @IBOutlet weak var navBarShadowView:SSNeumorphicView!{
        didSet{
            navBarShadowView.viewDepthType = .innerShadow
            navBarShadowView.viewNeumorphicMainColor = navBarShadowView.backgroundColor?.cgColor
            navBarShadowView.viewNeumorphicLightShadowColor = UIColor(red: 163/255, green: 177/255, blue: 198/255, alpha: 0.5).cgColor
            navBarShadowView.viewNeumorphicDarkShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
            navBarShadowView.viewNeumorphicCornerRadius = 0
        }
    }
    

    // MARK: IBActions
    @IBAction func saveTapped(_ sender: UIButton) {
        guard self.isConnectedToNetwork() else {
            return
        }
        if self.checkForErrorsInGroupInfo() == false {
            self.showLoader()
            if self.groupIconChanged {
                self.getImageUrl { (_) in
                    self.updateGroupInfo()
                }
            } else {
                self.updateGroupInfo()
            }
        }
    }
    
    @IBAction func backButtonTapped(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clearButtonTapped(_ sender:SSNeumorphicButton){
        
    }

    @IBAction func editImageTapped(_ sender: UIButton) {
        photoManager = PhotoManager(navigationController: self.navigationController!, allowEditing: true, callback: { (pickedimage) in
            if(pickedimage != nil) {
                self.groupImageView.image = pickedimage
                self.groupIconChanged = true
            }
        })
    }

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    // MARK: Initializer
    private func initUI() {
        self.tableView.registerNibs(nibNames: [InputFieldTableViewCell.reuseIdentifier,GroupVisibilityTableViewCell.reuseIdentifier])
        let leftBarButtonItem = UIBarButtonItem(customView: self.getBackButton())
      self.setNavigationController(titleName: "TĒM INFO".localized, leftBarButton: [leftBarButtonItem], rightBarButtom: nil, backGroundColor: UIColor.white, translucent: true)
        self.setInitialTableDataSource()
    }

    private func setInitialTableDataSource() {
        if chatGroup.editableByMembers == nil { //this will be in the case if user has not toggle on or off and the user is creating the new group, then by default set it to open with toggle off
            chatGroup.editableByMembers = true
        }
        for section in GroupInfoSection.allCases {
            self.fieldsDataArray.append(InputFieldTableCellViewModel(title: section.title ?? "", inputIconImage: section.fieldLeftImage ?? #imageLiteral(resourceName: "avatar-g"), value: nil, errorMessage: "", isHighlighted: false , toggleState:false))
        }
        self.setFieldValueForSection()
    }

    //set the fields information in case of edit group
    private func setFieldValueForSection() {
        guard self.screenFrom == .editGroup else {
            self.saveButton.setTitle("Save".localized, for: .normal)
            return
        }
        self.saveButton.setTitle("Update".localized, for: .normal)
        self.fieldsDataArray[GroupInfoSection.groupName.rawValue].value = chatGroup.name
        self.fieldsDataArray[GroupInfoSection.groupDescription.rawValue].value = chatGroup.desc
        if let interests = self.chatGroup.interests {
            self.setDisplayedStringForInterests(selected: interests)
        }
        if let groupIcon = chatGroup.icon,
            let url = URL(string: groupIcon) {
            self.groupImageView.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "grp-image"))
        }
        if let visibility = self.chatGroup.visibility {
            self.setDisplayedStringForVisibility(visibility)
        }
        self.tableView.reloadData()
    }

    //change the selected state of textfield to unselected
    private func changeInputFieldState(forSection section: GroupInfoSection) {
        let indexPath = IndexPath(row: 0, section: section.rawValue)
        if let cell = tableView.cellForRow(at: indexPath) as? InputFieldTableViewCell {
            self.fieldsDataArray[section.rawValue].isHighlighted = false
            cell.inputTextField.changeViewFor(selectedState: false)
        }
    }

    // MARK: Helper functions
    private func checkForErrorsInGroupInfo() -> Bool {
        var hasError = false
        if self.chatGroup.name == nil || self.chatGroup.name == "" || (self.chatGroup.name ?? "").trim.isEmpty {
            //show error
            self.fieldsDataArray[GroupInfoSection.groupName.rawValue].errorMessage = AppMessages.Chat.enterGroupName
            hasError = true
        } else {
            self.fieldsDataArray[GroupInfoSection.groupName.rawValue].errorMessage = ""
        }
        if self.screenFrom == .createGroup && (self.chatGroup.memberIds == nil || chatGroup.memberIds?.isEmpty == true) {
            self.fieldsDataArray[GroupInfoSection.members.rawValue].errorMessage = AppMessages.Chat.selectTematesForTem
            hasError = true
        } else {
            self.fieldsDataArray[GroupInfoSection.members.rawValue].errorMessage = ""
        }
        if self.screenFrom == .createGroup && (self.chatGroup.visibility == nil) {
            self.showAlert(withTitle: AppMessages.Chat.selectGroupVisibility, message: nil, okayTitle: "Ok", cancelTitle: nil, okStyle: .default)
            hasError = true
        } else {
            self.fieldsDataArray[GroupInfoSection.visibility.rawValue].errorMessage = ""
        }
        self.tableView.reloadData()
        return hasError
    }

    /// call this function to upload image data on server and get the url
    private func getImageUrl(completion: @escaping (_ finished: Bool) -> Void) {
        guard let data = self.groupImageView.image?.jpegData(compressionQuality: 0.5) else {
            return
        }
        let imagePath = "groupIcon" + Utility.shared.getFileNameWithDate()
        self.chatGroup.imagePath = imagePath
        UploadMedia.shared.configureDataToUpload(type: .awsBucket, data: data, withName: imagePath, mimeType: "jpeg", mediaObj: Media())
        UploadMedia.shared.uploadImage(success: { (url, media) in
            self.chatGroup.icon = url
            completion(true)
        }) { (error) in
            self.hideLoader()
            if let msg = error.message {
                self.showAlert(message: msg)
            }
        }
    }

    override func handleSelection(indices: [Int], type: SheetDataType) {
        switch type {
        case .interests:
            if let interests = self.interests {
                self.selectedActivitySheetIndices = indices
                let selectedInterests = indices.map({ interests[$0] })
                setDisplayedStringForInterests(selected: selectedInterests)
                self.setInterestsForGroup(selectedInterests: selectedInterests)
                self.changeInputFieldState(forSection: .interests)
            }
        case .groupVisibility:
            if indices.count > 0,
               indices[0] < GroupVisibility.allCases.count {
                let value = GroupVisibility.allCases[indices[0]]
                self.setDisplayedStringForVisibility(value)
                self.setVisibilityForGroup(value)
                self.changeInputFieldState(forSection: .visibility)
            }
        default: break
        }
    }

    override func cancelSelection(type: SheetDataType) {
        if type == .interests {
            self.changeInputFieldState(forSection: .interests)
        }
    }

    /// setting the interests in the fields data array
    private func setInterestsForGroup(selectedInterests: [Activity]) {
        self.chatGroup.interests = []
        for interest in selectedInterests {
            chatGroup.interests?.append(interest.toCreateGroupJson())
        }
        let indexPath = IndexPath(row: 0, section: GroupInfoSection.interests.rawValue)
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    private func setDisplayedStringForInterests(selected: [Activity]) {
        let displayFieldValue = selected.map({ $0.name ?? "" }).joined(separator: ", ")
        fieldsDataArray[GroupInfoSection.interests.rawValue].value = displayFieldValue
        if !(displayFieldValue.isEmpty) && displayFieldValue != ""{
            self.setToggleState(viewModalIndex: GroupInfoSection.interests.rawValue, enable: true)
        }else{
            self.setToggleState(viewModalIndex: GroupInfoSection.interests.rawValue, enable: false)
        }
    }

    private func setVisibilityForGroup(_ value: GroupVisibility? = nil) {
        self.chatGroup.visibility = value
    }

    private func setDisplayedStringForVisibility(_ value: GroupVisibility) {
        let displayFieldValue = value.name
        fieldsDataArray[GroupInfoSection.visibility.rawValue].value = displayFieldValue
    }

    private func editGroupInfoCompletion() {
        if let roomId = self.chatGroup.groupId {
            self.chatGroup.chatType = .groupChat
            ChatManager().updateChatRoomInformationToDatabase(roomId: roomId, groupInfo: chatGroup)
        }
        self.delegate?.didUpdateGroupInformation(updatedGroup: self.chatGroup)
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: Api Calls
    private func updateGroupInfo() {
        switch self.screenFrom {
        case .createGroup:
            //create group api call
            self.createChatGroup()
        case .editGroup:
            //edit group api call
            self.editChatGroup()
        default:
            break
        }
    }

    private func createChatGroup() {
        guard self.isConnectedToNetwork() else {
                return
        }
        let params = chatGroup.createGroupJson().json()
        self.chatNetworkLayer.createGroup(params: params, completion: {[weak self] (roomId) in
            self?.hideLoader()
            if let roomID = roomId,
                let chatInfo = self?.chatGroup {
                chatInfo.chatType = .groupChat
                chatInfo.createdAt = Date().timeIntervalSince1970 //adding the current time to the group
                ChatManager().updateChatRoomInformationToDatabase(roomId: roomID, groupInfo: chatInfo)
            }
            //redirect to the chat screen
            self?.navigationController?.popViewController(animated: true)
        }) {[weak self] (error) in
            self?.hideLoader()
            if let msg = error.message {
                self?.showAlert(message: msg)
            }
        }
    }

    private func editChatGroup() {
        guard self.isConnectedToNetwork() else {
            return
        }
        let params = chatGroup.editGroupJson().json()
        self.chatNetworkLayer.editGroup(params: params, completion: {[weak self] (finished) in
            self?.hideLoader()
            self?.editGroupInfoCompletion()
        }) {[weak self] (error) in
            self?.hideLoader()
            if let msg = error.message {
                self?.showAlert(message: msg)
            }
        }
    }

    private func getInterests() {
        if self.interests == nil || self.interests?.isEmpty == true {
            self.showLoader()
            DIWebLayerUserAPI().getInterestsList(success: { (data) in
                self.hideLoader()
                if self.interests == nil {
                    self.interests = []
                }
                self.interests?.append(contentsOf: data)
                if let preSelectedInterests = self.chatGroup.interests {
                    if self.selectedActivitySheetIndices == nil {
                        self.selectedActivitySheetIndices = []
                    }
                    let preSelectedInterestIds = preSelectedInterests.map({$0.interestId ?? ""})
                    if let allInterests = self.interests {
                        for (index, interest) in allInterests.enumerated() {
                            if preSelectedInterestIds.contains(interest.id ?? "") {
                                self.selectedActivitySheetIndices?.append(index)
                            }
                        }
                    }
                }
                self.showSelectionModal(array: data, type: .interests, multiSelectionOn: true, selectedIndices: self.selectedActivitySheetIndices)
            }) { (error) in
                self.hideLoader()
                self.showAlert(message:error.message)
            }
        } else {
            if let interestsData = self.interests {
                self.showSelectionModal(array: interestsData, type: .interests, multiSelectionOn: true, selectedIndices: selectedActivitySheetIndices)
            }
        }
    }

    func selectGroupVisibility() {
        self.showSelectionModal(array: GroupVisibility.allCases, type: .groupVisibility, multiSelectionOn: false)
    }
    
    func createGradientView(view:GradientDashedLineCircularView , colors:[UIColor]){
        
        view.configureViewProperties(colors: colors, gradientLocations: [0, 0], startEndPint: GradientLocation(startPoint: CGPoint(x: 0.25, y: 0.5)))
        view.instanceWidth = 2.0
        view.instanceHeight = 6.0
        view.extraInstanceCount = 1
        view.lineColor = UIColor.gray
        view.updateGradientLocation(newLocations: [NSNumber(value: 0.35),NSNumber(value: 0.60),NSNumber(value: 0.89),NSNumber(value: 0.99)], addAnimation: false)
    }
    
    func createShadowView(view: SSNeumorphicView, shadowType: ShadowLayerType, cornerRadius:CGFloat,shadowRadius:CGFloat){
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor =  UIColor.white.cgColor
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.7).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = cornerRadius
        view.viewNeumorphicShadowRadius = shadowRadius
        view.viewNeumorphicShadowOffset = CGSize(width: 2, height: 2 )
    }
    
    func setToggleState(viewModalIndex:Int, enable:Bool){
        fieldsDataArray[viewModalIndex].toggleState = enable
    }
}

// MARK: InputFieldTableCellDelegate
extension CreateGroupViewController: InputFieldTableCellDelegate {
    func inputTextFieldDidEndEditing(textField: UITextField) {
        self.fieldsDataArray[textField.tag].isHighlighted = false
        self.fieldsDataArray[textField.tag].value = textField.text
        if let currentField = GroupInfoSection(rawValue: textField.tag) {
            switch currentField {
            case .groupName:
                self.chatGroup.name = textField.text?.trim
            case .groupDescription:
                self.chatGroup.desc = textField.text?.trim
            default:
                break
            }
            if textField.text?.isEmpty ?? false{
                self.setToggleState(viewModalIndex: textField.tag, enable: false)
            }else{
                self.setToggleState(viewModalIndex: textField.tag, enable: true)
            }
            let indexPath = IndexPath(row: 0, section: currentField.rawValue)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

    func inputTextFieldDidBeginEditing(textField: UITextField) {}

    func didTapDoneOnInputTextField(sender: UIBarButtonItem) {}

    func inputTextFieldShouldBeginEditing(textField: UITextField) -> Bool {
        self.fieldsDataArray[textField.tag].isHighlighted = true
        if let currentField = GroupInfoSection(rawValue: textField.tag) {
            switch currentField {
            case .members:
                self.view.endEditing(true)
                self.changeInputFieldState(forSection: .members)
                let friendsController: InviteFriendController = UIStoryboard(storyboard: .challenge).initVC()
                friendsController.selectedFriends = self.selectedFriends ?? [Friends]()
                friendsController.delegate = self
                self.navigationController?.pushViewController(friendsController, animated: true)
                return false
            case .interests:
                self.view.endEditing(true)
                self.changeInputFieldState(forSection: .interests)
                self.getInterests()
                return false
            case .visibility:
                self.view.endEditing(true)
                self.selectGroupVisibility()
                return false
            default:
                return true
            }
        }
        return true
    }
}

// MARK: GroupTypeTableCellDelegate
extension CreateGroupViewController: GroupTypeTableCellDelegate {
    func groupTypeToggle(on: Bool) {
        self.chatGroup.editableByMembers = on
    }
}

// MARK: InviteFriendControllerViewDelegate
extension CreateGroupViewController: InviteFriendControllerViewDelegate {
    func didSelectTemates(members: [Friends]) {
        selectedFriends = members
        self.setInvitedMembers(members: members)
        let indexPath = IndexPath(row: 0, section: GroupInfoSection.members.rawValue)
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    // set the friends array in the temates section and returns the names of the members by concatenating
    func setInvitedMembers(members: [Friends]) {
        var membersNameString = ""
        var concatenator = ", "
        self.chatGroup.members = []
        self.chatGroup.memberIds = []
        for (index, member) in members.enumerated() {
            if index == (members.count - 1) { //if this is the last string
                concatenator = ""
            }
            membersNameString += "\(member.fullName)\(concatenator)"
            let userId = member.id
            member.user_id = userId
            self.chatGroup.members?.append(member)
            if let memberId = member.id {
                self.chatGroup.memberIds?.append(memberId)
            }
        }
        self.fieldsDataArray[GroupInfoSection.members.rawValue].value = membersNameString
        self.setToggleState(viewModalIndex: GroupInfoSection.members.rawValue, enable: true)
    }
}

// MARK: UITableViewDataSource
extension CreateGroupViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return GroupInfoSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection = GroupInfoSection(rawValue: section) {
            switch currentSection {
            case .members:
                if self.screenFrom == .editGroup {
                    return 0
                }
            case .editableByMembers:
                if self.screenFrom == .editGroup,
                    self.chatGroup.admin?.userId != UserManager.getCurrentUser()?.id {
                    //if this is not the admin, then the user should not be allowed to change the group type
                    return 0
                }
            case .visibility:
                if self.screenFrom == .editGroup,
                   self.chatGroup.admin?.userId != UserManager.getCurrentUser()?.id {
                    //if this is not the admin, then the user should not be allowed to change the group visibility
                    return 0
                }
            default:
                return 1
            }
        }
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let section = GroupInfoSection(rawValue: indexPath.section) {
            switch section {
            case .groupName, .members, .interests, .groupDescription:
                let cell = tableView.dequeueReusableCell(withIdentifier: InputFieldTableViewCell.reuseIdentifier, for: indexPath) as! InputFieldTableViewCell
                cell.delegate = self
                cell.inputTextField.placeholder = section.title
                cell.inputTextField.font =  UIFont(name: "Avenir Next Medium", size: 16.0)
                cell.showToggle(isHide: false)
                cell.customiseTextFieldShadowFromCell(cornerRadius: 10.5, shadowType: .innerShadow, shadowRadius: 3, mainColor: UIColor.white.cgColor, lightShadowColor: UIColor.white.withAlphaComponent(0.7).cgColor, darkShadowView: UIColor.black.withAlphaComponent(0.3).cgColor)
                cell.initializeWith(viewModel: self.fieldsDataArray[indexPath.section], indexPath: indexPath)
                return cell
            case .visibility:
                let cell = tableView.dequeueReusableCell(withIdentifier: GroupVisibilityTableViewCell.reuseIdentifier, for: indexPath) as! GroupVisibilityTableViewCell
                cell.delegate = self
                return cell
            case .editableByMembers:
                let cell = tableView.dequeueReusableCell(withIdentifier: GroupTypeTableViewCell.reuseIdentifier, for: indexPath) as! GroupTypeTableViewCell
                cell.delegate = self
                cell.initialize(editableByMembers: chatGroup.editableByMembers)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let section = GroupInfoSection(rawValue: indexPath.section) {
            switch section {
            case .groupName, .members, .interests, .groupDescription:
                return 60
            default:
                return UITableView.automaticDimension
            }
        }
        return UITableView.automaticDimension
    }
}

extension CreateGroupViewController: GroupVisibilityTableViewCellDelegate{
    func didTapOnToggleButton(sender: UIButton) {
        if sender.isSelected{
            let value = GroupVisibility.allCases[sender.tag]
            self.setVisibilityForGroup(value)
        }
        else{
            self.setVisibilityForGroup(nil)
        }
    }
}
