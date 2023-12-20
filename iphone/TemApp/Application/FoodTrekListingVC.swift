//
//  FoodTrekListingVC.swift
//  TemApp
//
//  Created by Developer on 28/02/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

enum SelectedButton:Int,CaseIterable{
    case today = 0
    case history = 1
}

class FoodTrekListingVC: DIBaseController {
    var isOtherUser:Bool = false
    var userId:String = ""
    var showHistoryOfTreks:Bool = false
    var chatRoomId:String?
    var chatName:String?
    var chatImageURL:URL?
    weak var delegate: PostTableCellDelegate?
    private var foodTrek:[FoodTrekModel] = [FoodTrekModel]()
    var selectedButton:SelectedButton = .today
    var waterTrackingCount = 0

   
    @IBOutlet weak var waterTrackingLabel: UILabel!
    @IBOutlet weak var waterLabel: UILabel!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var todayBackView: UIView!
    @IBOutlet weak var historyBackView: UIView!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var onTrekLbl:UILabel!
    @IBOutlet weak var streakLbl:UILabel!
    @IBOutlet weak var dateLbl:UILabel!
    @IBOutlet weak var settingBtn:UIButton!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var bottomView2: UIView!
    @IBOutlet var todayButton: UIButton!
    @IBOutlet var historyButton: UIButton!
    @IBOutlet var messageButton: UIButton!
    @IBOutlet var addButton: UIButton!
    @IBOutlet weak var bottomOnTrekLbl:UILabel!
    @IBOutlet weak var bottomStreakLbl:UILabel!
    @IBOutlet var navigationBarLineView: [SSNeumorphicView]! {
        didSet{
            for view in navigationBarLineView {
                view.viewDepthType = .innerShadow
                view.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
                view.viewNeumorphicLightShadowColor = UIColor.appThemeDarkGrayColor.cgColor
                view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
                view.viewNeumorphicCornerRadius = 0
            }
        }
    }
    
    @IBOutlet weak var todayBtnView: SSNeumorphicView! {
        didSet{
            selectToday(isSelected: true)
        }
    }
    
    @IBOutlet weak var historyBtnView: SSNeumorphicView! {
        didSet{
            selectHistory(isSelected: false)
        }
    }


    @IBOutlet weak var waterTrackerView: SSNeumorphicView! {
        didSet{
            waterTrackerView.viewDepthType = .outerShadow
            waterTrackerView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
            waterTrackerView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
            waterTrackerView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
            waterTrackerView.viewNeumorphicCornerRadius = waterTrackerView.bounds.height / 2
        }
    }
    @IBOutlet weak var addBtnView: SSNeumorphicView! {
        didSet{
            addBtnView.viewDepthType = .outerShadow
            addBtnView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
            addBtnView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
            addBtnView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
            addBtnView.viewNeumorphicCornerRadius = addBtnView.bounds.height / 2
        }
    }
    @IBOutlet weak var msgBtnView: SSNeumorphicView! {
        didSet{
            msgBtnView.viewDepthType = .outerShadow
            msgBtnView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
            msgBtnView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
            msgBtnView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
            msgBtnView.viewNeumorphicCornerRadius = msgBtnView.bounds.height / 2
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateLbl.text = getDateForLbl(date: Date())
        settingBtn.addDoubleShadowToButton(cornerRadius: settingBtn.frame.height / 2, shadowRadius: 0.8, lightShadowColor: UIColor.white.withAlphaComponent(0.3).cgColor, darkShadowColor: UIColor.black.withAlphaComponent(0.3).cgColor, shadowBackgroundColor: UIColor.appThemeDarkGrayColor)
        settingBtn.setImage(UIImage(named: "setting_settings")?.withRenderingMode(.alwaysTemplate), for: .normal)
        settingBtn.tintColor = .white
        todayBackView.cornerRadius = todayBackView.frame.height / 2
        historyBackView.cornerRadius = historyBackView.frame.height / 2
        initUIForOtherUser()
    }
    
    
    // MARK: ViewWillAppear.
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(true)
        if self.selectedButton == .today {
            getFoodTrek()
        } else {
            getFoodTrek(type: 2)
        }
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func initUIForOtherUser(){
        if isOtherUser{
            messageButton.isHidden = false
            msgBtnView.isHidden = false
            addBtnView.isHidden = true
            waterTrackerView.isHidden = true
            waterLabel.isHidden = true
            addButton.isHidden = true
            settingBtn.isHidden = true
        }
    }
    private func getDateForLbl(date:Date) -> String{
        let dateString = date.toString(inFormat: .foodTrek) ?? ""
        let uppercasedDate = dateString.uppercased()
        return uppercasedDate
    }
    
    private func selectToday(isSelected: Bool) {
        todayBtnView.viewDepthType = .innerShadow
        todayBtnView.viewNeumorphicMainColor = isSelected ? UIColor.appThemeColor.cgColor : UIColor.appThemeDarkGrayColor.cgColor
        todayBtnView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
        todayBtnView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        todayBtnView.viewNeumorphicCornerRadius = todayBtnView.bounds.height / 2
    }
    
    private func selectHistory(isSelected: Bool) {
        historyBtnView.viewDepthType = .innerShadow
        historyBtnView.viewNeumorphicMainColor = isSelected ? UIColor.appThemeColor.cgColor : UIColor.appThemeDarkGrayColor.cgColor
        historyBtnView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
        historyBtnView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        historyBtnView.viewNeumorphicCornerRadius = historyBtnView.bounds.height / 2
    }
    
    func getTrekTime(timeStamp: Int) -> String {
        let sDate = String(describing: timeStamp)
        var date = Date()
        if sDate.count == 10 {
            date = timeStamp.toDate
        }
        else if sDate.count == 13 {
            date = timeStamp.timestampInMillisecondsToDate
        }
        return date.toString(inFormat: .time) ?? ""
    }
    
    private func redirectToChatRoom(){
        guard let chatRoomId = chatRoomId else {
            return
        }
        
        let chatController: ChatViewController = UIStoryboard(storyboard: .chatListing).initVC()
        chatController.chatRoomId = chatRoomId
        chatController.chatName = chatName
        if let url = chatImageURL{
            chatController.chatImageURL = url
        }else{
            chatController.chatImageURL = URL(string: "")
        }
        self.navigationController?.pushViewController(chatController, animated: true)
    }
    
    private func getFoodTrek(type:Int = 1) {
        PostManager.shared.getFoodTrek(userId:userId,isOtherUser:isOtherUser, type: type, completion: { (foodtreks,on_treak,streak, waterCount) in
            self.foodTrek.removeAll()
            self.foodTrek = foodtreks
            DispatchQueue.main.async {
                self.streakLbl.text = "\(streak) STREAK"
                self.waterTrackingLabel.text = "\(waterCount)"
                self.waterTrackingCount = waterCount
                if let value = Double(on_treak)?.toInt(){
                    let intON_Trek = value
                    self.onTrekLbl.text = "\(intON_Trek)% ON TRACK"
                } else{
                    self.onTrekLbl.text = "0% ON TRACK"
                }
                self.tableView.reloadData()
            }
        }) { (error) in
        }
    }

    @IBAction func onClickAdd(_ sender:UIButton) {
        self.showYPPhotoGallery(showCrop: false,isFromFoodTrek:true)
    }

    @IBAction func onClickMessage(_ sender:UIButton) {
        redirectToChatRoom()
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func waterTrackingButtonsTApped(_ sender: UIButton) {
        self.showLoader()
        if sender.tag == 1{ //Decrement pressed
            if waterTrackingCount > 0{
                self.waterTrackingCount -= 1
            }
        } else{ //Increment pressed
            self.waterTrackingCount += 1
        }
        saveWaterTracking()
    }
    @IBAction func settingsTapped(_ sender: UIButton) {
        let settingsVC:FoodTrekSettingsController = UIStoryboard(storyboard: .settings).initVC()
        //        self.navigationController?.pushViewController(settingsVC, animated: true)
        self.present(settingsVC, animated: true)
    }

    @IBAction func onClickToday(_ sender:UIButton) {
        DispatchQueue.main.async {
            self.bottomViewHeight.constant = 62.0
            self.bottomView.isHidden = false
        }
        self.selectedButton = .today
        selectToday(isSelected: true)
        selectHistory(isSelected: false)
        todayBackView.isHidden = false
        historyBackView.isHidden = true
        getFoodTrek(type: 1)
    }
    
    @IBAction func onClickHistory(_ sender:UIButton) {
        DispatchQueue.main.async {
            self.bottomViewHeight.constant = 0.0
            self.bottomView.isHidden = true
        }
        
        self.selectedButton = .history
        selectToday(isSelected: false)
        selectHistory(isSelected: true)
        todayBackView.isHidden = true
        historyBackView.isHidden = false
        getFoodTrek(type: 2)
    }
    @IBAction func onClickComment(_ sender:UIButton) {
        let index = sender.tag
        redirectToComments(index: index)
    }
    
    @IBAction func onClickRightComment(_ sender:UIButton) {
        let index = sender.tag
        redirectToComments(index: index)
    }
    
    @IBAction func onClickRightLike(_ sender:UIButton) {
        let index = sender.tag
        likePost(index: index)
    }
    
    @IBAction func onClickLeftLike(_ sender:UIButton) {
        let index = sender.tag
        likePost(index: index)
    }

    private func saveWaterTracking(){
        let date = Date()
        let startDate = date.startOfDay.locaToUTCString(inFormat: .preDefined)
        let endDate = date.endOfDay.locaToUTCString(inFormat: .preDefined)
        let params = [ "waterintake":waterTrackingCount,
                       "startDate":startDate,
                       "endDate":endDate
        ] as [String : Any]
        PostManager.shared.saveWaterTracker(params: params, completion: {self.hideLoader()}, failure: {error in
            self.hideLoader()
            self.showAlert(withError: error)
        })
        self.waterTrackingLabel.text = "\(waterTrackingCount)"
    }

    private func likePost(index: Int) {
        let status = foodTrek[index].likes.contains(where: { $0.user_id == User.sharedInstance.id ?? "" })
        let params:[String:Any] = ["post_id":foodTrek[index]._id,"status": status ? 2 : 1]
        DIWebLayerUserAPI().likeOrDislikePost(isFromTrek:true, parameters: params, success: { (_) in
            self.getFoodTrek(type: 1)
        }) { (error) in
            fatalError(error.message?.localized ?? "")
        }
    }
    
    private func redirectToComments(index: Int) {
        let commentsVC: CommentsController = UIStoryboard(storyboard: .post).initVC()
        commentsVC.postId = self.foodTrek[index]._id
        commentsVC.isFromFoodTrek = true
        self.navigationController?.pushViewController(commentsVC, animated: true)
    }
    
    private func redirectToProfile(userId: String) {
        let profileController: ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
        if userId != (UserManager.getCurrentUser()?.id ?? "") { //is this is not me who is tagged
            profileController.otherUserId = userId
        }
        self.navigationController?.pushViewController(profileController, animated: true)
    }
    override func didSelectRowWithValue(data: Any, type: SheetDataType) {
        if type == .taggedList {
            if let user = data as? UserTag, let userId = user.id {
                redirectToProfile(userId: userId)
            }
        } else {
            return
        }
    }
}

extension FoodTrekListingVC:UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selectedButton{
            case .today:
                return foodTrek.count
            case .history:
                return foodTrek.count
        }
    }
    
    //To Perform Unwind Seque
    @IBAction func performUnwindSegueOperation(_ sender: UIStoryboardSegue) {
        //    guard let foodTrekListingVC = sender.source as? FoodTrekListingVC else { return }
        
        if self.selectedButton == .today {
            getFoodTrek()
        } else {
            getFoodTrek(type: 2)
        }
        
    }
    
    //dfdfdfdfdfd
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var isLeftTrek: Bool?
        switch selectedButton {
            case .today:
                let data = foodTrek[indexPath.row]
                let cell = tableView.dequeueReusableCell(withIdentifier: "TrekLeftTVC", for: indexPath) as! TrekLeftTVC
                let status = foodTrek[indexPath.row].likes.contains(where: { $0.user_id == User.sharedInstance.id ?? "" })
                if data.trek == 1 {
                    isLeftTrek = true
                    if indexPath.row == foodTrek.count - 1 {
                        cell.leftBottomLbl.isHidden = true
                    } else {
                        
                        let value = indexPath.row + 1
                        if foodTrek[value].trek == 1 {
                            cell.leftBottomLbl.isHidden = true
                        } else if foodTrek[value].trek == 2 {
                            cell.leftBottomLbl.isHidden = false
                        }
                    }
                    cell.view1.isHidden = false
                    cell.view2.isHidden = true
                    cell.leftButton.tag = indexPath.row
                    cell.leftLikeButton.tag = indexPath.row
                    cell.leftTimeLbl.text = getTrekTime(timeStamp: data.date ?? 0)
                    if status {
                        cell.leftLikeButton.setImage(#imageLiteral(resourceName: "high five-blue"), for: .normal)
                    } else {
                        cell.leftLikeButton.tintColor = .black
                        cell.leftLikeButton.setImage(#imageLiteral(resourceName: "high five"), for: .normal)
                    }
                    cell.imageView1.kf.indicatorType = .activity
                    if let text = data.text, text.count > 0 {
                        cell.leftcaptionShadowView.isHidden = false
                        cell.lbl.row = indexPath.row
                        cell.lbl.section = indexPath.section
                        cell.lbl.text = text
                        cell.setAndDetectTagsInCaption(descriptionLabel: cell.lbl)
                    } else {
                        cell.leftcaptionShadowView.isHidden = true
                    }
                    if let urlString = data.image,
                       let url = URL(string: urlString) {
                        cell.imageView1.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: { (receivedSize, totalSize) in
                        }, completionHandler: {(result) in
                        })
                    }
                } else {
                    isLeftTrek = false
                    if indexPath.row == foodTrek.count - 1 {
                        cell.leftBottomLbl.isHidden = true
                    } else {
                        
                        let value = indexPath.row + 1
                        if foodTrek[value].trek == 1 {
                            cell.leftBottomLbl.isHidden = false
                        } else if foodTrek[value].trek == 2 {
                            
                            cell.leftBottomLbl.isHidden = true
                        }
                    }
                    cell.view2.isHidden = false
                    cell.view1.isHidden = true
                    cell.rightButton.tag = indexPath.row
                    cell.rightLikeButton.tag = indexPath.row
                    cell.rightTimeLbl.text = getTrekTime(timeStamp: data.date ?? 0)
                    if status {
                        cell.rightLikeButton.setImage(#imageLiteral(resourceName: "high five-blue"), for: .normal)
                    } else {
                        cell.rightLikeButton.tintColor = .black
                        cell.rightLikeButton.setImage(#imageLiteral(resourceName: "high five"), for: .normal)
                    }
                    cell.imageView2.kf.indicatorType = .activity
                    if let text = data.text, text.count > 0 {
                        cell.rightcaptionShadowView.isHidden = false
                        cell.lbl1.row = indexPath.row
                        cell.lbl1.section = indexPath.section
                        cell.lbl1.text = text
                        cell.setAndDetectTagsInCaption(descriptionLabel: cell.lbl1)
                    } else {
                        cell.rightcaptionShadowView.isHidden = true
                    }
                    
                    if let urlString = data.image,
                       let url = URL(string: urlString) {
                        cell.imageView2.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: { (receivedSize, totalSize) in
                        }, completionHandler: {(result) in
                        })
                    }
                }
                cell.rightTagButton.row = indexPath.row
                cell.leftTagButton.row = indexPath.row
                cell.leftTagButton.section = indexPath.section
                cell.rightTagButton.section = indexPath.section
                cell.checkForAnyTagInMedia(tagIds: foodTrek[indexPath.row].postTagIds ?? [UserTag](),isLeftTrek: isLeftTrek ?? false)
                cell.delegate = self
                if let isLeftTrek = isLeftTrek {
                    let dir: WaterTrackerDirection = isLeftTrek ? .left : .right
                    var nextDir: WaterTrackerDirection = dir
                    if indexPath.row < foodTrek.count - 1 {
                        let nextTrek = foodTrek[indexPath.row + 1].trek ?? 0
                        nextDir = nextTrek == 1 ? .left : .right
                    }
                    cell.fillData(currentDirection: dir, nextDirection: nextDir)
                }
                return cell
            case .history:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTrekTVC", for: indexPath) as! HistoryTrekTVC
                
                let data = foodTrek[indexPath.row]
                cell.initializeCell = data
                cell.trekValueLbl.isHidden = false
                return cell
                
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch selectedButton{
            case .history:
                let data = foodTrek[indexPath.row]
                let foodTrekHistoryListingVC:FoodTrekHistoryListingVC = UIStoryboard(storyboard: .foodTrek).initVC()
                foodTrekHistoryListingVC.isOtherUser = self.isOtherUser
                foodTrekHistoryListingVC.userId = self.userId
                foodTrekHistoryListingVC.selectedDate = data.date ?? 0
                self.navigationController?.pushViewController(foodTrekHistoryListingVC, animated: true)
                
                
            default:
                break
        }
    }
}
extension FoodTrekListingVC: PostTableCellDelegate {
    func collectionViewDidScroll(newContentOffset: CGPoint, scrollView: UIScrollView) {}
    
    func adjustTableHeight(scrollToTp: Bool) {}
    
    func UserActions(indexPath: IndexPath, isDecrease: Bool, action: UserActions, actionInformation: Any?) {}
    
    func didTapOnSharePostWith(id: String, indexPath: IndexPath) {}
    
    func didTapMentionOnCaptionAt(row: Int, section: Int, tagText: String) {
        if let captionTaggedIds = self.foodTrek[row].captionTagIds {
            let currentTagged = captionTaggedIds.filter({$0.text == tagText})
            if let userId = currentTagged.first?.id {
                redirectToProfile(userId: userId)
            }
        }
    }
    
    func didTapOnViewTaggedPeople(sender: CustomButton) {
        let indexPath = IndexPath(item: sender.row, section: 0)
        if let taggedList = foodTrek[indexPath.row].postTagIds {
            self.showSelectionModal(array: taggedList, type: .taggedList)
        }
    }
    
    func didTapMentionOnCommentAt(row: Int, section: Int, tagText: String, commentFirst: Comments?, commentSecond: Comments?) {}
    
    func didTapOnUrl(url: URL) {}
}
