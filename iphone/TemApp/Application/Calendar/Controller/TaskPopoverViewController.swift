//
//  TaskPopoverViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 20/07/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
import MobileCoreServices

protocol TaskPopoverViewControllerDelegate: AnyObject {
    func passTaskModal(newtask: Tasks)
}
class TaskPopoverViewController: DIBaseController {
    // MARK: IBOutlet
    @IBOutlet weak var titleTextField: CustomTextField!
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var shadowView: SSNeumorphicView! {
        didSet {
            shadowView.viewDepthType = .innerShadow
            shadowView.viewNeumorphicMainColor = viewBackgroundColor.cgColor
            self.shadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
            self.shadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(1).cgColor
            shadowView.viewNeumorphicCornerRadius = 9
            shadowView.viewNeumorphicShadowRadius = 3
            shadowView.borderWidth = 0
        }
    }
    @IBOutlet weak var addTitleView: SSNeumorphicView! {
        didSet {
            setShadow(view: addTitleView, shadowType: .innerShadow)
        }
    }
    // MARK: Variables
    private let viewBackgroundColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.59)
    let currentMedia = Media()
    var mediaItems = [YPMediaItem]()
    var listOfFiles: [SavedURls] = []
    var documentData = Data()
    weak var delegate: TaskPopoverViewControllerDelegate?
    var selectedMediaType: EventMediaType?
    override func viewDidLoad() {
        super.viewDidLoad()
        mediaView.isHidden = true
    }
    // MARK: IBAction
    @IBAction func saveTaskTapped(_ sender: UIButton) {
        if titleTextField.text == "" {
            self.showAlert(withTitle: "", message: "Please enter title", okayTitle: AppMessages.AlertTitles.Ok)
        } else {
            self.uploadMedia { url in
                if let title = self.titleTextField.text {
                    self.delegate?.passTaskModal(newtask: Tasks(task_name: title, file: url, fileType: self.selectedMediaType?.rawValue ?? 0))
                    self.dismiss(animated: true)
                }
            }
        }
    }
    private func uploadMedia(_ completion: @escaping(_ url: String) -> Void) {
        self.showLoader()
        if let selectedMediaType = selectedMediaType {
            switch selectedMediaType {
            case .video:
                uploadMediaToFireBase {
                    self.hideLoader()
                    if self.listOfFiles.count > 0 {
                        completion(self.listOfFiles[0].url ?? "")
                    } else {
                        completion("")
                    }
                } failure: { error in
                    self.hideLoader()
                }
            case .pdf:
                uploadPdfToFireBase(data: documentData) {
                    self.hideLoader()
                    if self.listOfFiles.count > 0 {
                        completion(self.listOfFiles[0].url ?? "")
                    } else {
                        completion("")
                    }
                } failure: { error in
                    self.hideLoader()
                }
            }
        } else {
            self.hideLoader()
            completion("")
        }
    }
    @IBAction func crossTapped(_ sender: UIButton) {
        self.dismiss(animated: true )
    }
    @IBAction func addMediaTapped(_ sender: UIButton) {
        showSelectionModal(array: ["Video", "PDF"], type: .fileType)
    }
    // MARK: Helper functions
    func setShadow(view: SSNeumorphicView, shadowType: ShadowLayerType, isType: Bool = false) {
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor =  #colorLiteral(red: 0.2431066334, green: 0.2431549132, blue: 0.2431036532, alpha: 1)
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = 8
        view.viewNeumorphicShadowRadius = 3
    }
    override func handleSelection(index: Int, type: SheetDataType) {
        if type == .fileType {
            if index == 0 { // video
                self.showYPPhotoGallery(showCrop: false, isFromFoodTrek: false, showOnlyVideo: true)
            } else if index == 1 { // pdf
                getPDf()
            }
        }
    }
    override func handleAfterMediaSelection(withMedia items: [YPMediaItem], isPresentingFromCreatePost: Bool, isFromFoodTrek: Bool = false) {
        guard isConnectedToNetwork() else {
            return
        }
        self.picker?.dismiss(animated: true, completion: nil)
        mediaItems = items
        initializeNewPostWithYPMedia()
    }
    // pass the media items array picked from gallery
    func initializeNewPostWithYPMedia() {
        self.iterateMediaItems()
    }
    private func iterateMediaItems() {
        for mediaItem in self.mediaItems {
            switch mediaItem {
            case .photo:
                break
            case .video(let video):
                do {
                    currentMedia.data = try Data(contentsOf: video.url)
                    currentMedia.ext = MediaType.video.mediaExt
                    currentMedia.type = MediaType.video
                    currentMedia.image = video.thumbnail
                    currentMedia.mimeType = "video/mp4"
                    showMediaImages(mediaType: .video)
                } catch (let _) {
                }
            }
        }
    }
    func showMediaImages(mediaType: EventMediaType) {
        self.selectedMediaType = mediaType
        mediaView.isHidden = false
        switch mediaType {
        case .video:
            mediaImageView.image = UIImage(named: "videoWhite")
        case .pdf:
            mediaImageView.image = UIImage(named: "pdfWhite")
        }
    }
    func getPDf() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypePDF as String], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    private func mediaSizeValidated() -> Bool {
        if let data = currentMedia.data,
           data.count >= AWSBucketFileSizeLimit {
            return false
        }
        return true
    }
    func uploadMediaToFireBase(completion: @escaping() -> Void, failure: @escaping (DIError) -> Void) {
        showLoader()
        let media = currentMedia
        guard mediaSizeValidated() else {
            self.showAlert(message: "Some files are too large to share. Please, select other files.")
            return
        }
        guard let data = media.data else { return }
        let filepath = "UserID101" + "media" + Utility.shared.getFileNameWithDate()
        DispatchQueue.main.async {
            AWSBucketMangaer.bucketInstance.uploadFile(data: data, mediaObj: media, mimeType: media.mimeType ?? "", key: "file", fileName: filepath) { (_, firebaseUrl, error, _) in
                if let url = firebaseUrl {
                    self.hideLoader()
                    self.listOfFiles.append(contentsOf: [SavedURls(name: "Video", mediaType: EventMediaType.video.rawValue, url: url)])
                    completion()
                } else {
                    self.hideLoader()
                    failure(error)
                }
            }
        }
    }
    func uploadPdfToFireBase(data: Data, completion: @escaping() -> Void, failure: @escaping (DIError) -> Void) {
        showLoader()
        let media = Media()
        media.data =  data
        media.mimeType = "application/pdf"
        guard let data = media.data else { return }
        let filepath = "UserID101" + "media" + Utility.shared.getFileNameWithDate()
        DispatchQueue.main.async {
            AWSBucketMangaer.bucketInstance.uploadFile(data: data, mediaObj: media, mimeType: media.mimeType ?? "", key: "file", fileName: filepath) { (_, firebaseUrl, error, _) in
                if let url = firebaseUrl {
                    self.hideLoader()
                    self.listOfFiles.append(contentsOf: [SavedURls(name: "PDF", mediaType: EventMediaType.pdf.rawValue, url: url)])
                    completion()
                } else {
                    self.hideLoader()
                    failure(error)
                }
            }
        }
    }
}

extension TaskPopoverViewController: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        showMediaImages(mediaType: .pdf)
        do {
            for url in urls {
                documentData = try Data(contentsOf: url)
            }
        } catch {
        }
    }
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
}
