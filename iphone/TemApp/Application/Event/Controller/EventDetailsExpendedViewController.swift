//
//  EventDetailsExpendedViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 28/02/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class EventDetailsExpendedViewController: UIViewController {
    
    // MARK: OUtlets
    @IBOutlet weak var membersView: UICollectionView!
    @IBOutlet weak var shadowView: SSNeumorphicView!{
        didSet{
            setShadow(view: shadowView, shadowType: .innerShadow)
        }
    }
    @IBOutlet var lineShadowView: SSNeumorphicView! {
        didSet {
            lineShadowView.viewDepthType = .innerShadow
            lineShadowView.viewNeumorphicMainColor = lineShadowView.backgroundColor?.cgColor
            lineShadowView.viewNeumorphicLightShadowColor = UIColor.clear.cgColor
            lineShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
            lineShadowView.viewNeumorphicCornerRadius = 0
        }
    }
    // MARK: Properties
    var eventDetail : EventDetail?
    var activityDetail: GroupActivity?{
        didSet{
            seprateActivityMembers(activityMembers: activityDetail?.members ?? [])
        }
    }
    var joinedMembers:[ActivityMember] = [ActivityMember]()
    var notJoinedMembers:[ActivityMember] = [ActivityMember]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: Helper Function
    func setShadow(view: SSNeumorphicView, shadowType: ShadowLayerType,isType:Bool = false){
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor = UIColor.newAppThemeColor.cgColor
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        if isType{
            view.viewNeumorphicCornerRadius = 25
        } else{
            view.viewNeumorphicCornerRadius = 8
        }
        
        view.viewNeumorphicShadowRadius = 3
    }
    
    private func seprateActivityMembers(activityMembers:[ActivityMember]){
        for activityMember in activityMembers{
            if activityMember.inviteAccepted == 0{
                notJoinedMembers.append(activityMember)
            }else{
                joinedMembers.append(activityMember)
            }
        }
    }
    
}
extension EventDetailsExpendedViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if self.eventDetail?.members?.count != nil {
            return 1
        }
        if self.activityDetail?.members != nil {
            return 2
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let eventMembersCount = self.eventDetail?.members?.count{
            return eventMembersCount
        }
        if self.activityDetail?.members != nil {
            if  section == 1{
                return notJoinedMembers.count
            }else{
                return joinedMembers.count
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExpendedTematesCollectionViewCell.reuseIdentifier, for: indexPath) as? ExpendedTematesCollectionViewCell else {
            return UICollectionViewCell()
        }
        if let member = self.eventDetail?.members?[indexPath.item]{
            cell.configureCellForEventDetails(member:member)
        }
        if self.activityDetail?.members?[indexPath.item] != nil{
            if indexPath.section == 1{
                cell.configureCellForActivityDetails(member: notJoinedMembers[indexPath.item])
            }else{
                cell.configureCellForActivityDetails(member: joinedMembers[indexPath.item])
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if self.eventDetail != nil{
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ExpendedTematesCollectionViewCellHeaderCollectionReusableView.reuseIdentifier, for: indexPath) as? ExpendedTematesCollectionViewCellHeaderCollectionReusableView else{
                return UICollectionReusableView()
            }
            sectionHeader.titleLbl.text = ""
            return sectionHeader
        }
        
        if self.activityDetail != nil{
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ExpendedTematesCollectionViewCellHeaderCollectionReusableView.reuseIdentifier, for: indexPath) as? ExpendedTematesCollectionViewCellHeaderCollectionReusableView else{
                return UICollectionReusableView()
            }
            if indexPath.section == 1{
                sectionHeader.titleLbl.text = "Invited But Not Yet Joined"
            }else{
                sectionHeader.titleLbl.text = "Joined"
            }
            return sectionHeader
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if self.eventDetail != nil {
            return CGSize(width: collectionView.frame.width, height: 0)
        }
        if self.activityDetail != nil {
            return CGSize(width: collectionView.frame.width, height: 40)
        }
        return CGSize(width: collectionView.frame.width, height: 0)
    }
}
