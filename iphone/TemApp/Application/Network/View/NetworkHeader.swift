//
//  NetworkHeader.swift
//  VIZU
//
//  Created by shubam on 06/10/18.
//  Copyright © 2018 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
protocol NetworkHeaderDelegate {
    func expandCollapseTapped(section:Int)
    func selectedQuestion(cell:NetworkHeader,section:Int)
}

class NetworkHeader: UITableViewHeaderFooterView {
    var section = 0
    var delegate : NetworkHeaderDelegate?
    var isPendingRequestOpen = true
    var isSentRequestOpen = true
    let grayishColor = #colorLiteral(red: 0.2431372702, green: 0.2431372702, blue: 0.2431372702, alpha: 1)
    @IBOutlet weak var expandCollapseBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dropDownImgVw: UIImageView!
    @IBOutlet weak var ptsLbl: UILabel!
    @IBOutlet weak var selectedBtn: UIButton!
    @IBOutlet weak var backView: SSNeumorphicView!{
        didSet{
            backView.viewDepthType = .outerShadow
            backView.viewNeumorphicMainColor = grayishColor.cgColor
            backView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
            backView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
            //  headerBgView.viewNeumorphicCornerRadius = 0
        }
    }
    @IBOutlet weak var headerBgView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureQuestionCell(section:Int,question:Question){
        self.section = section
        titleLbl.text = question.subject
        titleLbl.textColor = question.isSelected ? .white : .black
        self.contentView.backgroundColor = question.isSelected ? .black : .white
        expandCollapseBtn.isUserInteractionEnabled = !question.isSelected
        if !question.isSelected {
            let buttonImage = question.isOpen ?  #imageLiteral(resourceName: "ArrowUp") : #imageLiteral(resourceName: "downArrow")
            expandCollapseBtn.setImage(buttonImage, for: .normal)
        } else {
             expandCollapseBtn.setImage(#imageLiteral(resourceName: "correctwhite.png"), for: .normal)
        }
        
    }
    
    func configureCell(section:Int,count:Int = 0){
        self.section = section
        if let header = NetworkSection(rawValue: section){
            if count == 0 {
                titleLbl.text = header.getSectionTitle().uppercased()
            } else {
                titleLbl.text = count.stringValue + " " + header.getSectionTitle().uppercased()
            }
        }
    }
    
    func configure(section: NetworkSection, count: Int = 0) {
        self.expandCollapseBtn.tag = section.rawValue//hide button
        if count == 0 {
            titleLbl.text = section.getSectionTitle()
        } else {
            titleLbl.text = count.stringValue + " " + section.getSectionTitle()
        }
    }
    
    func setUpExapndImage(isOpen:Bool){
        self.dropDownImgVw.image = isOpen ? #imageLiteral(resourceName: "ArrowUp") : #imageLiteral(resourceName: "downArrow")
    }

    
    @IBAction func expandCollapseTapped(_ sender: UIButton) {
        delegate?.expandCollapseTapped(section: sender.tag)
    }
    
    @IBAction func selectQuestionTapped(_ sender: UIButton) {
        delegate?.selectedQuestion(cell:self,section:section)
    }
}
