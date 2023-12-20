//
//  SearchViewController.swift
//  TemApp
//
//  Created by Harpreet_kaur on 23/07/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import SSNeumorphicView

protocol GlobalSearchControllerDelegate: AnyObject {
    func parentControllerSearchTextDidChange(searchText: String)
}

class SearchViewController : DIBaseController, SearchViewControllerProtocol {
    // MARK: Variables.
    var postCommentFullScreenVC: PostCommentAddTagContainerViewController?
    private var refresh: UIRefreshControl!
    var actionSheet = CustomBottomSheet()
    var collectionOffsets: [Int: CGPoint] = [:]
    
    private var mode: SearchMode = .preview
    private var selection: SearchSelection = .all
    private var search: GlobalSearch = GlobalSearch()
    private var categorySearch: CategorySearch?
    
    var keyboardSize: CGFloat = 0
    var activeTextView: UITextView?
    var tagUsersListController: TagUsersListViewController?
    
    var minVideoPlaySize: CGFloat = 125.0
    var player : VGPlayer!
    //Will keep track of the index paths of currently playing player view
    var currentPlayerIndex: (tableIndexPath: IndexPath?, collectionIndexPath: IndexPath?)?
    //will keep track of the index paths of last played player view
    var previousPlayerIndex: (tableIndexPath: IndexPath?, collectionIndexPath: IndexPath?)?
    //will keep track of the last url being played in the player view
    private var lastPlayingMediaUrl: String?
    //timer to show the remaining time for an activity
    var timer: Timer?
    
    // MARK: IBOutlets.
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var categorySelectionContainer: SSNeumorphicView!
    @IBOutlet weak var categorySelection: CustomTextField!
    @IBOutlet weak var categorySearchHeaderContainer: UIStackView!
    @IBOutlet weak var categorySearchHeader: UILabel!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var tagListContainerView: UIView!
    //    @IBOutlet weak var tagListBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tematesView: SSNeumorphicView!
    @IBOutlet weak var postsView: SSNeumorphicView!
    @IBOutlet weak var temsView: SSNeumorphicView!
    @IBOutlet weak var goalsView: SSNeumorphicView!
    @IBOutlet weak var eventsView: SSNeumorphicView!
    @IBOutlet weak var challengesView: SSNeumorphicView!

    @IBOutlet weak var searchShadowView: SSNeumorphicView!{
        didSet{
            setShadow(view: searchShadowView)
        }
    }


    @IBOutlet var categoryheaderViews: [SSNeumorphicView]!
    {
        didSet{
            for view in categoryheaderViews{
                view.layer.name = "darkShadowLayer"
                view.viewDepthType = .innerShadow
                view.viewNeumorphicCornerRadius = view.frame.width/2
                if view.tag == 0{
                    configureView(isSelected: true, views: [view])
                } else{
                    configureView(isSelected: false, views: [view])
                }
            }
        }
    }

    @IBOutlet var categoryLabels: [UILabel]!
    private var filter: String? { searchField.text }
    private let minimumSearchTextLength = 3
    private let previewLimit = 3
    private let searchCategoryLimit = 10
    
    // MARK: -ViewLifeCycle.
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults().setValue(Constant.ScreenSize.SCREEN_WIDTH, forKey: "Height")
        DispatchQueue.main.async {
            self.initUI()
        }
        self.setUpTagListContainer()
        searchBar.delegate = self
    ///    categorySelection.delegate = self
        table.dataSource = self
        table.delegate = self
        refresh = UIRefreshControl()
        refresh.tintColor = appThemeColor
        refresh?.addTarget(self, action: #selector(onPullToRefresh(sender:)) , for: .valueChanged)
        table.refreshControl = refresh
        table.registerNibs(nibNames: [
            EmptySearchResult.reuseIdentifier,
            SearchCategoryHeader.reuseIdentifier,
            UserListTableViewCell.reuseIdentifier,
            OpenGoalDashboardCell.reuseIdentifier,
            OpenChallengeDashboardCell.reuseIdentifier,
            SearchCategoryFooter.reuseIdentifier,
            ChatListTableViewCell.reuseIdentifier,
            PostTableCell.reuseIdentifier,
            EventSearchCell.reuseIdentifier,
        ])
    }
    func setShadow(view: SSNeumorphicView){
        view.viewDepthType = .innerShadow
        view.viewNeumorphicCornerRadius = view.frame.width/2
        view.viewNeumorphicMainColor = UIColor.blakishGray.cgColor

        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardNotificationObservers()
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
        self.navigationController?.setDefaultNavigationBar()
        let leftBarButtonItem = UIBarButtonItem(customView: getBackButton())
        //self.setNavigationController(titleName: Constant.ScreenFrom.search.title, leftBarButton: [leftBarButtonItem], rightBarButtom: nil, backGroundColor: UIColor.white, translucent: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.playVideo()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removePlayer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardNotificationObservers()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        //self.removeVolumeListeners()
        self.view.endEditing(true)
    }
    
    // MARK: Helper Function
    func initUI(){
        searchField.delegate = self
        if #available(iOS 13.0, *) {
            self.searchBar.searchTextField.backgroundColor = .clear
        } else {
            // Fallback on earlier versions
            
        }
        for view in categoryheaderViews{
            if view.tag == 0{
                configureView(isSelected: true, views: [view])
            } else{
                configureView(isSelected: false, views: [view])
            }
        }
        searchBar.cornerRadius = 10
        searchBar.backgroundColor = .clear
    //    categorySelectionContainer.isHidden = false
//        searchBar.textField?.backgroundColor = .white
        categorySearchHeaderContainer.isHidden = true
        selectCategory(.all)

    }

    func configureView(isSelected: Bool, views: [SSNeumorphicView]){
        if isSelected{
            for view in views{

                for label in categoryLabels{
                    if label.tag == view.tag{
                        label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                    }
                }

                let sublayers: [CALayer]? = view.layer.sublayers
                if let layeers = sublayers{
                    for layer in  layeers{
                        if layer.name == "darkShadowLayer" {
                            layer.removeFromSuperlayer()
                        }
                    }
                }
                    view.backgroundColor = #colorLiteral(red: 0.01568627451, green: 0.9137254902, blue: 0.8901960784, alpha: 1)
                    view.viewNeumorphicMainColor = #colorLiteral(red: 0.01568627451, green: 0.9137254902, blue: 0.8901960784, alpha: 1).cgColor
                    view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.1).cgColor
                    view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
            }
        }else{
            for view in views{

                for label in categoryLabels{
                    if label.tag == view.tag{
                        label.textColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    }
                }

                let sublayers: [CALayer]? = view.layer.sublayers
                if let layeers = sublayers{
                    for layer in  layeers{
                        if layer.name == "darkShadowLayer" {
                            layer.removeFromSuperlayer()
                        }
                    }
                }
                view.backgroundColor = #colorLiteral(red: 0.2431372702, green: 0.2431372702, blue: 0.2431372702, alpha: 1)
                view.viewNeumorphicMainColor = UIColor.blakishGray.cgColor
                view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.1).cgColor
                view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
            }

        }

    }
    
    override func handleSelection(index: Int, type: SheetDataType) {
        if type == .searchCategory {
    ///        categorySelection.changeViewFor(selectedState: false)
            selectCategory(SearchSelection.allCases[index])
        }
    }
    
    private func selectCategory(_ selection: SearchSelection) {
        self.selection = selection
///        self.categorySelection.text = selection.title
        reload()
    }
    
    override func cancelSelection(type: SheetDataType) {
        if type == .searchCategory {
      ///      categorySelection.changeViewFor(selectedState: false)
        }
    }
    
    @objc func onPullToRefresh(sender: UIRefreshControl) {
        reload()
    }
    
    private func reload(scrollToTop: Bool = true) {
        func reloadTable() {
            refresh.endRefreshing()
            table.reloadData()
            if (scrollToTop) {
                table.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
        func handleError(_ error: DIError) {
            self.refresh.endRefreshing()
            self.showAlert(withError: error)
        }
        
        guard let filter = filter else {
            reloadTable()
            return
        }
        if filter.length < minimumSearchTextLength {
            if mode == .preview {
                search.clearPreview()
            } else if mode == .allInCategory, let search = categorySearch {
                search.clear()
            }
            reloadTable()
            return
        }
        
        if mode == .preview {
            search.loadPreview(selection.request, filter: filter, limit: previewLimit, success: reloadTable, failure: handleError)
        } else if mode == .allInCategory, let search = categorySearch {
            search.resetAndLoad(filter: filter, limit: searchCategoryLimit, success: reloadTable, failure: handleError)
        }
    }


   
    @IBAction func allCategoriesButtonsTapped(_ sender: UIButton) {
        if sender.tag == 0{
            selectCategory(SearchSelection.allCases[0])
        }

        for view in categoryheaderViews{
            if view.tag == sender.tag {
                configureView(isSelected: true, views: [view])
            } else{
                configureView(isSelected: false, views: [view])
            }

        }
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func switchToPreviewSearch(_ sender: Any) {
        switchToPreviewSearch()
    }
    
    @IBAction func showAllTapped(_ sender: UIButton) {
        selectCategory(SearchSelection.allCases[0])
    }

    func switchToPreviewSearch() {
        mode = .preview
        categorySearchHeaderContainer.hideView()
     ///   categorySelectionContainer.showView()
        reload()
    }
    
    func switchToCategorySearch(search: CategorySearch) {
        mode = .allInCategory
        categorySearch = search
        categorySearchHeader.text = search.description
  ///      categorySelectionContainer.hideView()
        categorySearchHeaderContainer.showView()
        reload()
    }
    
    private func setUpTagListContainer() {
        self.tagListContainerView.isHidden = true
    }
    
    // MARK: Keyboard observers
    override func keyboardDisplayedWithHeight(value: CGRect) {
        self.keyboardSize = value.height
    }
    
    override func keyboardHide(height: CGFloat) {
        self.tagListContainerView.isHidden = true
    }
    
    /// method to initialize timer
    func createTimer() {
        if timer == nil {
            print("timer created")
            let timer = Timer(timeInterval: 1.0, target: self, selector: #selector(tickTimer), userInfo: nil, repeats: true)
            RunLoop.current.add(timer, forMode: .common)
            timer.tolerance = 0.1
            self.timer = timer
        }
    }
    
    /// invalidates the timer
    private func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /// called each time the timer is triggered
    @objc func tickTimer() {
        guard let visibleRowsIndexPaths = table.indexPathsForVisibleRows else {
            return
        }
        for indexPath in visibleRowsIndexPaths {
            if let cell = table.cellForRow(at: indexPath) as? OpenGoalDashboardCell {
                cell.updateRemainingTimeForActivity()
            } else if let cell = table.cellForRow(at: indexPath) as? OpenChallengeDashboardCell {
                cell.updateRemainingTimeForActivity()
            }
        }
    }
    
    override func fullScreenPreviewDidDismiss() {
        self.playVideo()
    }
    
    @available(*, deprecated, message: "Do not use posts directly, render cells properly instead")
    func getPreviewPost(_ index: IndexPath) -> Post? {
        // Do not use posts directly, render cells properly instead
        // Post is the second group of search. People is the first.
        let count = search.people.previewCellsCount()
        var post: Post?
        let index = index.row - count
        if index >= 0 {
            _ = search.posts.tryGetPreviewItem(index, &post)
        }
        return post
    }
    
    @available(*, deprecated, message: "Do not use temate items directly, render cells properly instead")
    func getPreviewTemate(_ index: IndexPath) -> Friends? {
        // Temates is the first first group of search.
        var temate: Friends?
        _ = search.people.tryGetPreviewItem(index.row, &temate)
        return temate
    }
    
    override func setData(selectedData:ReportData,indexPath:IndexPath) {
        let index = indexPath.row
        if let desc = selectedData.desc , desc == 1 {
            addReportMessageView(index: index)
            return
        }
        reportPost(description:selectedData.title ?? "", id: selectedData.id ?? "", indexPath: indexPath)
    }
    
    func reportPost(description:String,id:String,indexPath:IndexPath) {
        if let post = getPreviewPost(indexPath) {
            var obj = ReportPost()
            obj.id = id
            obj.description = description
            obj.postId = post.id ?? ""
            self.showLoader()
            PostManager.shared.reportPost(parameters: obj.getDictionary(), success: { (message) in
                self.dotsButtonAction(indexPath:indexPath, type: .report)
            }) { (error) in
                self.hideLoader()
                self.showAlert(message:error.message)
            }
        }
    }
    
    // MARK: Auto play - pause helpers
    func playVideo() {
        self.currentPlayerIndex = nil
        self.previousPlayerIndex = nil
        self.pausePlayVideo()
    }
    
    /// call this function to handle the play and pause video for the visible table view cell
    func pausePlayVideo() {
        let visisbleCells = table.visibleCells
        var mediaCollectionCell: GridCollectionCell?
        var maxHeight: CGFloat = 0.0
        //iterate through the table visible cells and get the maximum height visible
        for cellView in visisbleCells {
            if let containerCell = cellView as? PostTableCell,
               let indexPathOfFeedCell = table.indexPath(for: containerCell) {
                let currentIndexOfCollection = Int(containerCell.mediaCollectionView.contentOffset.x / containerCell.mediaCollectionView.frame.width)
                let indexPathOfMediaCell = IndexPath(item: currentIndexOfCollection, section: 0)
                print("index of current viisible item -------> \(indexPathOfMediaCell.item)")
                guard let collectionCell = containerCell.mediaCollectionView.cellForItem(at: indexPathOfMediaCell) as? GridCollectionCell,
                      let post = getPreviewPost(indexPathOfFeedCell),
                      let media = post.media,
                      indexPathOfMediaCell.item < media.count,
                      post.media?[indexPathOfMediaCell.item].type! == .video,
                      let _ = post.media?[indexPathOfMediaCell.item].url else {
                    continue
                }
                let height = containerCell.visibleVideoHeight()
                print("visible video view height of row: \(indexPathOfFeedCell.row)*********** \(height)")
                if maxHeight < height {
                    maxHeight = height
                    currentPlayerIndex = (indexPathOfFeedCell, indexPathOfMediaCell)
                    mediaCollectionCell = collectionCell
                }
            }
        }
        if maxHeight <= minVideoPlaySize {
            self.removePlayer()
            self.previousPlayerIndex = nil
            self.currentPlayerIndex = nil
        }
        guard let tableIndexPath = currentPlayerIndex?.tableIndexPath,
              let collectionIndexPath = currentPlayerIndex?.collectionIndexPath,
              let post = getPreviewPost(tableIndexPath),
              post.media?[collectionIndexPath.row].type! == .video else {
            return
        }
        if let post = getPreviewPost(tableIndexPath) {
            //if maxheight is greater than minimum play size, play the video for this cell
            if maxHeight > minVideoPlaySize {
                if let lastTableIndex = previousPlayerIndex?.tableIndexPath,
                   let lastCollectionIndex = previousPlayerIndex?.collectionIndexPath {
                    if (lastTableIndex == tableIndexPath) && (collectionIndexPath == lastCollectionIndex) {
                        let currentPlayingMediaUrl = post.media?[collectionIndexPath.item].url ?? ""
                        //if current index media url is equal to the last playing then return else, add player with the new media url
                        if currentPlayingMediaUrl == lastPlayingMediaUrl {
                            //already playing video at this index
                            return
                        }
                    }
                }
                if let mediaCollectionCell = mediaCollectionCell {
                    self.addPlayer(cell: mediaCollectionCell, collectionIndexPath: collectionIndexPath, tableIndexPath: tableIndexPath)
                    self.lastPlayingMediaUrl = post.media?[collectionIndexPath.item].url ?? ""
                    previousPlayerIndex = (tableIndexPath, collectionIndexPath)
                }
            }
        }
    }
    
    // MARK: VGPLayer Video player helpers
    ///initialize the VGPLayer and set current controller as its delegate
    func configurePlayer(view: UIView) {
        self.player = VGPlayer(parentViewFrame: view.frame)//VGPlayer()
        self.player.delegate = self
        self.player.displayView.delegate = self
    }
    
    /// add VGPlayer to the view passed as the cell
    func addPlayer(cell: GridCollectionCell, collectionIndexPath: IndexPath, tableIndexPath: IndexPath) {
        guard let post = getPreviewPost(tableIndexPath),
              let url = post.media?[collectionIndexPath.item].url else {
            return
        }
        self.removePlayer()
        //        self.configurePlayer()
        self.configurePlayer(view: cell.videoView)
        self.player.addTo(view: cell.videoView, url: url, previewUrl: post.media?[collectionIndexPath.item].previewImageUrl)
        self.player.displayView.section = tableIndexPath.row
        self.player.displayView.row = collectionIndexPath.item
        self.player.displayView.indexPath = tableIndexPath
        updatePlayerSoundStatus()
    }
    
    func updatePlayerSoundStatus() {
        if let muteStatus = Defaults.shared.get(forKey: .muteStatus) as? Bool {
            if self.player != nil {
                self.player.setSound(toValue: muteStatus)
            }
        }
    }
    
    /// remove the current player added to self
    func removePlayer() {
        if self.player != nil {
            self.player.remove()
            self.player = nil
            print("player removed")
        }
    }
    
    // MARK: Segue Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPostCommentFullView",
           let destination = segue.destination as? PostCommentAddTagContainerViewController {
            self.postCommentFullScreenVC = destination
            destination.delegate = self
        }
    }
}

// MARK: PostCommentAddTagContainerViewController
extension SearchViewController: PostCommentAddTagDelegate {
    func resetTableOffsetToBottom(indexPath: IndexPath) {
    }
    
    func updateCommentOnPost(indexPath: IndexPath, isDecrease: Bool, commentInfo: Comments) {
        self.UserActions(indexPath: indexPath, isDecrease: isDecrease, action: .comment, actionInformation: commentInfo)
    }
    
    func hideCommentView() {
        self.tagListContainerView.isHidden = true
    }
}

// MARK: ActivityInformationTableCellDelegate
//extension SearchViewController: ActivityInformationTableCellDelegate {
//    func didClickOnJoinActivity(sender: UIButton) {
////        self.presenter?.joinActivity(index: sender.tag)
//    }
//}
//For Join Goal......
//extension SearchViewController: JoinGoal {
//    func showAlertMsg(message: String) {
//        self.showAlert(withTitle: AppMessages.AlertTitles.Alert, message: message)
//    }
//}//Extension....

// MARK: - Table delegates
extension SearchViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reload()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}

extension SearchViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        reload()
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let textField = textField as? CustomTextField {
            textField.changeViewFor(selectedState: true)
        }
//        if textField == categorySelection {
//            self.showSelectionModal(array: SearchSelection.allCases, type: .searchCategory)
//            return false
//        } else {
            return true
    //    }
    }
}

extension SearchViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        // Headers for categories and deep-nested subcategories
        // are rendered as regular rows, thus there would be
        // a single section in the table.
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var result = 0
        if mode == .preview {
            if search.isPreviewEmpty {
                result = 1
            } else {
                result = search.previewCellsCount()
            }
        } else if mode == .allInCategory, let search = categorySearch {
            if search.isEmpty {
                result = 1
            } else {
                result = search.cellsCount()
            }
        }
        return result
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if mode == .preview {
            if search.isPreviewEmpty {
                return createEmptyResultCell(table, indexPath, selection.emptyMessage)
            }
            var acquiredCell: UITableViewCell?
            if !search.tryAcquirePreviewCell(self, table, indexPath, &acquiredCell) || acquiredCell == nil {
                cell = createStubCell(indexPath)
            } else {
                cell = acquiredCell!
            }
        }
        else if mode == .allInCategory {
            guard let search = categorySearch else {
                return createEmptyResultCell(table, indexPath, "No search category selected")
            }
            if search.isEmpty {
                return createEmptyResultCell(table, indexPath, search.emptyMessage)
            }
            var acquiredCell: UITableViewCell?
            if !search.tryAcquireCell(self, table, indexPath, &acquiredCell) || acquiredCell == nil {
                cell = createStubCell(indexPath)
            } else {
                cell = acquiredCell!
            }
        }
        else {
            cell = createStubCell(indexPath)
        }
        return cell
    }
    
    private func createEmptyResultCell(_ tableView: UITableView, _ indexPath: IndexPath, _ text: String) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EmptySearchResult.reuseIdentifier, for: indexPath) as! EmptySearchResult
        cell.message.text = self.selection.emptyMessage
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
    }
    
    private func createStubCell(_ indexPath: IndexPath) -> UITableViewCell {
        print("Search table: unable to create cell for index \(indexPath.row)")
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}

extension SearchViewController : UITableViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == table {
            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
                if mode == .allInCategory,
                   let search = categorySearch {
                    search.loadNextPage {
                        self.table.reloadData()
                    } failure: { (error) in
                        self.refresh.endRefreshing()
                        self.showAlert(withError: error)
                    }
                }
            }
        }
    }
}

// MARK: - Other delegates -

// MARK: ViewPostDetailDelegate
extension SearchViewController: ViewPostDetailDelegate {
    func redirectToPostDetail(indexPath: IndexPath) {
        guard let item = getPreviewPost(indexPath) else {
            return
        }
        let controller : PostDetailController = UIStoryboard(storyboard: .profile).initVC()
        controller.post = item
        controller.indexPath = indexPath
        controller.user = item.user
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension SearchViewController : PostDetailDotsDelegate {
    func dotsButtonAction(indexPath: IndexPath, type: UserActions) {
        guard let post = getPreviewPost(indexPath) else {
            return
        }
        self.hideLoader()
        switch type {
        case .delete, .report:
            search.posts.byPeople.removeFromPreview { (item) -> Bool in item.id == post.id }
            search.posts.byCaption.removeFromPreview { (item) -> Bool in item.id == post.id }
            search.posts.byTags.removeFromPreview { (item) -> Bool in item.id == post.id }
            self.table.reloadData()
        case .unfriend:
            search.posts.byPeople.preview.first { (item) -> Bool in item.id == post.id }?.user?.friendStatus = .other
            search.posts.byCaption.preview.first { (item) -> Bool in item.id == post.id }?.user?.friendStatus = .other
            search.posts.byTags.preview.first { (item) -> Bool in item.id == post.id }?.user?.friendStatus = .other
            self.table.reloadData()
        default:
            break
        }
    }
}

extension SearchViewController : PostTableCellDelegate, URLTappableProtocol {
    func didTapOnUrl(url: URL) {
        self.pushToSafariVCOnUrlTap(url: url)
    }
    
    
    func didBeginEdit(textView: UITextView) {
        self.activeTextView = textView
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.table.scrollWithKeyboard(keyboardHeight: self.keyboardSize, inputView: textView)
            var safeArea: CGFloat = 0.0
            if #available(iOS 11.0, *) {
                safeArea = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            } else {
                // Fallback on earlier versions
            }
            textView.resignFirstResponder()
            //            self.tagListBottomConstraint.constant = -(self.keyboardSize - safeArea)
            self.tagListContainerView.isHidden = false
            self.postCommentFullScreenVC?.setFirstResponder()
            
            let row = textView.tag % 100
            let section = textView.tag / 100
            let indexPath = IndexPath(row: row, section: section)
            self.postCommentFullScreenVC?.indexPath = indexPath
            
            if let post = self.getPreviewPost(indexPath), let postId = post.id {
                self.postCommentFullScreenVC?.postId = postId
            }
        }
    }
    
    func didTapOnViewTaggedPeople(sender: CustomButton) {
        let indexPath = IndexPath(row: sender.row, section: sender.section)
        guard let post = self.getPreviewPost(indexPath) else { return }
        if let taggedIds = post.media?[sender.row].taggedPeople {
            self.showSelectionModal(array: taggedIds, type: .taggedList)
        }
    }
    
    func didTapMentionOnCommentAt(row: Int, section: Int, tagText: String, commentFirst: Comments?, commentSecond: Comments?) {
        var comment = commentFirst
        if commentSecond != nil {
            comment = commentSecond
        }
        if let first = comment,
           let taggedIds = first.taggedIds {
            let current = taggedIds.filter({$0.text == tagText})
            if let userId = current.first?.id {
                let profileController: ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
                if userId != (UserManager.getCurrentUser()?.id ?? "") { //is this is not me who is tagged
                    profileController.otherUserId = userId
                }
                self.navigationController?.pushViewController(profileController, animated: true)
            }
        }
    }
    
    func didTapMentionOnCaptionAt(row: Int, section: Int, tagText: String) {
        let indexPath = IndexPath(row: row, section: section)
        if let post = getPreviewPost(indexPath), let captionTaggedIds = post.captionTags {
            let currentTagged = captionTaggedIds.filter({$0.text == tagText})
            if let userId = currentTagged.first?.id {
                let profileController: ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
                if userId != (UserManager.getCurrentUser()?.id ?? "") { //is this is not me who is tagged
                    profileController.otherUserId = userId
                }
                self.navigationController?.pushViewController(profileController, animated: true)
            }
        }
    }
    
    func didTapOnSharePostWith(id: String, indexPath: IndexPath) {
        guard let selectedPost = getPreviewPost(indexPath) else { return }
        if let link = selectedPost.shortLink , link != ""{
            self.shareLink(data: link)
            return
        } else {
            let urlString = Constant.SubDomain.sharePost + "?post_id=\(selectedPost.id ?? "")"
            let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            self.showLoader()
            DIWebLayerNetworkAPI().getBusinessDynamicLink(url:url,parameters: nil, success: { (response) in
                self.hideLoader()
                self.shareLink(data: response)
                self.search.posts.byPeople.preview.first { (item) -> Bool in item.id == selectedPost.id }?.shortLink = response
                self.search.posts.byCaption.preview.first { (item) -> Bool in item.id == selectedPost.id }?.shortLink = response
                self.search.posts.byTags.preview.first { (item) -> Bool in item.id == selectedPost.id }?.shortLink = response
            }) { (error) in
                self.hideLoader()
                self.showAlert(withError:error)
            }
        }
    }
    
    func shareLink(data:String) {
        let activityViewController = UIActivityViewController(activityItems: [ data ] , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func UserActions(indexPath: IndexPath, isDecrease: Bool, action: UserActions, actionInformation: Any?) {
        guard let post = getPreviewPost(indexPath) else { return }
        switch action {
        case .like:
            self.search.posts.byPeople.preview.first { (item) -> Bool in item.id == post.id }?.updateLikes(withStatus: isDecrease)
            self.search.posts.byCaption.preview.first { (item) -> Bool in item.id == post.id }?.updateLikes(withStatus: isDecrease)
            self.search.posts.byTags.preview.first { (item) -> Bool in item.id == post.id }?.updateLikes(withStatus: isDecrease)
        case .comment :
            func updateComments(_ post: Post?) {
                guard let post = post else { return }
                post.updateCommentsCount(forStatus: isDecrease)
                if let commentInfo = actionInformation as? Comments {
                    post.updateLatestComment(info: commentInfo, value: isDecrease)
                }
                if let comments = actionInformation as? [Comments] {
                    post.updateLatestCommentsArray(data: comments, value: isDecrease)
                }
            }
            updateComments(self.search.posts.byPeople.preview.first { (item) -> Bool in item.id == post.id })
            updateComments(self.search.posts.byCaption.preview.first { (item) -> Bool in item.id == post.id })
            updateComments(self.search.posts.byTags.preview.first { (item) -> Bool in item.id == post.id })
        default:
            break
        }
        UIView.performWithoutAnimation {
            self.table.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func adjustTableHeight(scrollToTp:Bool) {
        UIView.setAnimationsEnabled(false)
        self.table.beginUpdates()
        self.table.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    
    func collectionViewDidScroll(newContentOffset: CGPoint, scrollView: UIScrollView) {
        self.collectionOffsets[scrollView.tag] = newContentOffset
    }
    
    // MARK: Server call
    // delete post api call
    func deletePostAt(indexPath: IndexPath) {
        guard let post = getPreviewPost(indexPath) else { return }
        self.showLoader()
        let params = DeletePostApiKey(id: post.id ?? "")
        PostManager.shared.deletepost(parameters: params.toDictionary(), success: { (message) in
            self.showAlert(message:message)
            self.dotsButtonAction(indexPath: indexPath, type: .delete)
        }) { (error) in
            self.hideLoader()
            self.showAlert(message:error.message)
        }
    }
    
    // delete friend api call
    func deleteFriendAt(indexPath: IndexPath) {
        guard let post = getPreviewPost(indexPath) else { return }
        self.showLoader()
        let params = DeleteFriendApiKey(friendId: post.user?.id  ?? "")
        NetworkConnectionManager().deleteFriend(params: params.toDictionary(), success: { (message) in
            self.showAlert(message:message)
            self.dotsButtonAction(indexPath:indexPath, type: .unfriend)
        }, failure: { (error) in
            self.hideLoader()
            self.showAlert(message:error.message)
        })
    }
}

extension SearchViewController: PresentActionSheetDelegate {
    func presentActionSheet(titleArray: [UserActions], titleColorArray: [UIColor], tag: Int, indexPath: IndexPath) {
        self.view.endEditing(true)
        actionSheet = Utility.presentActionSheet(titleArray: titleArray, titleColorArray: titleColorArray, tag: tag,section: indexPath.section)
        actionSheet.delegate = self
    }
}

extension SearchViewController: CustomBottomSheetDelegate {
    func customSheet(actionForItem action: UserActions) {
        let actionIndex = actionSheet.tag
        let indexPath = IndexPath(row: actionIndex, section: actionSheet.section ?? 0)
        self.actionSheet.dismissSheet()
        guard let post = getPreviewPost(indexPath) else { return }
        if action == .report {
            if Constant.reportHeadings.isEmpty {
                Utility.getHeadings()
            }
        }
        if action == .challenge {
            let controller: CreateGoalOrChallengeViewController = UIStoryboard(storyboard: .creategoalorchallengenew).initVC()
            controller.presenter = CreateGoalOrChallengePresenter(forScreenType: .createChallenge)
            controller.isType = false
            if let user = post.user {
                controller.selectedFriends = [user]
            }
            self.navigationController?.pushViewController(controller, animated: true)
            return
        }
        if action == .cancel {
            return
        }
        self.showAlert(withTitle: "", message: action.message, okayTitle: action.action, cancelTitle: AppMessages.AlertTitles.No,okStyle:.destructive, okCall: {
            guard self.isConnectedToNetwork() else {
                return
            }
            switch action {
            case .delete:
                self.deletePostAt(indexPath: indexPath)
            case .unfriend:
                self.deleteFriendAt(indexPath: indexPath)
            case .report:
                self.addTableView(indexPath: indexPath)
            default:
                break
            }
        }) {
        }
    }
}

/// MARK: UserListTableCellDelegate
extension SearchViewController : UserListTableCellDelegate {
    func didTapremoveFriend(sender: UIButton, rowSection: Int?, userId: String?) {
        
    }
    
    func didTapAcceptOrRemindButton(sender: CustomButton) {
        if !(Reachability.isConnectedToNetwork()) {
            self.showAlert(message:AppMessages.AlertTitles.noInternet)
            return
        }
        let networkConnectionManager = NetworkConnectionManager()
        let indexPath = IndexPath(row: sender.row, section: sender.section)
        guard let friend = getPreviewTemate(indexPath) else { return }
        if let id = friend.id {
            guard User.sharedInstance.id != id else {return}
            let params:FriendRequest = FriendRequest(friendId:id)
            guard let friendStatus = friend.friendStatus else {
                return
            }
            switch friendStatus {
            case .other :
                networkConnectionManager.sendRequest(params: params.getDictionary(), success: {[weak self] (response)  in
                    self?.handleResponse(statusValue: .requestSent, isFriend: 0, id: id, isAccepted: false, indexPath: indexPath)
                }) {[weak self] (error) in
                    self?.showAlert(withError: error)
                }
            case .requestReceived:
                networkConnectionManager.acceptRequest(params: params.getDictionary(), success: {[weak self] (response) in
                    self?.handleResponse(statusValue: .requestSent, isFriend: 1, id: id, isAccepted: true, indexPath: indexPath)
                }) {[weak self] (error) in
                    self?.showAlert(withError: error)
                }
            default:
                break
            }
        }
    }
    
    func didTapCancelButton(sender: CustomButton) {
    }
    
    func handleResponse(statusValue: FriendStatus, isFriend: Int, id: String, isAccepted:Bool, indexPath:IndexPath) {
        func updateFriends(_ search: SearchPeople.ByAttribute) {
            search.friends.preview.first { (item) -> Bool in item.id == id }?.updateFriendStatus(statusValue: statusValue, isFriend: isFriend)
            if let index = search.other.preview.firstIndex(where: { (item) -> Bool in item.id == id }) {
                search.other.preview[index].updateFriendStatus(statusValue: statusValue, isFriend: isFriend)
                if isAccepted {
                    search.moveFromOtherToFriends(otherIndex: index)
                }
            }
        }
        updateFriends(search.people.byName)
        updateFriends(search.people.byLocation)
        updateFriends(search.people.byGym)
        updateFriends(search.people.byInterests)
        self.table.reloadData()
    }
    
    func getIndex(id:String,array:[Friends]) -> Int? {
        if let filteredValue = array.firstIndex(where: {$0.id == id}){
            return filteredValue
        }
        return nil
    }
}

// MARK: PostTableVideoMediaDelegate
extension SearchViewController: PostTableVideoMediaDelegate {
    func didDismissFullScreenPreview() {
        self.playVideo()
    }
    
    func mediaCollectionScrollDidEnd() {
        self.pausePlayVideo()
    }
    
    func didTapOnMuteButton(sender: CustomButton) {
        if let muteStatus = Defaults.shared.get(forKey: .muteStatus) as? Bool {
            //set the reversed value
            Defaults.shared.set(value: !muteStatus, forKey: .muteStatus)
            //            updatePlayerSoundStatus()
        }
        self.updateMuteButtonOnChangingSoundStatus()
    }
    
    ///call this function whenevr the user changes the sound status of the video
    private func updateMuteButtonOnChangingSoundStatus() {
        //updating mute button on other rows as well
        guard let visibleTableCells = table.visibleCells as? [PostTableCell] else {
            return
        }
        for tableCell in visibleTableCells {
            let firstVisibleCell = tableCell.mediaCollectionView.visibleCells.first
            guard let videoCell = firstVisibleCell as? GridCollectionCell else {
                continue
            }
            videoCell.setViewForMuteButton()
        }
    }
}

// MARK: VGPlayerDelegate
extension SearchViewController: VGPlayerDelegate {
    func vgPlayer(_ player: VGPlayer, stateDidChange state: VGPlayerState) {
        self.player.didChangeState()
        updatePlayerSoundStatus()
    }
}

// MARK: VGPlayerViewDelegate
extension SearchViewController: VGPlayerViewDelegate {
    func didTapOnVGPlayerView(_ playerView: VGPlayerView) {
        //present the full screen preview
        guard let indexPath = playerView.indexPath, let post = getPreviewPost(indexPath) else {
            return
        }
        if let tableRow = playerView.section,
           let collectionItem = playerView.row {
            if let tableCell = self.table.cellForRow(at: indexPath) as? PostTableCell,
               let collection = tableCell.mediaCollectionView {
                self.presentFullScreenPreview(forPost: post, atIndex: collectionItem, collectionView: collection, currentDuration: self.player.currentDuration)
                self.removePlayer()
            }
        }
    }
}

extension SearchViewController: ChallengeDelegate {
    func checkActivityStatus(activityId:String) {
        //        self.presenter?.updateOpenGoalInfo(activityId: activityId)
    }
}

extension SearchViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.pausePlayVideo()
    }
}

extension UIView {
    func roundedCorner(bottom:Bool) {
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.frame
        rectShape.position = self.center
        if bottom {
            rectShape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.bottomLeft , .bottomRight], cornerRadii: CGSize(width: 10, height: 10)).cgPath
        }else{
            rectShape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft , .topRight], cornerRadii: CGSize(width: 10, height: 10)).cgPath
        }
        //   self.layer.backgroundColor = UIColor.white.cgColor
        //Here I'm masking the textView's layer with rectShape layer
        self.layer.mask = rectShape
    }
}

extension SearchViewController : EventSearchDelegate {
    func updateEvent(_ item: EventDetail) {
        reload(scrollToTop: false)
    }
    
    func deleteEvent(id: String) {
        reload(scrollToTop: false)
    }
    
    func eventListUpdated() {
        reload(scrollToTop: false)
    }
}
