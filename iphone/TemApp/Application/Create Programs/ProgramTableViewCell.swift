//
//  ProgramTableViewCell.swift
//  TemApp
//
//  Created by Shiwani Sharma on 07/12/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

protocol ShowMediaDelegate: AnyObject{
    func showMedia(media type: Int, url: String)
}

class ProgramTableViewCell: UITableViewCell {
    
    // MARK: IBoutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var visibilityLabel: UILabel!
    @IBOutlet weak var activityButton: SSNeumorphicButton!
    @IBOutlet weak var checklistButton: SSNeumorphicButton!
    @IBOutlet weak var checklistArrowBtn: UIButton!
    @IBOutlet weak var activityArrowBtn: UIButton!
    @IBOutlet weak var checklistLAbel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var mediaBgView: SSNeumorphicView!{
        didSet {
           addInnerShadow(view: mediaBgView)
        }
    }
    @IBOutlet weak var bgView: SSNeumorphicView! {
        didSet {
           addInnerShadow(view: bgView)
        }
    }
    @IBOutlet weak var activityLabelBgView: SSNeumorphicView!{
        didSet {
           addInnerShadow(view: activityLabelBgView)
        }
    }
    @IBOutlet weak var checklistBgLabelView: SSNeumorphicView!{
        didSet {
           addInnerShadow(view: checklistBgLabelView)
        }
    }
    
    var programData: Programs?{
        didSet{
            collectionView.reloadData()
        }
    }
    var showMediaDelegate: ShowMediaDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.registerNibsForCollectionView(nibNames: [MediaCollectionCell.reuseIdentifier])
        collectionView.delegate = self
        collectionView.dataSource = self
        configureButtons()
        }
    
        // MARK: Helper functions
    func configureButtons(){
        activityButton.imageEdgeInsets = UIEdgeInsets(top: 0, left:  (activityButton.frame.size.width / 2 - 55), bottom: 0, right: 0)
        checklistButton.imageEdgeInsets = UIEdgeInsets(top: 0, left:  (checklistButton.frame.size.width / 2 - 70), bottom: 0, right: 0)
        setBtnShadow(btn: activityButton, shadowType: .outerShadow)
        setBtnShadow(btn: checklistButton, shadowType: .outerShadow)
    }
    
    func addInnerShadow(view: SSNeumorphicView){
        view.viewDepthType = .innerShadow
        view.viewNeumorphicLightShadowColor = UIColor(red: 163.0 / 255.0, green: 177.0 / 255.0, blue: 198.0 / 255.0, alpha: 0.3).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.3).cgColor
        view.viewNeumorphicCornerRadius = 8.0
        view.viewNeumorphicMainColor = UIColor.blakishGray.cgColor
        view.viewNeumorphicShadowRadius = 2.0
    }
    
    @IBAction func activityArrowTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
          //  activityLabelBgView.isHidden = false
        }else{
         //   activityLabelBgView.isHidden = true
        }
    }
    
    @IBAction func checklistTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
            if sender.isSelected{
             //   checklistBgLabelView.isHidden = false
            }else{
             //   checklistBgLabelView.isHidden = true
        }
    }
    
    func setData(data: Programs?){
        programData = data
        locationLabel.text = "Location: \(data?.location?.location ?? "")"
        descriptionLabel.text = data?.description?.capitalized
        visibilityLabel.text = "Visibility: \(data?.visibility ?? "")"
        setActivityData()
        setChecklistData()
    }
    
    func setActivityData(){
        var info = [String]()
        if let addOnArr = programData?.activityAddOn,addOnArr.count > 0 {
            //Get all categories
            let allCats = Array(Set(addOnArr.map({return $0.category_id})))
            for i in 0..<allCats.count {
                let filterOne = addOnArr.filter({$0.category_id == allCats[i]})
                let count = filterOne.count
                let name = (filterOne.first?.category_name ?? "Activity \(i+1)").capitalized
                info.append("\(name) (\(count) Activit\(count > 1 ? "ies" : "y"))")
            }
            activityLabel.text = info.reduce("", {$0 + $1 + "\n"})
        }else {
            activityLabel.text = "No Activity added !"
            activityLabel.textAlignment = .center
        }
    }
    
    func setChecklistData(){
        checklistLAbel.textAlignment = .left
        var lblText = ""
        if programData?.rounds?.count == 0{
            lblText = "No checklist added !"
            checklistLAbel.textAlignment = .center
        }else if  programData?.rounds?.count ?? 0 > 2{
            lblText = """
                                Round1   (\( programData?.rounds?[0].tasks?.count ?? 0) Tasks)
                                Round2   (\( programData?.rounds?[1].tasks?.count ?? 0) Tasks)
                                """
        }
        else{
            for round in (0...(programData?.rounds?.count ?? 0)-1){
                lblText.append("Round\(round+1)   (\( programData?.rounds?[round].tasks?.count ?? 0) Task)\n")
            }
        }
        checklistLAbel.text = lblText
    }
    
    func setBtnShadow(btn: SSNeumorphicButton, shadowType: ShadowLayerType){
        btn.btnNeumorphicCornerRadius = 4
        btn.btnNeumorphicShadowRadius = 0.4
        btn.btnDepthType = shadowType
        btn.btnNeumorphicLayerMainColor = #colorLiteral(red: 0.2431372702, green: 0.2431372702, blue: 0.2431372702, alpha: 1).cgColor
        btn.btnNeumorphicShadowOpacity = 0.25
        btn.btnNeumorphicDarkShadowColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        btn.btnNeumorphicShadowOffset = CGSize(width: -2, height: -2)
        btn.btnNeumorphicLightShadowColor = UIColor.black.cgColor
    }
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension ProgramTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if programData?.eventMedia?.count ?? 0 > 0{
            return programData?.eventMedia?.count ?? 0
        } else{
                collectionView.setEmptyMessage("No media added", textColor: .white)
            return 0
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaCollectionCell.reuseIdentifier, for: indexPath) as? MediaCollectionCell else{
            return UICollectionViewCell()
            
        }
        if let data = programData, let urls = data.eventMedia{
            cell.setData(data: urls[indexPath.item])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let mediaType = programData?.eventMedia?[indexPath.item].mediaType{
                    showMediaDelegate?.showMedia(media: mediaType, url: programData?.eventMedia?[indexPath.item].url ?? "")
             
                }
            }
    }

