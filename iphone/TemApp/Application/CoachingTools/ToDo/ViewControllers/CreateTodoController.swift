//
//  CreateTodoController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 26/04/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
import UniformTypeIdentifiers
import MobileCoreServices
import Imaginary

protocol ShowAddItemDelegate{
    func openAddItemScreen(title: String, willAddSubtask: Bool, index: Int)
}
protocol DeleteTaskDelegate{
    func deleteTask(index:Int)
    func deleteSubTask(taskIndex: Int, subtaskIndex: Int)
}
protocol ShowMedia{
    func showMediaSheet(media: ToDoMediaType, taskIndex: Int, subTaskIndex: Int)
    func redirectToMediaScreens( url: String, mediaType: EventMediaType)
}
enum ToDoMediaType: Int,CaseIterable{
    case todo = 0, task, subtask
}

class CreateTodoController: DIBaseController, LoaderProtocol, NSAlertProtocol {

    //MARK: IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addItemButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var addMediaToDoButton: UIButton!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!

    //MARK: Variables
    var toDoItems: TodoItems? // created tasks
    var isItemAdded = false
    var isTaskAdded = false
    var currentTaskName = ""
    var viewModal = CreateTodoModel()
    var memberIds: [String] = []
    var itemTitle = ""
    var isListEditing = false
    var tasks = [ToDoTasks]() //tasks to be edit
    private var mediaItems = [YPMediaItem]()
    private var showDeleteButtonOnCells = false
    var editingTasks = [TodoTasks]() // edited tasks
    var todoId = ""
    private var taskMedia: [TaskMedia] = []
    private var subtaskMedia: [SubTaskMedia] = []
    private var todoMedia: [TodoMedia] = []
    private var mediaType: ToDoMediaType?
    private var taskIndex = 0
    private var subtaskIndex = 0
    let currentMedia = Media()

    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        initializer()
    }

    //MARK: Helper functions
    private func initializer(){
        addMediaToDoButton.isHidden = true
        self.mediaCollectionView.registerNibsForCollectionView(nibNames: [TodoMediaCollectionCell.reuseIdentifier])
        if isListEditing{
            showDeleteButtonOnCells = true
            self.isItemAdded = true
            libraryButton.isHidden = true
            bookmarkButton.isHidden = true
            shareButton.isHidden = true
            addItemButton.setTitle(itemTitle, for: .normal)

            for task in tasks.indices{
                if let sTasks = tasks[task].subTasks{
                    var subTasks = [TodoSubTasks]()
                    for subTask in sTasks.indices{
                        var media: [SubTaskMedia] = []
                        for m in sTasks[subTask].media ?? []{
                            media.append(m)
                        }
                        subTasks.append(TodoSubTasks(name: sTasks[subTask].subtaskName,media: media))
                    }
                    var media: [TaskMedia] = []
                    for m in tasks[task].media ?? []{
                        media.append(m)
                    }
                    editingTasks.append(TodoTasks(name: tasks[task].taskName, details: subTasks,media: media))
                }
            }
        }
        collectionViewHeight.constant = 0
        toDoItems = TodoItems(itemName: itemTitle, itemDetails: editingTasks)
    }
    private func registerCells(){
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 5
        }
        tableView.registerNibs(nibNames: [SubtaskTableCell.reuseIdentifier])
        tableView.registerHeaderFooter(nibNames: [TaskTableHeaderView.reuseIdentifier])
    }
    @objc func addTaskTapped(){
        let addTodoVc: AddTodoDetailsController = UIStoryboard(storyboard: .todo).initVC()
        addTodoVc.headerTitle = "TASK"
        addTodoVc.itemName = { name in
            self.currentTaskName = name
            var todoTasks = self.getTodoTasks()
            todoTasks.append(TodoTasks(name: name, details: []))
            var media: [TodoMedia] = []
            for m in self.toDoItems?.media ?? []{
                media.append(m)
            }
            self.toDoItems = TodoItems(itemName: self.toDoItems?.itemName, itemDetails: todoTasks,media: media)
            self.isTaskAdded = true
            self.isListEditing = false
            self.tableView.reloadData()
        }
        self.present(addTodoVc, animated: true)
    }


    private func createTOdoAPI(addBookmark: Bool){
        if addItemButton.currentTitle != "ADD TO DO ITEM +" {
            self.showHUDLoader()
            let params = getTodoParams()

            viewModal.createTodo(isBookmarkTodo: addBookmark, params: params , completion: { [weak self] in
                self?.hideHUDLoader()
                if let error = self?.viewModal.error{
                    self?.showAlert(withMessage: "\(error.message ?? "")")
                }
                if let msg = self?.viewModal.sucessMsg{
                    self?.showAlert(withTitle: "", message: msg, okayTitle: "OK", okCall: {
                        self?.navigationController?.popViewController(animated: true)
                    }, cancelCall: {
                        // cancel call
                    })
                }
            })
        } else{
            self.showAlert(withMessage: "Please enter Todo name")
        }
    }
    private func editTodoApi(){
        self.showHUDLoader()
        let params = getTodoParams()

        viewModal.editTodo( params: params, todoId: self.todoId , completion: { [weak self] in
            self?.hideHUDLoader()
            if let error = self?.viewModal.error{
                self?.showAlert(withMessage: "\(error.message ?? "")")
            }
            if let msg = self?.viewModal.sucessMsg{
                self?.showAlert(withMessage: msg)
            }
        })
    }

    //MARK: IBAction

    @IBAction func addMediaInToDo(_ sender: UIButton) {
        self.mediaType = .todo
        self.showSelectionModal(array: ["Video", "PDF"], type: .fileType)
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func addButtonTapped(_ sender: UIButton) {
        if showDeleteButtonOnCells{
            editTodoApi()
        } else{
            createTOdoAPI(addBookmark: false)
        }
    }

    @IBAction func shareButtonTapped(_ sender: UIButton) {
        let tematesVc: SelectTematesViewController = UIStoryboard(storyboard: .todo).initVC()
        tematesVc.createToDoVc = self
        self.navigationController?.pushViewController( tematesVc, animated: true)
    }
    @IBAction func addItemTapped(_ sender: UIButton) {
        if addItemButton.currentTitle == "ADD TO DO ITEM +"{
            let addTodoVc: AddTodoDetailsController = UIStoryboard(storyboard: .todo).initVC()
            addTodoVc.headerTitle = addItemButton.currentTitle ?? ""
            // to do item name
            addTodoVc.itemName = { name in
                self.toDoItems = TodoItems(itemName: name, itemDetails: [])
                self.isItemAdded = true
                self.addItemButton.setTitle(name, for: .normal)
                self.addMediaToDoButton.isHidden = false
                self.tableView.reloadData()
            }
            self.present(addTodoVc, animated: true)
        }
    }
    @IBAction func bookmarkTapped(_ sender: UIButton) {
        createTOdoAPI(addBookmark: true)
    }
    @IBAction func libraryTapped(_ sender: UIButton) {
        let libaryVC: TodoLibraryController = UIStoryboard(storyboard: .todo).initVC()
        self.navigationController?.pushViewController(libaryVC, animated: true)
    }
    override func handleSelection(index: Int, type: SheetDataType) {
        if type == .fileType{
            if index == 0{ // video
                self.showYPPhotoGallery(showCrop: false, isFromFoodTrek: false, showOnlyVideo: true)
            } else if index == 1{ // pdf
                getPDf()
            }
        }
    }
    func getPDf(){
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypePDF as String], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        //       documentPicker.modalPresentationStyle = .fullScreen
        present(documentPicker, animated: true, completion: nil)

    }
    private func getTodoParams() -> [String:Any?]{
        var taskParamList: [[String : Any]] = []
        if let tasks = toDoItems?.itemDetails{

            for taskIndex in tasks.indices {
                var subtaskParamList: [[String : Any]] = []
                if let subtasks = toDoItems?.itemDetails?[taskIndex].details{
                    for stask in subtasks {
                        var subTaskMediaList: [[String : Any]] = []
                        for m in stask.media ?? []{
                            let dict: [String: Any] = ["subtaskfile":m.url ?? "",
                                                       "mediaType":m.mediaType?.rawValue]
                            subTaskMediaList.append(dict)
                        }
                        let dict: [String: Any] = ["subtask_name":stask.name ?? "",
                                                   "subtaskmedia":subTaskMediaList]
                        subtaskParamList.append(dict)
                    }
                }
                var taskMediaList: [[String : Any]] = []
                for m in tasks[taskIndex].media ?? []{
                    let dict: [String: Any] = ["taskfile":m.url ?? "",
                                               "mediaType":m.mediaType?.rawValue]
                    taskMediaList.append(dict)
                }

                var dict: [String: Any] = ["task_name":tasks[taskIndex].name ?? ""]
                dict["subtasks"] = subtaskParamList
                dict["taskmedia"] = taskMediaList

                taskParamList.append(dict)
            }
        }
        var todoMediaList: [[String : Any]] = []
        for m in toDoItems?.media ?? []{
            let dict: [String: Any] = ["titlefile":m.url ?? "",
                                       "mediaType":m.mediaType?.rawValue]
            todoMediaList.append(dict)
        }

        var params: [String : Any?]
        if showDeleteButtonOnCells{
            params = ["title": toDoItems?.itemName ?? "",
                      "tasks": taskParamList ]
        }else{
            params = [ "members": memberIds,
                       "title": toDoItems?.itemName ?? "",
                       "tasks": taskParamList,
                       "titlemedia": todoMediaList]
        }
        return params
    }
    override func handleAfterMediaSelection(withMedia items: [YPMediaItem], isPresentingFromCreatePost: Bool, isFromFoodTrek:Bool = false) {
        guard isConnectedToNetwork() else {
            return
        }
        self.picker?.dismiss(animated: true, completion: nil)
        mediaItems = items
        initializeNewPostWithYPMedia()

    }
    //pass the media items array picked from gallery
    func initializeNewPostWithYPMedia() {
        self.iterateMediaItems()
    }

    private func iterateMediaItems() {
        for mediaItem in self.mediaItems {
            switch mediaItem {
            case .photo(let photo):
                break
            case .video(let video):
                do {
                    currentMedia.data = try Data(contentsOf: video.url)
                    currentMedia.ext = MediaType.video.mediaExt
                    currentMedia.type = MediaType.video
                    currentMedia.image = video.thumbnail
                    currentMedia.mimeType = "video/mp4"
                    uploadMediaToFireBase() { (error) in
                        // do nothing ?
                    }
                } catch (let error) {
                    print(error.localizedDescription)

                }
            }
        }
    }
    private func mediaSizeValidated() -> Bool {
        if let data = currentMedia.data,
           data.count >= AWSBucketFileSizeLimit {
            return false
        }
        return true
    }
    func uploadMediaToFireBase(failure: @escaping (DIError) -> ()) {
        showLoader()
        let media = currentMedia

        guard mediaSizeValidated() else {
            self.showAlert(message: "Some files are too large to share. Please, select other files.")
            return
        }
        guard let data = media.data else { return }

        let filepath = "UserID101" + "media" + Utility.shared.getFileNameWithDate()
        DispatchQueue.main.async {
            AWSBucketMangaer.bucketInstance.uploadFile(data: data, mediaObj: media, mimeType: media.mimeType ?? "", key: "file", fileName: filepath) { (callback, firebaseUrl, error, mediaObjFromFirebase) in
                if let url = firebaseUrl {
                    self.hideLoader()
                    self.updateMediaItems(url: url, mediaType: .video)
                }
                else {
                    self.hideLoader()
                    DILog.print(items: "Error Occured \(error)")
                    failure(error)
                }
            }
        }
    }
    func uploadPdfToFireBase(data: Data, failure: @escaping (DIError) -> ()) {
        showLoader()
        let media = Media()
        media.data =  data
        media.mimeType = "application/pdf"
        guard let data = media.data else { return }
        let filepath = "UserID101" + "media" + Utility.shared.getFileNameWithDate()
        DispatchQueue.main.async {
            AWSBucketMangaer.bucketInstance.uploadFile(data: data, mediaObj: media, mimeType: media.mimeType ?? "", key: "file", fileName: filepath) { (callback, firebaseUrl, error, mediaObjFromFirebase) in
                if let url = firebaseUrl {
                    self.hideLoader()
                    self.updateMediaItems(url: url, mediaType: .pdf)
                }
                else {
                    self.hideLoader()
                    DILog.print(items: "Error Occured \(error)")
                    failure(error)
                }
            }
        }
    }

    private func updateMediaItems(url: String,mediaType: EventMediaType){
        switch self.mediaType{
        case .todo:
            updateTodoItems(url: url, mediaType: mediaType)
        case .task:
            updateTaskItems(url: url, mediaType: mediaType)
        case .subtask:
            updateSubtaskItems(url: url, mediaType: mediaType)
        case .none:
            break
        }
        self.tableView.reloadData()
    }

    func updateTodoItems(url: String,mediaType: EventMediaType){
        var todoTasks : [TodoTasks] = []
        if let tasks = self.toDoItems?.itemDetails{
            for task in tasks{
                todoTasks.append(task)
            }
        }
        var media: [TodoMedia] = []
        if toDoItems?.media?.count ?? 0 > 0{
            for m in toDoItems?.media ?? []{
                media.append(m)
            }
        }
        media.append(TodoMedia(url: url, mediaType: mediaType))
        self.todoMedia = media
        self.toDoItems = TodoItems(itemName: addItemButton.currentTitle, itemDetails: todoTasks, media: todoMedia)
        self.collectionViewHeight.constant = 50
        self.mediaCollectionView.reloadData()
    }

    func updateTaskItems(url: String,mediaType: EventMediaType){
        var todoSubTasks : [TodoSubTasks] = []
        if let tasks = self.toDoItems?.itemDetails{
            for st in tasks[taskIndex].details{
                var media: [SubTaskMedia] = []
                if st.media?.count ?? 0 > 0{
                    for m in st.media ?? []{
                        media.append(m)
                    }
                }
                todoSubTasks.append(TodoSubTasks(name:st.name,media: media))
            }
        }
        var todoTasks : [TodoTasks] = []
        if let tasks = self.toDoItems?.itemDetails{
            for task in tasks.indices{
                if task == taskIndex {
                    var media: [TaskMedia] = []
                    if tasks[taskIndex].media?.count ?? 0 > 0{
                        for m in tasks[taskIndex].media ?? []{
                            media.append(m)
                        }
                    }
                    media.append(TaskMedia(url: url, mediaType: mediaType))
                    todoTasks.insert(TodoTasks(name: tasks[task].name, details: todoSubTasks, media: media), at: taskIndex)
                } else{
                    todoTasks.append(tasks[task])
                }
            }
        }
        self.toDoItems = TodoItems(itemName: addItemButton.currentTitle, itemDetails: todoTasks, media: todoMedia)
    }
    func updateSubtaskItems(url: String,mediaType: EventMediaType){
        var todoSubTasks : [TodoSubTasks] = []
        if let tasks = self.toDoItems?.itemDetails{
            for st in tasks[taskIndex].details.indices{
                if subtaskIndex == st{
                    var media: [SubTaskMedia] = []
                    if tasks[taskIndex].details[st].media?.count ?? 0 > 0{
                        for m in tasks[taskIndex].details[subtaskIndex].media ?? []{
                            media.append(m)
                        }
                    }
                    media.append(SubTaskMedia(url: url, mediaType: mediaType))
                    todoSubTasks.insert(TodoSubTasks(name:tasks[taskIndex].details[st].name,media: media), at: subtaskIndex)
                } else{
                    var media: [SubTaskMedia] = []
                    if tasks[taskIndex].details[st].media?.count ?? 0 > 0{
                        for m in tasks[taskIndex].details[st].media ?? []{
                            media.append(m)
                        }
                    }
                    todoSubTasks.append(TodoSubTasks(name:tasks[taskIndex].details[st].name, media: media))
                }
            }
            var todoTasks = getTodoTasks()
            var media: [TaskMedia] = []
            if let tasks = self.toDoItems?.itemDetails{
                for m in tasks[taskIndex].media ?? []{
                    media.append(m)
                }
            }
            var todoMedia: [TodoMedia] = []
            for m in self.toDoItems?.media ?? []{
                todoMedia.append(m)
            }
            todoTasks[taskIndex] = TodoTasks(name: todoTasks[taskIndex].name, details: todoSubTasks,media: media)
            self.toDoItems = TodoItems(itemName: self.toDoItems?.itemName, itemDetails: todoTasks,media: todoMedia)
        }
    }

    func getTodoTasks() -> [TodoTasks]{
        var todoTasks : [TodoTasks] = []
        if let tasks = self.toDoItems?.itemDetails{
            for task in tasks{
                todoTasks.append(task)
            }
        }
        return todoTasks
    }

}

//MARK: UITableViewDataSource, UITableViewDelegate
extension CreateTodoController: UITableViewDataSource, UITableViewDelegate{

    func numberOfSections(in tableView: UITableView) -> Int {
        if isItemAdded{
            if isListEditing && self.toDoItems?.itemDetails?.count ?? 0 != 0 {
                return tasks.count
            } else if isTaskAdded{
                return self.toDoItems?.itemDetails?.count ?? 0
            }
            return 1
        }
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isListEditing {
            isTaskAdded = true
            return  tasks[section].subTasks?.count ?? 0
        }else if isTaskAdded{
            return self.toDoItems?.itemDetails?[section].details.count ?? 0
        }
        return 0
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isTaskAdded{
            guard let subtaskCell: SubtaskTableCell = tableView.dequeueReusableCell(withIdentifier: SubtaskTableCell.reuseIdentifier) as? SubtaskTableCell else { return UITableViewCell()}

            if showDeleteButtonOnCells {
                subtaskCell.deleteButton.isHidden = false
            } else{
                subtaskCell.deleteButton.isHidden = true
            }
            subtaskCell.addMediaButton.tag = indexPath.row
            subtaskCell.showMediaDelegate = self
            subtaskCell.taskIndex = indexPath.section
            subtaskCell.deleteTaskDelegate = self
            subtaskCell.deleteButton.tag = indexPath.row
            if let subTask = self.toDoItems?.itemDetails?[indexPath.section].details[indexPath.row]{
                subtaskCell.listOfFiles = subTask.media ?? []
                subtaskCell.configureView(subTaskName: subTask.name ?? "")
                subtaskCell.mediaCollectionView.reloadData()
            }
            return subtaskCell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let  headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TaskTableHeaderView.reuseIdentifier) as? TaskTableHeaderView else{
            return UITableViewHeaderFooterView()
        }
        headerView.addMediaButton.tag = section
        headerView.deleteTaskDelegate = self
        headerView.subtaskButton.tag = section
        headerView.contentView.backgroundColor = .black
        headerView.showAddItemDelegate = self

        if showDeleteButtonOnCells {
            headerView.deleteButton.isHidden = false
        } else{
            headerView.deleteButton.isHidden = true
        }
        headerView.showMediaDelegate = self
        headerView.deleteButton.tag = section
        if let task = self.toDoItems?.itemDetails?[section]{
            headerView.listOfFiles = task.media ?? []
            headerView.configureView(taskName: task.name ?? "")
        }
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isTaskAdded{
            return UITableView.automaticDimension
        }
        else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 30))
        let button = UIButton()
        button.frame = CGRect.init(x: 25, y: 0, width: 100, height: footerView.frame.height)
        button.setTitle("ADD TASK +", for: .normal)
        button.titleLabel?.textAlignment = .right
        button.titleLabel?.font = UIFont(name:UIFont.avenirNextMedium, size: 16.0) ?? UIFont()
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(addTaskTapped), for: .touchUpInside)
        footerView.addSubview(button)
        footerView.backgroundColor = .black
        return footerView
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 && toDoItems?.itemDetails?.count == 0{
            return 30
        }else if toDoItems?.itemDetails?.count == section + 1 {
            return 30
        } else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .clear
        view.backgroundColor = .clear
    }
    
}


//MARK: Delegate to show the popup for entering to-do items
extension CreateTodoController: ShowAddItemDelegate{
    func openAddItemScreen(title: String, willAddSubtask: Bool,index: Int) {
        let addTodoVc: AddTodoDetailsController = UIStoryboard(storyboard: .todo).initVC()
        addTodoVc.headerTitle = title
        var todoMEdia: [TodoMedia] = []
        addTodoVc.itemName = { name in
            var todoTasks = self.getTodoTasks()
            for m in self.toDoItems?.media ?? []{
                todoMEdia.append(m)
            }
            var media: [TaskMedia] = []
            var stMedia: [SubTaskMedia] = []
            var todoSubTasks : [TodoSubTasks] = []
            if let tasks = self.toDoItems?.itemDetails{
                for st in tasks[index].details{
                    for m in st.media ?? []{
                        stMedia.append(m)
                    }
                    todoSubTasks.append(TodoSubTasks(name:st.name, media: stMedia))
                }
                for m in tasks[index].media ?? []{
                    media.append(m)
                }
            }
            if self.toDoItems?.itemDetails?.count != index{
                self.currentTaskName = todoTasks[index].name ?? "" //to keep the backup of already added task name
            }
            todoSubTasks.append(TodoSubTasks(name: name))
            todoTasks[index] = TodoTasks(name: self.currentTaskName, details: todoSubTasks,media: media)
            self.toDoItems = TodoItems(itemName: self.toDoItems?.itemName, itemDetails: todoTasks,media: todoMEdia)
            self.isListEditing = false // to show the new data
            self.tableView.reloadData()
        }
        self.present(addTodoVc, animated: true)
    }


}

extension CreateTodoController: DeleteTaskDelegate{
    func deleteSubTask(taskIndex: Int, subtaskIndex: Int) {
        isListEditing = false
        self.toDoItems?.itemDetails?[taskIndex].details.remove(at: subtaskIndex)
        self.tableView.reloadData()
    }

    func deleteTask(index: Int) {
        self.toDoItems?.itemDetails?.remove(at: index)
        isListEditing = false
        if toDoItems?.itemDetails?.count == 0{
            self.isTaskAdded = false
        }
        self.tableView.reloadData()
    }
}

//MARK: UICollectionViewDelegate, UICollectionViewDataSource
extension CreateTodoController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return todoMedia.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: TodoMediaCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: TodoMediaCollectionCell.reuseIdentifier, for: indexPath) as? TodoMediaCollectionCell else{
            return UICollectionViewCell()
        }
        cell.setData(data: todoMedia[indexPath.item])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if let mediaType = todoMedia[indexPath.item].mediaType{
            switch EventMediaType(rawValue: mediaType.rawValue){
            case .video:
                let episodeVideoVC: EpisodeVideoViewController = UIStoryboard(storyboard: .temTv).initVC()
                episodeVideoVC.url = todoMedia[indexPath.item].url ?? ""
                self.navigationController?.pushViewController(episodeVideoVC, animated: false)
            case .pdf:
                let selectedVC:AffilativePDFView = UIStoryboard(storyboard: .affilativeContentBranch).initVC()
                selectedVC.urlString = todoMedia[indexPath.item].url ?? ""

                self.navigationController?.pushViewController(selectedVC, animated: true)
            default:
                break
            }
        }

    }

}
//MARK: UIDocumentPickerDelegate
extension CreateTodoController: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        do {
            var documentData = Data()
            for url in urls {
                documentData = try Data(contentsOf: url)
            }
            uploadPdfToFireBase(data: documentData, failure: { error in
                print(error.message ?? "error in uploading")
            })
        } catch {
            print("no pdf found")
        }
    }

    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
}

//MARK: UICollectionViewDelegateFlowLayout
extension CreateTodoController: UICollectionViewDelegateFlowLayout{
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

extension CreateTodoController: ShowMedia{
    func redirectToMediaScreens(url: String, mediaType: EventMediaType) {
        switch EventMediaType(rawValue: mediaType.rawValue){
        case .video:
            let episodeVideoVC: EpisodeVideoViewController = UIStoryboard(storyboard: .temTv).initVC()
            episodeVideoVC.url = url
            self.navigationController?.pushViewController(episodeVideoVC, animated: false)
        case .pdf:
            let selectedVC:AffilativePDFView = UIStoryboard(storyboard: .affilativeContentBranch).initVC()
            selectedVC.urlString = url

            self.navigationController?.pushViewController(selectedVC, animated: true)
        default:
            break
        }
    }
    func showMediaSheet(media: ToDoMediaType, taskIndex: Int, subTaskIndex: Int) {
        self.mediaType = media
        self.taskIndex = taskIndex
        self.subtaskIndex = subTaskIndex
        self.showSelectionModal(array: ["Video", "PDF"], type: .fileType)
    }
}
