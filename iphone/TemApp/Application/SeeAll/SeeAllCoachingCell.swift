//
//  SeeAllCoachingCell.swift
//  TemApp
//
//  Created by PrabSharan on 29/11/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import Kingfisher

class SeeAllCoachingCell: UITableViewCell {
    @IBOutlet weak var msgButOut: CustomButton!
    @IBOutlet weak var bookmarkButOut: CustomButton!
    @IBOutlet weak var profileButOut: CustomButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImgView: CircularImgView!
    @IBOutlet weak var backgroundImageView: UIImageView!

    var redirectMsg:IndexSelected?
    var profileRedirect:IndexSelected?
    var bookMarkHandler: IntCompletion?
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func msgAction(_ sender: CustomButton) {
        redirectMsg?(IndexPath(row: sender.row, section: sender.section))
    }
    
    @IBAction func bookmarkAction(_ sender: CustomButton) {
        if let bookMarkHandler = bookMarkHandler {
            let isBookMark = sender.isSelected ? 0 : 1
            bookMarkHandler(isBookMark, IndexPath(row: sender.row, section: sender.section))
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func profileAction(_ sender: CustomButton) {
        profileRedirect?(IndexPath(row: sender.row, section: sender.section))
    }
    func setData(_ data:SeeAllModel?, indexPath: IndexPath){
        guard let data = data else {return}
        if let urlStr = data.store_image_thumbnail, let url = URL(string: urlStr) {
            let scale = UIScreen.main.scale
            let resizingProcessor = ResizingImageProcessor(referenceSize: CGSize(width: backgroundImageView.frame.width * scale, height: backgroundImageView.frame.height * scale))
            backgroundImageView.kf.indicatorType = .activity
            backgroundImageView.kf.setImage(with: url,
                                            options: [.processor(resizingProcessor)])
        }
        profileImgView.setImg(data.profile_pic,#imageLiteral(resourceName: "ImagePlaceHolder"))
        nameLabel.text = data.title
        bookmarkButOut.row = indexPath.row
        bookmarkButOut.section = indexPath.section
        msgButOut.row = indexPath.row
        msgButOut.section = indexPath.section
        profileButOut.row = indexPath.row
        profileButOut.section = indexPath.section
        if let isBookMark = data.isBookMark {
            bookmarkButOut.isSelected = isBookMark == 1 ? true : false
        }
    }
}
