//
//  TaskTableHeaderView.swift
//  TemApp
//
//  Created by Shiwani Sharma on 01/05/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import UIKit

class TaskTableHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var addMediaButton: UIButton!
    @IBOutlet weak var taskNameLAbel: UILabel!
    @IBOutlet weak var subtaskButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!

    //MARK: Variables
    var showAddItemDelegate: ShowAddItemDelegate?
    var deleteTaskDelegate: DeleteTaskDelegate?
    var showMediaDelegate: ShowMedia?
    var listOfFiles: [TaskMedia] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        self.mediaCollectionView.registerNibsForCollectionView(nibNames: [TodoMediaCollectionCell.reuseIdentifier])
        collectionViewHeight.constant = 0
        mediaCollectionView.dataSource = self
        mediaCollectionView.delegate = self
    }

    @IBAction func addMediaTapped(_ sender: UIButton) {
        showMediaDelegate?.showMediaSheet(media: .task, taskIndex: sender.tag,subTaskIndex: 0)
    }

    @IBAction func deleteTapped(_ sender: UIButton) {
        deleteTaskDelegate?.deleteTask(index: sender.tag)
    }

    @IBAction func addSubtaskTapped(_ sender: UIButton) {
        showAddItemDelegate?.openAddItemScreen(title: "SUBTASK", willAddSubtask: true,index: sender.tag)
    }

    func configureView(taskName: String){
        self.taskNameLAbel.text = taskName
        if listOfFiles.count  == 0{
            collectionViewHeight.constant = 0
        } else{
            collectionViewHeight.constant = 50
            self.mediaCollectionView.reloadData()
        }
    }
}

//MARK: UICollectionViewDelegate, UICollectionViewDataSource
extension TaskTableHeaderView: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listOfFiles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: TodoMediaCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: TodoMediaCollectionCell.reuseIdentifier, for: indexPath) as? TodoMediaCollectionCell else{
            return UICollectionViewCell()
        }
        if listOfFiles.count > 0{
            cell.setData(data: TodoMedia(url: listOfFiles[indexPath.item].url, mediaType: listOfFiles[indexPath.item].mediaType))
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showMediaDelegate?.redirectToMediaScreens(url: listOfFiles[indexPath.item].url ?? "", mediaType: listOfFiles[indexPath.item].mediaType ?? .video)
    }
}

//MARK: UICollectionViewDelegateFlowLayout
extension TaskTableHeaderView: UICollectionViewDelegateFlowLayout{
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
