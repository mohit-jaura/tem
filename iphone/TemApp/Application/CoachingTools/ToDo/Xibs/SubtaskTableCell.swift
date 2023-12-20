//
//  SubtaskTableCell.swift
//  TemApp
//
//  Created by Shiwani Sharma on 01/05/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import UIKit

class SubtaskTableCell: UITableViewCell {

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var subtaskNameLabel: UILabel!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!

    @IBOutlet weak var addMediaButton: UIButton!

    var deleteTaskDelegate: DeleteTaskDelegate?
    var taskIndex: Int?
    var showMediaDelegate: ShowMedia?
    var listOfFiles: [SubTaskMedia] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        self.mediaCollectionView.registerNibsForCollectionView(nibNames: [TodoMediaCollectionCell.reuseIdentifier])
        mediaCollectionView.delegate = self
        mediaCollectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    @IBAction func deleteTapped(_ sender: UIButton) {
        deleteTaskDelegate?.deleteSubTask(taskIndex: taskIndex ?? 0, subtaskIndex: sender.tag)
    }
    
    @IBAction func addMediaTapped(_ sender: UIButton) {
        showMediaDelegate?.showMediaSheet(media: .subtask,taskIndex: taskIndex ?? 0,subTaskIndex: sender.tag)
    }

    func configureView(subTaskName: String){
        subtaskNameLabel.text = subTaskName
        if listOfFiles.count  == 0{
            collectionViewHeight.constant = 0
        } else{
            collectionViewHeight.constant = 50
             mediaCollectionView.reloadData()
        }
    }
}


//MARK: UICollectionViewDelegate, UICollectionViewDataSource
extension SubtaskTableCell: UICollectionViewDelegate, UICollectionViewDataSource{
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
extension SubtaskTableCell: UICollectionViewDelegateFlowLayout{
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
