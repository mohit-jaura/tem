//
//  FoodTrekHistoryListingVC.swift
//  TemApp
//
//  Created by Developer on 14/03/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class FoodTrekHistoryListingVC: UIViewController {
    private var foodTrek:[FoodTrekModel] = [FoodTrekModel]()
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var waterTrackerHIstoryCountLabel: UILabel!
    @IBOutlet weak var waterTrackerHIstoryView: SSNeumorphicView! {
        didSet{
            waterTrackerHIstoryView.viewDepthType = .outerShadow
            waterTrackerHIstoryView.viewNeumorphicMainColor = UIColor.appThemeDarkGrayColor.cgColor
            waterTrackerHIstoryView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
            waterTrackerHIstoryView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
            waterTrackerHIstoryView.viewNeumorphicCornerRadius = waterTrackerHIstoryView.bounds.height / 2
        }
    }

    var selectedDate:Int = 0
    var isOtherUser:Bool = false
    var userId:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        //        getFoodTrekHistoryByDate(date: selectedDate)
        getFoodTrekHistoryByDate(date: selectedDate, isOtherUser: isOtherUser, userId: userId)
        // Do any additional setup after loading the view.
    }
    
    
    // MARK: ViewWillAppear.
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        //   self.configureNavigation()
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func getFoodTrekHistoryByDate(date:Int,isOtherUser:Bool,userId:String){
        //        PostManager.shared.getFoodTrekHistory(date: date,isOtherUser: isOtherUser,userI) { foodTreks in
        //            self.foodTrek = foodTreks
        //            DispatchQueue.main.async {
        //                self.tableView.reloadData()
        //            }
        //        } failure: { error in
        //
        //        }
        PostManager.shared.getFoodTrekHistory(date: date, isOtherUser: isOtherUser, userId: userId) { foodTreks, waterCount in
            self.foodTrek = foodTreks
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.waterTrackerHIstoryCountLabel.text = "\(waterCount)"
            }
        } failure: { error in
            DILog.print(items: error.message)
        }
    }
    
    @IBAction func onClickComment(_ sender:UIButton) {
        let value = sender.tag
        let commentsVC : CommentsController = UIStoryboard(storyboard: .post).initVC()
        commentsVC.postId = self.foodTrek[value]._id ?? ""
        //        commentsVC.delegate = self
        //        commentsVC.indexPath = value
        commentsVC.isFromFoodTrek = true
        self.navigationController?.pushViewController(commentsVC, animated: true)
    }
    
    @IBAction func onClickRightComment(_ sender:UIButton) {
        let value = sender.tag
        let commentsVC : CommentsController = UIStoryboard(storyboard: .post).initVC()
        commentsVC.postId = self.foodTrek[value]._id ?? ""
        //        commentsVC.delegate = self
        //        commentsVC.indexPath = value
        commentsVC.isFromFoodTrek = true
        self.navigationController?.pushViewController(commentsVC, animated: true)
        
    }
    
    @IBAction func onClickRightLike(_ sender:UIButton) {
        let value1 = sender.tag
        
        let status = foodTrek[value1].likes.contains(where: { $0.user_id == User.sharedInstance.id ?? "" })
        
        
        let value:[String:Any] = ["post_id":foodTrek[value1]._id ?? "","status": status ? 2 : 1]
        DIWebLayerUserAPI().likeOrDislikePost(isFromTrek:true, parameters: value, success: { (message) in
            self.getFoodTrekHistoryByDate(date: self.selectedDate, isOtherUser: self.isOtherUser, userId: self.userId)
        }) { (_) in
        }
        
    }
    
    
    @IBAction func onClickLeftLike(_ sender:UIButton) {
        let value1 = sender.tag
        
        let status = foodTrek[value1].likes.contains(where: { $0.user_id == User.sharedInstance.id ?? "" })
        
        
        let value:[String:Any] = ["post_id":foodTrek[value1]._id ?? "","status": status ? 2 : 1]
        DIWebLayerUserAPI().likeOrDislikePost(isFromTrek:true,parameters: value, success: { (message) in
            self.getFoodTrekHistoryByDate(date: self.selectedDate, isOtherUser: self.isOtherUser, userId: self.userId)
        }) { (error) in
        }
        
        
    }
    
    func getTrekTime(timeStamp:Int) -> String {
        let sDate = String(describing: timeStamp)
        var date = Date()
        if sDate.count == 10 {
            date = timeStamp.toDate
        }
        else if sDate.count == 13 {
            date = timeStamp.timestampInMillisecondsToDate
        }
        return date.toString(inFormat: .time) ?? ""
    }
    
}

extension FoodTrekHistoryListingVC:UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodTrek.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var isLeftTrek: Bool?
        let data = foodTrek[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrekLeftTVC", for: indexPath) as! TrekLeftTVC
        let status = foodTrek[indexPath.row].likes.contains(where: { $0.user_id == User.sharedInstance.id ?? "" })
        if data.trek == 1 {
            isLeftTrek = true
            if indexPath.row == foodTrek.count - 1 {
                cell.leftBottomLbl.isHidden = true
            } else {
                
                let value = indexPath.row + 1
                if foodTrek[value].trek == 1 {
                    cell.leftBottomLbl.isHidden = true
                } else if foodTrek[value].trek == 2 {
                    cell.leftBottomLbl.isHidden = false
                }
            }
            cell.view1.isHidden = false
            cell.view2.isHidden = true
            cell.leftButton.tag = indexPath.row
            cell.leftLikeButton.tag = indexPath.row
            cell.leftTimeLbl.text = getTrekTime(timeStamp: data.date ?? 0)
            if status {
                cell.leftLikeButton.setImage(#imageLiteral(resourceName: "high five-blue"), for: .normal)
            } else {
                cell.leftLikeButton.tintColor = .black
                cell.leftLikeButton.setImage(#imageLiteral(resourceName: "high five"), for: .normal)
            }
            cell.imageView1.kf.indicatorType = .activity
            if let text = data.text, text.count > 0 {
                cell.leftcaptionShadowView.isHidden = false
                cell.lbl.row = indexPath.row
                cell.lbl.section = indexPath.section
                cell.lbl.text = text
                cell.setAndDetectTagsInCaption(descriptionLabel: cell.lbl)
            } else {
                cell.leftcaptionShadowView.isHidden = true
            }
            if let urlString = data.image,
               let url = URL(string: urlString) {
                cell.imageView1.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: { (receivedSize, totalSize) in
                }, completionHandler: {(result) in
                })
            }
        } else {
            isLeftTrek = false
            if indexPath.row == foodTrek.count - 1 {
                cell.leftBottomLbl.isHidden = true
            } else {
                
                let value = indexPath.row + 1
                if foodTrek[value].trek == 1 {
                    cell.leftBottomLbl.isHidden = false
                } else if foodTrek[value].trek == 2 {
                    
                    cell.leftBottomLbl.isHidden = true
                }
            }
            cell.view2.isHidden = false
            cell.view1.isHidden = true
            cell.rightButton.tag = indexPath.row
            cell.rightLikeButton.tag = indexPath.row
            cell.rightTimeLbl.text = getTrekTime(timeStamp: data.date ?? 0)
            if status {
                cell.rightLikeButton.setImage(#imageLiteral(resourceName: "high five-blue"), for: .normal)
            } else {
                cell.rightLikeButton.tintColor = .black
                cell.rightLikeButton.setImage(#imageLiteral(resourceName: "high five"), for: .normal)
            }
            cell.imageView2.kf.indicatorType = .activity
            if let text = data.text, text.count > 0 {
                cell.rightcaptionShadowView.isHidden = false
                cell.lbl1.row = indexPath.row
                cell.lbl1.section = indexPath.section
                cell.lbl1.text = text
                cell.setAndDetectTagsInCaption(descriptionLabel: cell.lbl1)
            } else {
                cell.rightcaptionShadowView.isHidden = true
            }
            if let urlString = data.image,
               let url = URL(string: urlString) {
                cell.imageView2.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: { (receivedSize, totalSize) in
                }, completionHandler: {(result) in
                })
            }
        }
        if let isLeftTrek = isLeftTrek {
            let dir: WaterTrackerDirection = isLeftTrek ? .left : .right
            var nextDir: WaterTrackerDirection = dir
            if indexPath.row < foodTrek.count - 1 {
                let nextTrek = foodTrek[indexPath.row + 1].trek ?? 0
                nextDir = nextTrek == 1 ? .left : .right
            }
            cell.fillData(currentDirection: dir, nextDirection: nextDir)
        }
        return cell
        
    }
}
