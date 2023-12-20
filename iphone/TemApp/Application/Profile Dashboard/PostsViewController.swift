//
//  PostsViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 12/01/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

class PostsViewController: UIViewController {
    
    private var arrStaticHeight = [200,200]
    private var lastUsedLayout = 10
    var delegate:ViewPostDetailDelegate?
    var userPosts:[Post] = [Post]()
    var userProfile: Friends?
    var postLblTitle:String = ""
    @IBOutlet weak var postCollectionView: UICollectionView!
    @IBOutlet weak var postLbl:UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let layout = postCollectionView?.collectionViewLayout as? CustomFlowLayout {
            layout.delegate = self
        }
        self.postCollectionView.register(UINib(nibName: GridCollectionCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: GridCollectionCell.reuseIdentifier)
        postLbl.text = postLblTitle
        UserDefaults().setValue(Constant.ScreenSize.SCREEN_WIDTH, forKey: "Height")
    }
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
      //  self.tabBarController?.navigationItem.hidesBackButton = true
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
// MARK: UICollectionViewDelegate, UICollectionViewDataSource, CustomFlowLayoutDelegate
extension PostsViewController: UICollectionViewDelegate, UICollectionViewDataSource, CustomFlowLayoutDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.userPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell:GridCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: GridCollectionCell.reuseIdentifier, for: indexPath) as? GridCollectionCell else {
            return UICollectionViewCell()
        }
        cell.screenFrom = .createPost
        
        if indexPath.item < self.userPosts.count {
            if self.userPosts[indexPath.item].media?.count == 0{
                cell.videoPlayIcon.isHidden = true
                cell.videoIconImageView.isHidden = true
                cell.descriptionLabel.text = self.userPosts[indexPath.item].caption
                cell.descriptionLabel.isHidden = false
            }else{
                cell.descriptionLabel.isHidden = true
                cell.videoPlayIcon.isHidden = false
                cell.videoIconImageView.isHidden = false
                cell.setData(data: self.userPosts[indexPath.item].media?[0] ?? Media(), postType: self.userPosts[indexPath.item].type ?? PostType.normal)
            }
            cell.soundButton.isHidden = true
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
        var randomNumber = getRandomNumber()
        while lastUsedLayout == randomNumber {
            randomNumber =  getRandomNumber()
            continue
        }
        var height:CGFloat = 0
        let (_,remainder) = indexPath.row.quotientAndRemainder(dividingBy: 2)
        if (remainder == 1) {
            height = CGFloat(arrStaticHeight[remainder])
            arrStaticHeight = arrStaticHeight.reversed()
        } else {
            height = CGFloat(arrStaticHeight[remainder])
        }
        return height
    }
    
    
    func getRandomNumber() -> Int{
        let lower : UInt32 = 0
        let upper : UInt32 = UInt32(arrStaticHeight.count)
        let randomNumber = Int(arc4random_uniform(upper - lower) + lower)
        return randomNumber
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let controller : PostDetailController = UIStoryboard(storyboard: .profile).initVC()
        controller.post = self.userPosts[indexPath.row]
        controller.indexPath = indexPath
        controller.user = self.userProfile
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
}

// MARK: PostDetailDotsDelegate
extension PostsViewController: PostDetailDotsDelegate {
    func dotsButtonAction(indexPath: IndexPath, type: UserActions) {
        //  self.hideLoader()
        switch type {
        case .delete:
            if let postCount = self.userProfile?.feedsCount,
               postCount > 0 {
                self.userProfile?.feedsCount = postCount - 1
                print("You have not created a post yet. Once you have, all your posts live here.")
            }
            
            self.userPosts.remove(at: indexPath.row)
            self.postCollectionView.reloadData()
        case .unfriend:
            self.userProfile?.friendStatus = .other
            //   self.updateConnectionStatusButtonView()
            self.postCollectionView.reloadData()
        case .report :
            self.userPosts.remove(at: indexPath.row)
            self.postCollectionView.reloadData()
        case .block :
            self.userProfile?.friendStatus = .blocked
            //      self.postButton.isUserInteractionEnabled = false
            //       self.tematesButton.isUserInteractionEnabled = false
            self.userPosts.removeAll()
            //       self.updateConnectionStatusButtonView()
            self.postCollectionView.reloadData()
        default:
            break
        }
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout

extension PostsViewController: UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        return CGSize(width: collectionViewWidth/3, height: collectionViewWidth/3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}
