//
//  CreateEventDetailsController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 29/12/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Kingfisher
import IQKeyboardManagerSwift
import SwiftDate
import SSNeumorphicView
import UniformTypeIdentifiers
import MobileCoreServices
import Imaginary


struct CreateEventDetails{
    var endsOn: EndsOnValue?
    var id = ""
    var media: [SavedURls] = []
    var description = ""
    var location : Address = Address()
    var reccurEvent :RecurrenceType = .doesNotRepeat
    var eventReminder = true
    var isEditEvent = false
    var updatedFor = ""
    var updateAllEvents = 0
}

class CreateEventDetailsController: DIBaseController {
    
    // MARK: IBOutlets
    @IBOutlet var descriptionToggleImage: UIImageView!
    @IBOutlet var locationToggleImage: UIImageView!
    @IBOutlet var recurringToggleImage: UIImageView!
    @IBOutlet var recurrenceToggleImage: UIImageView!
    @IBOutlet var reminderToggleImage: UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var descriptionToggleShadowView: SSNeumorphicView!{
        didSet{
            descriptionToggleShadowView.setToggleShadow(view: descriptionToggleShadowView)
        }
    }
    @IBOutlet weak var locationToggleShadowView: SSNeumorphicView!{
        didSet{
            locationToggleShadowView.setToggleShadow(view: locationToggleShadowView)
        }
    }
    @IBOutlet weak var recurringToggleShadowView: SSNeumorphicView!{
        didSet{
            recurringToggleShadowView.setToggleShadow(view: recurringToggleShadowView)
        }
    }
    @IBOutlet weak var recurrenceToggleShadowView: SSNeumorphicView!{
        didSet{
            recurrenceToggleShadowView.setToggleShadow(view: recurrenceToggleShadowView)
        }
    }
    
    @IBOutlet weak var reminderToggleShadowView: SSNeumorphicView!{
        didSet{
            reminderToggleShadowView.setToggleShadow(view: reminderToggleShadowView)
        }
    }
    @IBOutlet weak var locationDetailsLabel: UILabel!
    @IBOutlet weak var recurrenceDetailsLabel: UILabel!
    @IBOutlet weak var recurenceFinishDEtailsLabel: UILabel!
    @IBOutlet weak var eventTypeDetailsLabel: UILabel!
    @IBOutlet weak var descriptionDetailsField: CustomTextField!
    @IBOutlet weak var descriptionDetailsFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var locationDetailsLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var recurrenceDetailsLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var eventTypeLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var recurrenceEndsLabelHeight: NSLayoutConstraint!
    @IBOutlet  var detailsShadowViews: [SSNeumorphicView]!{
        didSet{
            for view in detailsShadowViews{
                view.setShadow(view: view, shadowType: .innerShadow, mainColor: UIColor.newAppThemeColor.cgColor)
            }
        }
    }
    
    @IBOutlet  var BgShadowViews: [SSNeumorphicView]!{
        didSet{
            for view in BgShadowViews{
                view.setShadow(view: view, shadowType: .outerShadow, mainColor: UIColor.newAppThemeColor.cgColor)
            }
        }
    }
    @IBOutlet weak var toggleButtonShadowView: SSNeumorphicView!{
        didSet{
            toggleButtonShadowView.setShadow(view: toggleButtonShadowView, shadowType: .outerShadow, mainColor: UIColor.newAppThemeColor.cgColor)
            toggleButtonShadowView.viewNeumorphicShadowOpacity = 0.2
        }
    }
    @IBOutlet weak var locationField: CustomTextField!
    @IBOutlet weak var recurrenceField: CustomTextField!
    @IBOutlet weak var recurrenceFinishField: CustomTextField!
    @IBOutlet weak var chooseFileField: CustomTextField!
    @IBOutlet weak var descriptionField: CustomTextField!
    @IBOutlet weak var eventTypeField: CustomTextField!
    @IBOutlet weak var reminderToggle: UIButton!
    @IBOutlet var eventTypeToggleImage: UIImageView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var eventTypeToggleShadowView: SSNeumorphicView!{
        didSet{
            setToggleShadow(view: eventTypeToggleShadowView)
        }
    }
    
    // MARK: Properties

    var isEditEvent = false
    var eventID = ""
    var selectedGroup: ChatRoom?
    var eventDetail : EventDetail?
    var screenFrom: Constant.ScreenFrom?
    var section = 0
    let currentMedia = Media()
    var mediaItems = [YPMediaItem]()
    var listOfFiles: [SavedURls] = []
    var saveEventDetails : SaveEventDetails?
    var end: Date = Date().addMinutes(n: 90) {
        didSet {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
        }
    }
    var createdEventDetail:CreateEventDetails?
    private var location: Address = Address() {
        didSet {
            if let formatted = location.formatted{
                locationField.text = formatted
            }else{
                locationField.text = "    ADD LOCATION"
            }

        }
    }
    private var recurrence: RecurrenceType = .doesNotRepeat {
        didSet {
            recurrenceDetailsLabel.text = recurrence.getTitle()
            if isEditEvent{
                recurrenceDetailsLabelHeight.constant = 60
            }
            if recurrenceDetailsLabel.text?.isEmpty ?? true{
                recurringToggleImage.image = UIImage(named: "")
            }else{
                recurringToggleImage.image = UIImage(named: "Oval Copy 3")
            }
            
            if recurrence == .doesNotRepeat {
                recurrenceFinishType = nil
                recurrenceFinishField.isUserInteractionEnabled = false
            } else {
                recurrenceFinishField.isUserInteractionEnabled = true
                recurrenceFinishType = .never
                recurrenceEndsLabelHeight.constant = 60
                self.recurrenceFinishField.isSelected = false
            }
            
        }
    }
    private var recurrenceFinishType: RecurrenceFinishType? {
        didSet {
            
            if let recurrenceFinishType = recurrenceFinishType {
                if recurrenceFinishType == .never {
                    recurrenceFinishDate = nil
                } else if recurrenceFinishDate == nil {
//                    recurrenceFinishDate = Date().addDay(n: 30)
                }
            } else {
                recurrenceFinishDate = nil
            }
        }
    }
    private var recurrenceFinishDate: Date? {
        didSet {
            if let recurranceFinishType = recurrenceFinishType {
                if recurranceFinishType == .never {
                    recurenceFinishDEtailsLabel.text = recurranceFinishType.getTitle()
                } else if let recurranceFinishDate = recurrenceFinishDate {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    recurenceFinishDEtailsLabel.text = dateFormatter.string(from: recurranceFinishDate)
                    if recurenceFinishDEtailsLabel.text?.isEmpty ?? true{
                        recurrenceToggleImage.image = UIImage(named: "")
                    }else{
                        recurrenceToggleImage.image = UIImage(named: "Oval Copy 3")
                    }
                }
            } else {
                recurenceFinishDEtailsLabel.text = nil                }
        }
    }
    var desc: String? {
        didSet {
            descriptionDetailsField.text = desc
            if descriptionDetailsField.text?.isEmpty ?? true{
                descriptionToggleImage.image = UIImage(named: "")
            }else{
                descriptionToggleImage.image = UIImage(named: "Oval Copy 3")
            }
        }
    }
    private var eventType: EventType = .regular {
        didSet {
            eventTypeDetailsLabel.text = eventType.getTitle()
            eventTypeLabelHeight.constant = 60
            if eventTypeDetailsLabel.text?.isEmpty ?? true{
                eventTypeToggleImage.image = UIImage(named: "")
            }else{
                eventTypeToggleImage.image = UIImage(named: "Oval Copy 3")
            }
            
        }
    }
    
    private var reminder: Bool = false {
        didSet {
            reminderToggle.isSelected = reminder
            if reminderToggle.isSelected{
                reminderToggleImage.image = UIImage(named: "Oval Copy 3")
            }else{
                reminderToggleImage.image = UIImage(named: "")
            }
        }
    }
    
    // MARK: App life Cycle....
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.endEditing(true)
        if isEditEvent{
            submitButton.setTitle("UPDATE", for: .normal)
        }else{
            submitButton.setTitle("SAVE", for: .normal)
        }
        self.navigationController?.navigationBar.isHidden = true
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.previousNextDisplayMode = .default
    }
    
    // MARK: IBAction
    
    @IBAction func descriptionTapped(_ sender: UIButton) {
        // descriptionDetailsFieldHeight.constant = 50
    }
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        let savedDetails = getEventParams()
        saveEventDetails?.saveEventDetails(data: savedDetails, isEventEdited: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func remindMeTapped(_ sender: UIButton) {
        reminder.toggle()
    }
    // MARK: Methods
    private func configureViewForEditEvent() {
        if let event = self.eventDetail {
            desc = event.description
            recurrence = RecurrenceType(rawValue: event.reccurEvent ?? 0) ?? .doesNotRepeat
            reminder = event.eventReminder ?? false
            setUpLocation(event)
            setUpDatesForEditEvent(event)
            setupRecurranceFinish(event.endsOn)
            eventType = event.eventType ?? .regular
            eventTypeField.setUserInteraction(shouldEnable: false)
            if let media = event.media{
                collectionViewHeight.constant = 100
                listOfFiles = media
                self.mediaCollectionView.reloadData()
            }
            
        }
    }
    
    private func initUI() {
        guard let eventDetail = self.createdEventDetail else {
        // recurrence = .doesNotRepeat
            eventType = .regular
       //     recurrenceDetailsLabelHeight.constant = 0
            return
            
        }
        self.eventID = eventDetail.id
        self.descriptionDetailsField.text = eventDetail.description
        self.location = eventDetail.location
        self.recurrence = eventDetail.reccurEvent
        self.reminder = eventDetail.eventReminder
        self.isEditEvent = eventDetail.isEditEvent
        setupRecurranceFinish(eventDetail.endsOn)
        if eventDetail.media.count > 0 {
            collectionViewHeight.constant = 100
            listOfFiles = eventDetail.media
            self.mediaCollectionView.reloadData()
        }
        recurrenceDetailsLabelHeight.constant = 60
    }
    
    func setToggleShadow(view:SSNeumorphicView){
        view.viewDepthType = .innerShadow
        view.viewNeumorphicMainColor = UIColor.newAppThemeColor.cgColor
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = view.frame.height / 2
    }
    func initialize(){
        setDelegates()
        DispatchQueue.main.async {
            self.configureView()
        }
        collectionViewHeight.constant = 0
        mediaCollectionView.registerNibsForCollectionView(nibNames: [MediaCollectionViewCell.reuseIdentifier])
    }
    
    
    func configureView(){
        if isEditEvent {
            configureViewForEditEvent()
            self.initUI()
        } else {
            self.initUI()
        }
    }
    
    func setDelegates(){
        descriptionDetailsField.delegate = self
        locationField.delegate = self
        recurrenceField.delegate = self
        recurrenceFinishField.delegate = self
        descriptionField.delegate = self
        eventTypeField.delegate = self
        chooseFileField.delegate = self
        
    }
    
    private func setUpDatesForEditEvent(_ eventDetail:EventDetail) {
        let utcFormatter = timeZoneDateFormatter(format: .utcDate, timeZone: utcTimezone)
        let eventEndDate = utcFormatter.date(from: eventDetail.endDate?.date as? String ?? "")
        //    end = eventEndDate ?? Date().addMinutes(n: 90)
    }
    //This method is used to setup location field while editing a event.
    private func setUpLocation(_ eventDetail:EventDetail) {
        if let location = eventDetail.location {
            let address = Address()
            address.lat = location.lat
            address.lng = location.long
            address.formatted = location.location
            self.location = address
        }
    }
    
    private func setupRecurranceFinish(_ endsOn: EndsOnValue?) {
        if let eventValue = endsOn?.any as? Int, eventValue == RecurrenceFinishType.never.rawValue {
            recurrenceFinishType = .never
        }
        if let endOnDate = endsOn?.any as? String {
            self.recurrenceFinishType = .date
            recurrenceFinishDate = endOnDate.toISODate()!.date
        }
    }
    
    func getEventDateTime(_ date: Date) -> String {
        let dateString = timeZoneDateFormatter(format: .utcDate, timeZone: utcTimezone).string(from: date)
        return dateString
    }
    
    private func redirectOnLocationViewController(isFromGym:Bool? = false) {
        let locationVC:LocationViewController = UIStoryboard(storyboard: .main).initVC()
        locationVC.isFromGym = isFromGym!
        locationVC.delegate = self
        self.navigationController?.pushViewController(locationVC, animated: true)
    }
    
    override func handleSelection(index: Int, type: SheetDataType) {
        if type == .editEvent {
           if let editMode = EditRecurringEventMode(rawValue: index) {
        //   self.editMode = editMode
                ///self.updateEvent(editMode: editMode)
          }
        } else if type == .recurrence {
            recurrence = RecurrenceType.allCases[index]
            recurrenceField.changeViewFor(selectedState: false)
            
            recurrenceDetailsLabelHeight.constant = 60
        } else if type == .recurrenceFinish {
            recurrenceFinishType = RecurrenceFinishType.allCases[index]
            if recurrenceFinishType == .date {
                recurrenceFinishField.becomeFirstResponder()
            }
            recurrenceEndsLabelHeight.constant = 60
        } else if type == .eventType {
            eventTypeField.changeViewFor(selectedState: false)
            eventType = EventType.supported[index]
        } else if type == .fileType{
            if index == 0{ // video
                self.showYPPhotoGallery(showCrop: false, isFromFoodTrek: false, showOnlyVideo: true)
            } else if index == 1{ // pdf
                getPDf()
            }
        }
        
    }
    override func handleAfterMediaSelection(withMedia items: [YPMediaItem], isPresentingFromCreatePost: Bool, isFromFoodTrek:Bool = false) {
        guard isConnectedToNetwork() else {
            return
        }
        self.picker?.dismiss(animated: true, completion: nil)
        mediaItems = items
        initializeNewPostWithYPMedia()
        
    }
    //pass the media items array picked from gallery
    func initializeNewPostWithYPMedia() {
        self.iterateMediaItems()
    }
    
    private func iterateMediaItems() {
        for mediaItem in self.mediaItems {
            
            switch mediaItem {
                case .photo(let photo):
                    break
                case .video(let video):
                    do {
                        currentMedia.data = try Data(contentsOf: video.url)
                        currentMedia.ext = MediaType.video.mediaExt
                        currentMedia.type = MediaType.video
                        currentMedia.image = video.thumbnail
                        currentMedia.mimeType = "video/mp4"
                        uploadMediaToFireBase() { (error) in
                            // do nothing ?
                        }
                        
                    } catch (let error) {
                        print(error.localizedDescription)
                        
                    }
            }
        }
    }
    
    func getPDf(){
        
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypePDF as String], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        //       documentPicker.modalPresentationStyle = .fullScreen
        present(documentPicker, animated: true, completion: nil)
        
    }
    
    private func mediaSizeValidated() -> Bool {
        if let data = currentMedia.data,
           data.count >= AWSBucketFileSizeLimit {
            return false
        }
        return true
    }
    
    func uploadMediaToFireBase(failure: @escaping (DIError) -> ()) {
        showLoader()
        let media = currentMedia
        
        guard mediaSizeValidated() else {
            self.showAlert(message: "Some files are too large to share. Please, select other files.")
            return
        }
        
        guard let data = media.data else { return }
        
        let filepath = "UserID101" + "media" + Utility.shared.getFileNameWithDate()
        // DILog.print(items:"media is \(media.type)")
        DispatchQueue.main.async {
            AWSBucketMangaer.bucketInstance.uploadFile(data: data, mediaObj: media, mimeType: media.mimeType ?? "", key: "file", fileName: filepath) { (callback, firebaseUrl, error, mediaObjFromFirebase) in
                if let url = firebaseUrl {
                    self.hideLoader()
                    self.collectionViewHeight.constant = 100
                    self.listOfFiles.append(contentsOf: [SavedURls(name: "Video", mediaType: EventMediaType.video.rawValue, url: url)])
                    self.mediaCollectionView.reloadData()
                }
                else {
                    self.hideLoader()
                    DILog.print(items: "Error Occured \(error)")
                    failure(error)
                }
            }
        }
    }
    func uploadPdfToFireBase(data: Data, failure: @escaping (DIError) -> ()) {
        showLoader()
        
        let media = Media()
        media.data =  data
        media.mimeType = "application/pdf"
        
        guard let data = media.data else { return }
        
        let filepath = "UserID101" + "media" + Utility.shared.getFileNameWithDate()
        DispatchQueue.main.async {
            AWSBucketMangaer.bucketInstance.uploadFile(data: data, mediaObj: media, mimeType: media.mimeType ?? "", key: "file", fileName: filepath) { (callback, firebaseUrl, error, mediaObjFromFirebase) in
                if let url = firebaseUrl {
                    self.hideLoader()
                    self.collectionViewHeight.constant = 100
                    
                    self.listOfFiles.append(contentsOf: [SavedURls(name: "PDF", mediaType: EventMediaType.pdf.rawValue, url: url)])
                    self.mediaCollectionView.reloadData()
                    
                }
                else {
                    self.hideLoader()
                    DILog.print(items: "Error Occured \(error)")
                    failure(error)
                }
            }
        }
    }
    //on dismissing the activity sheet, reset the border color of the textfield to default gray
    override func cancelSelection(type: SheetDataType) {
        if type == .recurrence {
            recurrenceField.changeViewFor(selectedState: false)
        } else if type == .recurrenceFinish {
            recurrenceFinishField.changeViewFor(selectedState: false)
        } else if type == .eventType {
            eventTypeField.changeViewFor(selectedState: false)
        }
    }
    
    private func redirectToLocationSelection() {
        self.view.endEditing(true)
        redirectOnLocationViewController()
    }
    
    func editSuccessEvent() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.NotiName.editEvent), object: nil, userInfo: [Constant.NotiName.editEvent:eventDetail])
    }
    
    func getEventParams(editMode: EditRecurringEventMode = .thisEvent) -> CreateEventDetails {
        var event = CreateEventDetails()
        if let selectedEndsOnType = self.recurrenceFinishType {
            switch selectedEndsOnType {
            case .never:
                event.endsOn = EndsOnValue.int(RecurrenceFinishType.never.rawValue)
            case .date:
                event.endsOn = EndsOnValue.string(timeZoneDateFormatter(format: isEditEvent ? .eventUtcDateString : .eventUtcDate, timeZone: utcTimezone).string(from: recurrenceFinishDate ?? Date()))
            }
        } else {
            event.endsOn = EndsOnValue.string(getEventDateTime(end))
        }
        event.id = self.eventID
        event.media = listOfFiles
        event.description = descriptionDetailsField.text ?? ""
        event.location = location
        event.reccurEvent = recurrence
        event.eventReminder = reminder
        event.isEditEvent = self.isEditEvent
        event.updatedFor = timeZoneDateFormatter(format: .eventUtcDateString, timeZone: utcTimezone).string(from: self.eventDetail?.eventStartDate ?? Date())
        event.updateAllEvents = editMode.rawValue
        return event
    }
}

// MARK: Extension + TextField Delegate Methods

extension CreateEventDetailsController : UITextFieldDelegate {
    
     func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == recurrenceFinishField{
            return false
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let textField = textField as? CustomTextField {
            textField.changeViewFor(selectedState: true)
        }
        switch textField {
        case locationField:
            redirectToLocationSelection()
            return false
        case recurrenceField:
                    showSelectionModal(array: RecurrenceType.allCases, type: .recurrence)
            return false
        case recurrenceFinishField:
            if recurrenceFinishType == .never {
                showSelectionModal(array: RecurrenceFinishType.allCases, type: .recurrenceFinish)
                return false
            }
            return true
        case eventTypeField:
            showSelectionModal(array: EventType.supported, type: .eventType)
            return false
        case chooseFileField :
            showSelectionModal(array: ["Video", "PDF"], type: .fileType)
            return false
            
        default:
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let field = textField as? CustomTextField {
            field.errorMessage = ""
        }
        switch textField {
            case recurrenceFinishField:
                showDatePicker(textfield: recurrenceFinishField, action: #selector(recurrenceFinishDateChanged), mode: .date,
                               selectedDate: recurrenceFinishDate ?? end, minDate: end, maxDate: Constant.Calendar.endDate)
            default:
                break
        }
    }
    
    private func showDatePicker(textfield: UITextField, action: Selector, mode: UIDatePicker.Mode, selectedDate: Date, minDate: Date, maxDate: Date) {
        datePickerView = UIDatePicker()
        if #available(iOS 13.4, *) {
            datePickerView?.preferredDatePickerStyle = UIDatePickerStyle.wheels
        }
        datePickerView!.datePickerMode = mode
        datePickerView?.setDate(selectedDate, animated: true)
        datePickerView?.minimumDate = minDate
        datePickerView?.maximumDate = maxDate
        textfield.inputView = datePickerView
        if recurrenceFinishDate == nil {
            recurrenceFinishDate = end
        }
        datePickerView?.addTarget(self, action: action, for: .valueChanged)
    }
    @objc private func recurrenceFinishDateChanged(_ sender: UIDatePicker) {
        recurrenceFinishDate = sender.date
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == descriptionDetailsField, let text = textField.text {
            desc = text
        }
        if let textField = textField as? CustomTextField {
            textField.changeViewFor(selectedState: false)
        }
    }
}

// MARK: Picker Delegate Methods...

extension CreateEventDetailsController: AddressDelegate {
    //For Adderess....
    func selectedAddress(address: Address, isGymLocation: Bool) {
        location = address
        locationField.changeViewFor(selectedState: false)
    }
}



extension CreateEventDetailsController: UIDocumentPickerDelegate {
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        do {
            var documentData = Data()
            for url in urls {
                documentData = try Data(contentsOf: url)
            }
            uploadPdfToFireBase(data: documentData, failure: { error in
                print(error.message)
            })
        } catch {
            print("no pdf found")
        }
        
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
}

// MARK: UICollectionViewDataSource, UICollectionViewDelegate
extension CreateEventDetailsController: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listOfFiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: MediaCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaCollectionViewCell.reuseIdentifier, for: indexPath) as? MediaCollectionViewCell else{
            return UICollectionViewCell()
        }
        cell.setData(data: listOfFiles[indexPath.item])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let mediaType = listOfFiles[indexPath.item].mediaType{
            switch EventMediaType(rawValue: mediaType){
                case .video:
                    let episodeVideoVC: EpisodeVideoViewController = UIStoryboard(storyboard: .temTv).initVC()
                    episodeVideoVC.url = listOfFiles[indexPath.item].url ?? ""
                    self.navigationController?.pushViewController(episodeVideoVC, animated: false)
                case .pdf:
                    let selectedVC:AffilativePDFView = UIStoryboard(storyboard: .affilativeContentBranch).initVC()
                    selectedVC.urlString = listOfFiles[indexPath.item].url ?? ""
                    
                    self.navigationController?.pushViewController(selectedVC, animated: true)
                default:
                    break
            }
        }
        
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout
extension CreateEventDetailsController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width: 100, height: 100)
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}



