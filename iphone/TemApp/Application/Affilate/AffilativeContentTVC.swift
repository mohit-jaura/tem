//
//  AffilativeContentTVC.swift
//  TemApp
//
//  Created by Developer on 11/04/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

enum TypeCheck: Int, CaseIterable{
    case goal = 1, challenge, event, program
}

class AffilativeContentTVC: UITableViewCell {
    
    @IBOutlet weak var collectionView1:UICollectionView!
    var contentModel:[ContentModel]?
    var content:Bool = false
    var indexSelected:[Int] = [-1, -1, -1, -1]
    var affilativeCommunityContentParticularModel:[AffilativeCommunityContentParticularModel]?
    var affilativeContentVC:AffilativeContentVC = AffilativeContentVC()
    var affilativeCommunityVC:AffilativeCommunityVC = AffilativeCommunityVC()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    var model: [ContentModel]?{
        didSet {
            content = false
            self.contentModel = model
            collectionView1.reloadData()
        }
    }
    
    var model1: [AffilativeCommunityContentParticularModel]?{
        didSet {
            content = true
            self.affilativeCommunityContentParticularModel = model1
            
            collectionView1.reloadData()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension AffilativeContentTVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if content {
            return affilativeCommunityContentParticularModel?.count ?? 0
        } else {
            return contentModel?.count ?? 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 100)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AffilativeContentCVC", for: indexPath) as! AffilativeContentCVC
        if content {
            let data = affilativeCommunityContentParticularModel?[indexPath.row]
            cell.imageView.kf.indicatorType = .activity
            
             let name =  data?.name ?? data?.programName ?? ""
            cell.name.text = name.capitalized
            
            cell.description1.text = data?.description ?? "".capitalized
            if let urlString = data?.image,
                let url = URL(string: urlString) {
                cell.imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
            }else{
                if let urlString = data?.programThumbnail,
                   let url = URL(string: urlString) {
                    cell.imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
                } else {
                    cell.imageView.backgroundColor = .darkGray
                }
                
            }
            return cell
        } else {
            let data = contentModel?[indexPath.row]
            let name =  data?.name ?? ""
            cell.name.text = name.capitalized
            cell.imageView.kf.indicatorType = .activity
            if let urlString = data?.preview,
                let url = URL(string: urlString) {
                cell.imageView.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: { (receivedSize, _) in
                }, completionHandler: {(_) in
                })
            }
            return cell
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if content {
            let data = affilativeCommunityContentParticularModel?[indexPath.row]
            let typeCheck = TypeCheck(rawValue: data?.typecheck ?? 0)
            switch typeCheck{
            case .event:
                let eventDetailVC:EventDetailViewController = UIStoryboard(storyboard: .calendar).initVC()
                eventDetailVC.eventId = data?.id ?? ""
                affilativeCommunityVC.navigationController?.pushViewController(eventDetailVC, animated: true)
            case .goal:
                let goalDetailController: GoalDetailContainerViewController = UIStoryboard(storyboard: .challenge).initVC()
                goalDetailController.goalId = data?.id ?? ""
                goalDetailController.selectedGoalName = data?.name ?? ""
                affilativeCommunityVC.navigationController?.pushViewController(goalDetailController, animated: true)
            case .challenge:
                let selectedVC:ChallengeDetailController = UIStoryboard(storyboard: .goalandchallengedetailnew).initVC()
                selectedVC.challengeId = data?.id ?? ""
                affilativeCommunityVC.navigationController?.pushViewController(selectedVC, animated: true)
            case .program:
                let eventDetailVC:ProgramDetailsController = UIStoryboard(storyboard: .contentMarket).initVC()
                eventDetailVC.programID = data?.id ?? ""
                affilativeCommunityVC.navigationController?.pushViewController(eventDetailVC, animated: true)
            default:
                break
            }
            
        } else {
            let affilativeContentDetailVC: AffilativeDetailLandingVC = UIStoryboard(storyboard: .affilativeContentBranch).initVC()
            affilativeContentDetailVC.marketPlaceId = self.contentModel?[indexPath.row]._id ?? ""
            affilativeContentVC.navigationController?.pushViewController(affilativeContentDetailVC, animated: true)
        }
        
    }
}
