//
//  ToDoListTableViewCell.swift
//  TemApp
//
//  Created by Mohit Soni on 17/02/23.
//  Copyright ©  2023 Capovela LLC. All rights reserved.
//

import UIKit

class ToDoActivityDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var backShadowView: UIView!
    @IBOutlet weak var taskNameLbl: UILabel!
    @IBOutlet weak var taskStatusBtn: UIButton!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!


    var taskSelected: OnlyIntCompletion?
    var currentCompletedTask: Int?
    var saveCompletedTaskTags: [Int] = []
    var taskFiles: [TaskMedia] = []
    var subtaskFiles: [SubTaskMedia] = []
    var isScreenForSubtask = false
    var showMediaDelegate: ShowMedia?

    override func awakeFromNib() {
        super.awakeFromNib()
        statusView.cornerRadius = statusView.frame.height / 2
        self.mediaCollectionView.registerNibsForCollectionView(nibNames: [TodoMediaCollectionCell.reuseIdentifier])
        mediaCollectionView.delegate = self
        mediaCollectionView.dataSource = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func taskStatusTapped(_ sender: UIButton) {
        if sender.isUserInteractionEnabled {
            if let taskSelected = taskSelected {
                taskSelected(sender.tag)
            }
        }
    }
    
    func setCellData(data: ToDoTasks, tag: Int) {
        isScreenForSubtask = false
        taskNameLbl.text = data.taskName ?? ""
        taskStatusBtn.tag = tag
        if let isCompleted = CustomBool(rawValue: data.isCompleted ?? 0) {
            if isCompleted == .yes {
                taskStatusBtn.isUserInteractionEnabled = false
                statusView.backgroundColor = .systemGreen
            } else {
                taskStatusBtn.isUserInteractionEnabled = true
                statusView.backgroundColor = .systemRed
            }
        }
        if taskFiles.count  == 0{
            collectionViewHeight.constant = 0
        } else{
            collectionViewHeight.constant = 50
            mediaCollectionView.reloadData()
        }
    }
    func configureCellForSubTasks(data: SubTasks, tag: Int) {
        isScreenForSubtask = true
        taskNameLbl.text = data.subtaskName ?? ""
        taskStatusBtn.tag = tag
        if let isCompleted = CustomBool(rawValue: data.isCompleted ?? 0) {
            if isCompleted == .yes{
                taskStatusBtn.isUserInteractionEnabled = false
                statusView.backgroundColor = .systemGreen
            } else {
                taskStatusBtn.isUserInteractionEnabled = true
                statusView.backgroundColor = .systemRed
            }
        }
        if let tasks = Defaults.shared.get(forKey: .completedTasks) as? [Int], tasks.count != 0{
            saveCompletedTaskTags = tasks
        }

        if saveCompletedTaskTags.count > 0 {
            for taskTag in saveCompletedTaskTags{
                if taskTag == tag{
                    taskStatusBtn.isUserInteractionEnabled = false
                    statusView.backgroundColor = .systemGreen
                }
            }

        }
        if (currentCompletedTask != nil && currentCompletedTask == tag){
            saveCompletedTaskTags.append(tag)
            Defaults.shared.set(value: saveCompletedTaskTags, forKey: .completedTasks)
            for taskTag in saveCompletedTaskTags{
            if taskTag == tag{
                taskStatusBtn.isUserInteractionEnabled = false
                statusView.backgroundColor = .systemGreen
            }
        }
     }
        if subtaskFiles.count  == 0{
            collectionViewHeight.constant = 0
        } else{
            collectionViewHeight.constant = 50
            mediaCollectionView.reloadData()
        }
    }
}

extension ToDoActivityDetailTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isScreenForSubtask{
            return subtaskFiles.count
        }
        return taskFiles.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: TodoMediaCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: TodoMediaCollectionCell.reuseIdentifier, for: indexPath) as? TodoMediaCollectionCell else{
            return UICollectionViewCell()
        }
        if isScreenForSubtask{
            if subtaskFiles.count > 0 {
                cell.setData(data: TodoMedia(url: subtaskFiles[indexPath.item].url, mediaType: subtaskFiles[indexPath.item].mediaType))
            }
        } else{
            if taskFiles.count > 0 {
                cell.setData(data: TodoMedia(url: taskFiles[indexPath.item].url, mediaType: taskFiles[indexPath.item].mediaType))
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isScreenForSubtask{
            showMediaDelegate?.redirectToMediaScreens(url: subtaskFiles[indexPath.item].url ?? "", mediaType: subtaskFiles[indexPath.item].mediaType ?? .video)
        } else{
            showMediaDelegate?.redirectToMediaScreens(url: taskFiles[indexPath.item].url ?? "", mediaType: taskFiles[indexPath.item].mediaType ?? .video)
        }

    }
}

//MARK: UICollectionViewDelegateFlowLayout
extension ToDoActivityDetailTableViewCell: UICollectionViewDelegateFlowLayout{
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
