//
//  MyMediaMessageTableViewCell.swift
//  TemApp
//
//  Created by shilpa on 04/09/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import PDFKit
import SSNeumorphicView

class MyMediaMessageTableViewCell: UITableViewCell {

    // MARK: Properties
    weak var delegate: ChatMediaMessagesTableCellDelegate?
    
    // MARK: IBOutlets
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var pdfIconImageView: UIImageView!
    @IBOutlet weak var videoPlayButton: CustomButton!
    @IBOutlet weak var imageFullPreviewButton: CustomButton!
    @IBOutlet weak var openPdfButton: CustomButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var imagWidthConstraint: NSLayoutConstraint!
    @IBOutlet var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet var imageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var backShadowView:  SSNeumorphicView! {
        didSet{
            backShadowView.viewDepthType = .outerShadow
            backShadowView.viewNeumorphicMainColor = UIColor.appThemeColor.cgColor
            backShadowView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
            backShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.6).cgColor
            backShadowView.viewNeumorphicShadowOpacity = 0.5
            backShadowView.viewNeumorphicCornerRadius = 8
        }
    }
    
    // MARK: IBActions
    @IBAction func videoPlayButtonTapped(_ sender: CustomButton) {
        let indexPath = IndexPath(row: sender.row, section: sender.section)
        self.delegate?.playVideo(indexPath: indexPath)
    }
    
    @IBAction func imageFullPreviewButtonTapped(_ sender: CustomButton) {
        let indexPath = IndexPath(row: sender.row, section: sender.section)
        self.delegate?.openFullImageAt(indexPath: indexPath)
    }
    
    @IBAction func openPdfButtonTapped(_ sender: CustomButton) {
        let indexPath = IndexPath(row: sender.row, section: sender.section)
        self.delegate?.openPdf(indexPath: indexPath)
    }
    
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imageHeightConstraint.isActive = false
        self.imagWidthConstraint.isActive = false
    }
    
    /*override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
        self.addDropShadow()
    } */

    func initializeWith(message: Message, indexPath: IndexPath) {
        self.videoPlayButton.section = indexPath.section
        self.imageFullPreviewButton.section = indexPath.section
        self.openPdfButton.section = indexPath.section
        self.openPdfButton.row = indexPath.row
        self.videoPlayButton.row = indexPath.row
        self.imageFullPreviewButton.row = indexPath.row
        
        self.loadUrl(message: message)
        
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
            self.mediaImageView.kf.setImage(with: url, placeholder: nil)
//            self.mediaImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "ImagePlaceHolder"))
        } else {
            self.mediaImageView.image = nil//#imageLiteral(resourceName: "ImagePlaceHolder")
        }
    }
    
    func setViewForSmallerDisplay() {
        self.imageHeightConstraint.isActive = true
        self.imagWidthConstraint.isActive = true
        imageLeadingConstraint.isActive = false
        self.imageFullPreviewButton.isUserInteractionEnabled = false
        self.videoPlayButton.isUserInteractionEnabled = false
        self.imagWidthConstraint.constant = 100
        self.imageHeightConstraint.constant = 100
    }
    
    func addDropShadow() {
        //backShadowView.addDropShadowToView()
    }
}
