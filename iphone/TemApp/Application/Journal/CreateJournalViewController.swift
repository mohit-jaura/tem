//
//  CreateJournalViewController.swift
//  TemApp
//
//  Created by Mohit Soni on 31/01/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
import Kingfisher
struct ImgLoc {
    let image: UIImage
    let location: NSRange
}
class CreateJournalViewController: DIBaseController {
    //MERGE Activity and wellness journal
    // MARK: IBOutlets
    @IBOutlet weak var dateLabel:UILabel!
    var str = ""
    var recentlyUploadedImage = ""
    var imgLocArr = [ImgLoc]()
    var imgLoc:ImgLoc?
    var imageURLResultsFromStr:[NSTextCheckingResult] = []
    @IBOutlet weak var imageButOut: UIButton!
    @IBOutlet weak var wellnessJournalMainShadowView: UIView!
    @IBOutlet weak var wellnessOuterView: UIView!
    @IBOutlet weak var descriptionTextView:UITextView!
    @IBOutlet weak var badActivityButton: UIButton!
    @IBOutlet weak var poorActivityButton: UIButton!
    @IBOutlet weak var averageActivityButton: UIButton!
    @IBOutlet weak var goodActivityButton: UIButton!
    @IBOutlet weak var greatActivityButton: UIButton!
    @IBOutlet weak var saveButton:UIButton!
    @IBOutlet weak var historyButton:UIButton!
    var tempTextView = UITextView()
    // MARK: Properties
    let neumorphicShadow = NumorphicShadow()
    var selectedRateActivityNumber:Int?
    var todayTimeStamp:Int?
    var todayQuote:String?
    var journalList:JournalList?
    var ratingButtons:[UIButton] = [UIButton]()
    var isEditAble:Bool = false
    var isForDetail:Bool = false
    var fromeDashboard:Bool = false
    var photoManager:PhotoManager?
    
    final let textViewPlaceholderText:String = "Text…talk about your food, mood, workout, or anything!"
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
    }
    
    func convertToAttachment() {
        if imageURLResultsFromStr.count > 0 {
            imageTOAttributedText(imageURLResultsFromStr.first?.url, imageURLResultsFromStr.first?.range)
        } else{
            self.hideLoader()
            descriptionTextView.isHidden = false
        }
    }
    
    // MARK: IBActions
    
    @IBAction func backBtnTapped(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func rateActivityButtonsTapped(_ sender: UIButton) {
        self.configureRateActivityLayouts(selectedButton: sender)
    }
    
    @IBAction func saveBtnTapped(_ sender:UIButton) {
        /// This helps to avoid gliches while images are converting to urls
        tempTextView = descriptionTextView.copyView()
        tempTextView.attributedText = descriptionTextView.attributedText
        getImageFromAttributedText()
    }
    func saveAction() {
        if isEditAble {
            self.callUpdateJournalAPI()
        } else {
            self.callCreateJournalAPI()
        }
    }
    // MARK: This helps to get an image attachment and convert it to url and add to exisiting string
    func getImageFromAttributedText() {
        
        tempTextView.attributedText.enumerateAttribute(NSAttributedString.Key.attachment, in: NSRange(location: 0, length: tempTextView.attributedText.length), options: []) { (value, range, stop) in
            if (value is NSTextAttachment){
                let attachment: NSTextAttachment? = (value as? NSTextAttachment)
                
                if let image = attachment?.image {
                    print("\(self.imgLocArr.count ) image attached")
                    self.imgLocArr.append(ImgLoc(image: image, location: range))
                    // We need to stop enumeration to re-calculate location for next image
                    stop.initialize(to: true)
                } else {
                    print("No image attched")
                }
            }
        }
        imgArrUpload()
    }
    /// This is recurisive function call untill all images being converted to url and add to existing string
    func imgArrUpload() {
        showLoader()
        print("count \(self.imgLocArr.count)")
        if imgLocArr.count > 0 {
            getImgUrlFromImg(imgLocArr.first?.image,imgLocArr.first?.location)
        } else {
            saveAction()
        }
    }
    // This function used to upload image to server
    func getImgUrlFromImg(_ img:UIImage?,_ range:NSRange?) {
        guard let img = img, let range = range else { return }
        self.uploadImg(img, completion: {[weak self] imageUrl in
            guard let self = self, let imageUrl = imageUrl else { return }
            print("\(imageUrl)")
            /// This below lines replace server image url with image attachment
            let mutableAttr = self.tempTextView.attributedText.mutableCopy() as! NSMutableAttributedString
            mutableAttr.replaceCharacters(in: range, with:"\n\(imageUrl)\n")
            
            self.tempTextView.attributedText = mutableAttr
            /// Removing first element from array helps to add only one image to url at a time
            self.imgLocArr.remove(at: 0)
            /// Recursive call to upload image
            self.getImageFromAttributedText()
        })
    }
    // MARK: Directly insert image as attachment Not as URL
    func insertImage(_ image:UIImage) {
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.setImageHeight(height: 200)
        let attString = NSAttributedString(attachment: attachment)
        /// at is current cursor position
        self.descriptionTextView.textStorage.insert(attString, at: self.descriptionTextView.selectedRange.location)
        descriptionTextView.font = UIFont(name: UIFont.avenirNextRegular, size: 17)
        descriptionTextView.textColor = .white
    }
    
    // MARK: Server URL to Image conversion to show
    func imageTOAttributedText(_ url:URL?,_ range:NSRange?) {
        guard let url = url, let range = range else { return }
        let imgView = UIImageView()
        
        imgView.kf.setImage(with: url, completionHandler: { result in
            switch result {
                case .success(var data):
                    let attachment = NSTextAttachment()
                    attachment.image = data.image
                    // attachment.fileType = self.recentlyUploadedImage
                    attachment.setImageHeight(height: 200)
                    
                    /// This will help to remove existing url from server which we have sent as url
                    /// Start
                    let mutStr = self.descriptionTextView.attributedText.mutableCopy() as! NSMutableAttributedString
                    mutStr.deleteCharacters(in: range)
                    self.descriptionTextView.attributedText = mutStr
                    /// Add image as attachment downloaded from url
                    let attString = NSAttributedString(attachment: attachment)
                    self.descriptionTextView.textStorage.insert(attString, at: range.location)
                    /// Recursivly calls to check how many urls we have in string to avoid wrong location insertion
                    /// We need to re-calculate new string from server after removing url string and add image as attachment
                    self.imageURLResultsFromStr.remove(at: 0)
                    self.imageURLResultsFromStr =  self.checkForUrls(text: self.descriptionTextView.text)
                    self.convertToAttachment()
                case .failure(let error):
                    self.hideLoader()
                    print(error)
            }
        })
    }
    
    @IBAction func imageAction(_ sender: Any) {
        view.endEditing(true)
        insertImageFromPhotoManager()
    }
    /// Checks URLS from exisiting string so that we can download an image and show as attachment
    func checkForUrls(text: String) -> [NSTextCheckingResult] {
        let types: NSTextCheckingResult.CheckingType = .link
        
        do {
            let detector = try NSDataDetector(types: types.rawValue)
            
            let matches = detector.matches(in: text, options: .reportCompletion, range: NSRange(location: 0, length: text.count))
            return matches
            //   return matches.compactMap({$0.url})
        } catch let error {
            debugPrint(error.localizedDescription)
        }
        
        return []
    }
    private func insertImageFromPhotoManager() {
        photoManager = PhotoManager(navigationController: self.navigationController!, allowEditing: true, callback: { [weak self] (pickedimage) in
            guard let pickedimage = pickedimage else {return}
            guard let self = self else { return }
            self.insertImage(pickedimage)
        })
    }
    @IBAction func historyBtnTapped(_ sender: UIButton) {
        let journalHistoryVC:JournalListingViewController = UIStoryboard(storyboard: .journal).initVC()
        self.navigationController?.pushViewController(journalHistoryVC, animated: true)
    }
    
    // MARK: Methods
    private func initUI() {
        ratingButtons = [goodActivityButton,poorActivityButton,averageActivityButton,greatActivityButton,badActivityButton]
        addTitleLabel()
        //        self.addGradient()
        self.descriptionTextView.text = self.textViewPlaceholderText
        descriptionTextView.textColor = UIColor.lightGray
        descriptionTextView.delegate = self
        self.descriptionTextView.isEditable = true
        self.dateLabel.text = getupperCasedDate(date: Date())
        if let journalData = journalList{
            isEditAble = checkLastDateOfJournalUpdation(journalData: journalData)
            if isEditAble {
                self.descriptionTextView.isHidden = true
                self.showLoader()
                self.configureViewForJournalUpdation(journalData: journalData)
            } else if isForDetail {
                self.configureViewForJournalDetails(journalData: journalData)
            }
        }
    }
    
    func addGradient(){
        let gradient = getGradientLayer(bounds: descriptionTextView.bounds)
    }
    
    func getGradientLayer(bounds : CGRect) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = [UIColor(red: 0.97, green: 0.71, blue: 0.00, alpha: 1.00).cgColor,UIColor(red: 0.71, green: 0.13, blue: 0.88, alpha: 1.00).cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        return gradient
    }
    
    func configureRateActivityLayouts(selectedButton: UIButton) {
        selectedButton.setImage(UIImage(named: "selectActivity"), for: .normal)
        selectedRateActivityNumber = selectedButton.tag
        for button in ratingButtons{
            if button.tag != selectedButton.tag{
                button.setImage(UIImage(named: "Rate Your wellness unselect"), for: .normal)
            }
        }
    }
    private func addTitleLabel(){
        let myLabel = UILabel()
        let labelTitle = "DAILY WELLNESS JOURNAL"
        myLabel.text = "    " + labelTitle + "     "
        let font = UIFont(name: UIFont.avenirNextMedium, size: 14)
        let heightOfString = labelTitle.heightOfString(usingFont: font!)
        let x_cord = wellnessOuterView.frame.origin.x
        let y_cord = (wellnessOuterView.frame.origin.y - 44.3)
        
        let widthofString = labelTitle.widthOfString(usingFont: font!)
        var widthOfLabel:CGFloat = widthofString - 20
        if widthofString > wellnessOuterView.frame.width {
            widthOfLabel = widthofString
        }
        myLabel.frame = CGRect(x: x_cord, y: y_cord, width: widthOfLabel, height: heightOfString)
        myLabel.backgroundColor = .black
        myLabel.textColor = #colorLiteral(red: 0.01568627451, green: 0.9137254902, blue: 0.8901960784, alpha: 1)
        myLabel.font = font
        myLabel.textAlignment = .left
        myLabel.sizeToFit()
        wellnessOuterView.addSubview(myLabel)
        wellnessOuterView.clipsToBounds = false
    }
    
    private func validateRatingForm() -> Bool{
        if descriptionTextView.text.count == 0 || descriptionTextView.text == self.textViewPlaceholderText{
            self.showAlert(withTitle: "Rate your day", message: "Please enter your daily thought", okayTitle: "Ok", cancelTitle: nil, okStyle: .cancel) {} cancelCall: {}
            return false
        }
        else {
            todayTimeStamp = self.generateCurrentDayTimeStamp()
            todayQuote = self.tempTextView.text
            return true
        }
    }
    
    private func generateCurrentDayTimeStamp() -> Int {
        let date = Date()
        return date.timeStamp
    }
    
    private func generateParametersForApi() -> [String:Any] {
        var paramerter:[String:Any] = [:]
        paramerter["date"] = todayTimeStamp
        paramerter["rating"] = selectedRateActivityNumber
        paramerter["quote"] = todayQuote
        return paramerter
    }
    
    private func isConnectedToNetwork() -> Bool {
        if !Reachability.isConnectedToNetwork() {
            AlertBar.show(.error, message: AppMessages.AlertTitles.noInternet, duration: 2.0) {
                print("alert displayed")
            }
            return false
        }
        return true
    }
    
    private func callCreateJournalAPI() {
        let isNetworkAvailable = self.isConnectedToNetwork()
        if isNetworkAvailable{
            let isFormValidate = self.validateRatingForm()
            if isFormValidate{
                let params = self.generateParametersForApi()
                DIWebLayerJournalAPI().createJournal(parameters: params) { success in
                    self.hideLoader()
                    self.showAlert( message: "Journal created successfully !", okayTitle: "Ok", okCall: {
                        self.navigationController?.popViewController(animated: true)
                    })
                } failure: { error in
                    self.hideLoader()
                    if let message = error.message {
                        self.showAlert(message: message)
                    }
                }
            } else {
                self.hideLoader()
                return
            }
        }
    }
    
    private func callUpdateJournalAPI() {
        let isNetworkAvailable = self.isConnectedToNetwork()
        if isNetworkAvailable{
            let isFormValidate = self.validateRatingForm()
            if isFormValidate{
                var params = self.generateParametersForApi()
                params["_id"] = self.journalList?.id
                DIWebLayerJournalAPI().updateJournal(parameters: params) { success in
                    self.hideLoader()
                    self.showAlert( message: "Journal updated successfully !", okayTitle: "Ok", okCall: {
                        self.navigationController?.popViewController(animated: true)
                    })
                } failure: { error in
                    self.hideLoader()
                    if let message = error.message {
                        self.showAlert(message: message)
                    }
                }
            } else {
                self.hideLoader()
                return
            }
        }
    }
    
    private func configureViewForJournalDetails(journalData:JournalList) {
        let timeStamp = journalData.date
        let date = timeStamp.toDate
        self.dateLabel.text = getupperCasedDate(date: date)
        self.selectedRateActivityNumber = journalData.rating
        self.descriptionTextView.text = journalData.quote
        descriptionTextView.textColor = UIColor.white
        self.saveButton.isHidden = true
        self.descriptionTextView.isEditable = false
        self.descriptionTextView.isUserInteractionEnabled = false
        self.imageButOut.isUserInteractionEnabled = false
        for button in ratingButtons{
            if button.tag == selectedRateActivityNumber{
                button.setImage(UIImage(named: "selectActivity"), for: .normal)
            }
            button.isUserInteractionEnabled = false
        }
    }
    
    private func checkLastDateOfJournalUpdation(journalData:JournalList) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let timeStamp = journalData.date
        var journaldate = timeStamp.toDate
        let journalDateString = dateFormatter.string(from: journaldate)
        journaldate = dateFormatter.date(from: journalDateString) ?? Date()
        var todayDate = Date()
        let todayDateString = dateFormatter.string(from: todayDate)
        todayDate = dateFormatter.date(from: todayDateString) ?? Date()
        if journaldate == todayDate{
            return true
        }else{
            return false
        }
    }
    
    private func configureViewForJournalUpdation(journalData:JournalList) {
        let timeStamp = journalData.date
        let date = timeStamp.toDate
        self.dateLabel.text = getupperCasedDate(date: date)
        self.selectedRateActivityNumber = journalData.rating
        self.descriptionTextView.text = journalData.quote
        descriptionTextView.textColor = UIColor.white
        self.saveButton.isHidden = false
        self.descriptionTextView.isEditable = true
        for button in ratingButtons{
            if button.tag == selectedRateActivityNumber{
                button.setImage(UIImage(named: "selectActivity"), for: .normal)
            }
            button.isUserInteractionEnabled = true
        }
        self.imageURLResultsFromStr =  self.checkForUrls(text: self.descriptionTextView.text)
        convertToAttachment()
    }
    
    private func getupperCasedDate(date:Date) -> String{
        let dateString = date.toString(inFormat: .coachingTools) ?? ""
        let upperCasedDate = dateString.uppercased()
        return upperCasedDate
    }
}

// MARK: Extensions
extension CreateJournalViewController: UITextViewDelegate{
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descriptionTextView.textColor == UIColor.lightGray || descriptionTextView.text == textViewPlaceholderText {
            descriptionTextView.text = ""
            descriptionTextView.textColor = UIColor.white
        } else {
            descriptionTextView.textColor = UIColor.white
            descriptionTextView.font = UIFont(name: UIFont.avenirNextMedium, size: 16)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if descriptionTextView.text.hasPrefix(" ") || descriptionTextView.text.count == 0 {
            descriptionTextView.text = textViewPlaceholderText
            descriptionTextView.textColor = UIColor.lightGray
        }
    }
}
