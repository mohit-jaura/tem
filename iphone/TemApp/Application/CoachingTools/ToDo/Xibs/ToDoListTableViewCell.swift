//
//  ToDoListTableViewCell.swift
//  TemApp
//
//  Created by Mohit Soni on 17/02/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import UIKit

protocol AcceptDenyTodoDelegate{
    func acceptDenyCalled(tag: Int,isAccepted:Bool)
}


class ToDoListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var statusView: UIView!
    
    @IBOutlet weak var denyButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var coachImageView: UIImageView!
    @IBOutlet weak var activityLbl: UILabel!
    @IBOutlet weak var coachNameLbl: UILabel!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!

    var listOfFiles: [TodoMedia] = []
    var showMediaDelegate: ShowMedia?
    var acceptDenyTodoDelegate: AcceptDenyTodoDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.mediaCollectionView.registerNibsForCollectionView(nibNames: [TodoMediaCollectionCell.reuseIdentifier])
        mediaCollectionView.delegate = self
        mediaCollectionView.dataSource = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func acceptTapped(_ sender: UIButton) {
        acceptDenyTodoDelegate?.acceptDenyCalled(tag: sender.tag,isAccepted: true)
    }
    @IBAction func denyTapped(_ sender: UIButton) {
        acceptDenyTodoDelegate?.acceptDenyCalled(tag: sender.tag,isAccepted: false)
    }
    func setCellData(data: ToDoList) {
        statusView.cornerRadius = statusView.frame.height / 2
        coachImageView.cornerRadius = coachImageView.frame.height / 2
        activityLbl.text = data.title ?? ""
        coachNameLbl.text = "\(data.affiliateFirstName ?? "") \(data.affiliateLastName ?? "")"
        if let isCompleted = CustomBool(rawValue: data.isCompleted ?? 0) {
            if isCompleted == .yes {
                statusView.backgroundColor = .systemGreen
            } else {
                statusView.backgroundColor = .systemRed
            }
        }
        if data.isShared == 0 || data.isShared == 2{
            statusView.isHidden = false
            acceptButton.isHidden = true
            denyButton.isHidden = true
        } else{
            statusView.isHidden = true
            acceptButton.isHidden = false
            denyButton.isHidden = false
        }
        if let imageLink = data.affiliateProfilePic, let url = URL(string: imageLink) {
            coachImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "user-dummy"))
        }
        if listOfFiles.count  == 0{
            collectionViewHeight.constant = 0
        } else{
            collectionViewHeight.constant = 50
            mediaCollectionView.reloadData()
        }
    }

    
}
extension ToDoListTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listOfFiles.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: TodoMediaCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: TodoMediaCollectionCell.reuseIdentifier, for: indexPath) as? TodoMediaCollectionCell else{
            return UICollectionViewCell()
        }
        if listOfFiles.count > 0 {
            cell.setData(data: TodoMedia(url: listOfFiles[indexPath.item].url, mediaType: listOfFiles[indexPath.item].mediaType))
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      showMediaDelegate?.redirectToMediaScreens(url: listOfFiles[indexPath.item].url ?? "", mediaType: listOfFiles[indexPath.item].mediaType ?? .video)
    }
}

//MARK: UICollectionViewDelegateFlowLayout
extension ToDoListTableViewCell: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width: 50, height: 50)

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
