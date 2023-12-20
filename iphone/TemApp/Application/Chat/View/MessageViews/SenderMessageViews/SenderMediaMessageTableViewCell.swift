//
//  ChatMediaMessagesTableCell.swift
//  TemApp
//
//  Created by Harpreet_kaur on 26/08/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import PDFKit
import SSNeumorphicView

protocol ChatMediaMessagesTableCellDelegate: AnyObject {
    func playVideo(indexPath:IndexPath)
    func openFullImageAt(indexPath: IndexPath)
    func openPdf(indexPath: IndexPath)
}

class SenderMediaMessageTableViewCell: UITableViewCell {
    
    // MARK: Variables.
    weak var delegate:ChatMediaMessagesTableCellDelegate?
    var message: Message?
    
    // MARK: IBOutlets.
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var pdfIconImageView: UIImageView!
    @IBOutlet weak var videoPlayButton: CustomButton!
    @IBOutlet weak var imageFullPreviewButton: CustomButton!
    @IBOutlet weak var openPdfButton: CustomButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var imagWidthConstraint: NSLayoutConstraint!
    @IBOutlet var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet var imageTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var backShadowView:  SSNeumorphicView! {
        didSet{
            backShadowView.viewDepthType = .outerShadow
            backShadowView.viewNeumorphicMainColor = UIColor(red: 227 / 255.0, green: 227 / 255.0, blue: 227 / 255.0, alpha: 1).cgColor
            backShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
            backShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.6).cgColor
            backShadowView.viewNeumorphicShadowOpacity = 0.5
            backShadowView.viewNeumorphicCornerRadius = 8
        }
    }
    @IBOutlet weak var userNameLabel:UILabel!
    
    // MARK: IBActions
    @IBAction func imageFullPreviewButtonTapped(_ sender: CustomButton) {
        let indexPath = IndexPath(row: sender.row, section: sender.section)
        self.delegate?.openFullImageAt(indexPath: indexPath)
    }
    @IBAction func videoPlayButtonTapped(_ sender: CustomButton) {
        let indexPath = IndexPath(row: sender.row, section: sender.section)
        self.delegate?.playVideo(indexPath: indexPath)
    }
    
    @IBAction func openPdfButtonTapped(_ sender: CustomButton) {
        let indexPath = IndexPath(row: sender.row, section: sender.section)
        self.delegate?.openPdf(indexPath: indexPath)
    }
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imagWidthConstraint.isActive = false
        self.imageHeightConstraint.isActive = false
    }
    
    /*override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
        self.addDropShadow()
    } */
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initializeWith(message: Message, indexPath: IndexPath) {
        self.message = message
        self.videoPlayButton.section = indexPath.section
        self.imageFullPreviewButton.section = indexPath.section
        self.openPdfButton.section = indexPath.section
        self.openPdfButton.row = indexPath.row
        self.videoPlayButton.row = indexPath.row
        self.imageFullPreviewButton.row = indexPath.row
        self.loadUrl(message: message)
        self.userNameLabel.isHidden = true
        self.userNameLabel.text = ""
        
        imageFullPreviewButton.isHidden = true
        videoPlayButton.isHidden = true
        openPdfButton.isHidden = true
        activityIndicatorView.isHidden = true
        if message.mediaUploadingStatus == .isUploading {
            activityIndicatorView.isHidden = false
            activityIndicatorView.startAnimating()
        }
        if message.mediaUploadingStatus == .isUploaded {
            if message.type == .image {
                imageFullPreviewButton.isHidden = false
                videoPlayButton.isHidden = true
                openPdfButton.isHidden = true
                pdfIconImageView.isHidden = true
            } else if message.type == .video {
                imageFullPreviewButton.isHidden = true
                videoPlayButton.isHidden = false
                openPdfButton.isHidden = true
                pdfIconImageView.isHidden = true
            } else if message.type == .pdf {
                openPdfButton.isHidden = false
                imageFullPreviewButton.isHidden = true
                videoPlayButton.isHidden = true
                pdfIconImageView.isHidden = false
            }
        }
    }
    
    private func generatePdfThumbnail(of thumbnailSize: CGSize , for documentUrl: URL, atPage pageIndex: Int, completion: @escaping(_ image: UIImage?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let pdfDocument = PDFDocument(url: documentUrl)
            let pdfDocumentPage = pdfDocument?.page(at: pageIndex)
            let image = pdfDocumentPage?.thumbnail(of: thumbnailSize, for: PDFDisplayBox.trimBox)
            completion(image)
        }
    }
    
    private func setPdfThumbnail(image: UIImage?) {
            DispatchQueue.main.async {
                self.mediaImageView.image = image ?? UIImage(named: "pdfWhite")
        }
    }
    
    private func loadUrl(message: Message) {
        if let messageType = message.type {
            switch messageType {
            case .image:
                self.setImageInView(urlString: message.media?.url)
            case .video:
                self.setImageInView(urlString: message.media?.previewImageUrl)
            case .pdf:
                if let pdfLink = message.media?.url, let url = URL(string: pdfLink) {
                    let thumbnailSize = CGSize(width: mediaImageView.frame.width, height: mediaImageView.frame.height)
                    generatePdfThumbnail(of: thumbnailSize, for: url, atPage: 0) { [weak self]image in
                        self?.setPdfThumbnail(image: image)
                    }
                } else {
                    self.mediaImageView.image = UIImage(named: "pdfWhite")
                }
            default:
                self.setImageInView(urlString: nil)
            }
        }
    }
    
    ///set image url in image view
    private func setImageInView(urlString: String?) {
        if let downloadUrlString = urlString,
            let url = URL(string: downloadUrlString) {
//            self.mediaImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "ImagePlaceHolder"))
            self.mediaImageView.kf.setImage(with: url, placeholder: nil)
        } else {
            self.mediaImageView.image = nil//#imageLiteral(resourceName: "ImagePlaceHolder")
        }
    }
    
    /// set the user information in the cell
    ///
    /// - Parameter member: user object
    func setUserInformation(member: Friends) {
        self.userNameLabel.isHidden = false
        self.userNameLabel.text = member.fullName
        if let profileUrl = member.profilePic,
            let url = URL(string: profileUrl) {
            self.userImageView.kf.setImage(with: url, placeholder:#imageLiteral(resourceName: "user-dummy"))
        } else {
            self.userImageView.image = #imageLiteral(resourceName: "user-dummy")
        }
    }
    
    func setViewForSmallerDisplay() {
        self.imageHeightConstraint.isActive = true
        self.imagWidthConstraint.isActive = true
        imageTrailingConstraint.isActive = false
        self.imageFullPreviewButton.isUserInteractionEnabled = false
        self.videoPlayButton.isUserInteractionEnabled = false
        self.imagWidthConstraint.constant = 100
        self.imageHeightConstraint.constant = 100
    }
    
    func addDropShadow() {
        //backShadowView.addDropShadowToView()
    }
}
