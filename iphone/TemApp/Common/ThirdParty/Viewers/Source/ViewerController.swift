import UIKit
import CoreData

public protocol ViewerControllerDataSource: AnyObject {
    func numberOfItemsInViewerController(_ viewerController: ViewerController) -> Int
    func viewerController(_ viewerController: ViewerController, viewableAt indexPath: IndexPath) -> Viewable
}

public protocol ViewerControllerDelegate: AnyObject {
    func viewerController(_ viewerController: ViewerController, didChangeFocusTo indexPath: IndexPath)
    func viewerControllerDidDismiss(_ viewerController: ViewerController)
    func viewerController(_ viewerController: ViewerController, didFailDisplayingViewableAt indexPath: IndexPath, error: NSError)
    func viewerController(_ viewerController: ViewerController, didLongPressViewableAt indexPath: IndexPath)
}

/// The ViewerController takes care of displaying the user's photos and videos in full-screen. You can swipe right or left to navigate between them.
public class ViewerController: UIViewController {
    static let domain = "com.3lvis.Viewer"
    private static let HeaderHeight = CGFloat(64)
    private static let FooterHeight = CGFloat(50)
    private static let DraggingMargin = CGFloat(60)

    private var isSlideshow: Bool

    public init(initialIndexPath: IndexPath, collectionView: UICollectionView, isSlideshow: Bool = false) {
        self.initialIndexPath = initialIndexPath
        self.currentIndexPath = initialIndexPath
        self.collectionView = collectionView

        self.proposedCurrentIndexPath = initialIndexPath
        self.isSlideshow = isSlideshow

        super.init(nibName: nil, bundle: nil)

        self.view.backgroundColor = .clear
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.modalPresentationStyle = .overCurrentContext
        #if os(iOS)
            self.modalPresentationCapturesStatusBarAppearance = true
        #endif
    }

    private var proposedCurrentIndexPath: IndexPath

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public weak var delegate: ViewerControllerDelegate?
    public weak var dataSource: ViewerControllerDataSource?
    
    /**
     current duration of video,where should start....
     */
     public var currentDuration: Double = 0.0
    
    /**
     Flag that tells the viewer controller to autoplay videos on focus
     */
    public var autoplayVideos: Bool = true

    /**
     Cache for the reused ViewableControllers
     */
    private let viewableControllerCache = NSCache<NSString, ViewableController>()

    /**
     Temporary variable used to present the initial controller on viewDidAppear
     */
    private var initialIndexPath: IndexPath

    /**
     The UICollectionView to be used when dismissing and presenting elements
     */
    private unowned var collectionView: UICollectionView

    /**
     CGPoint used for diffing the panning on an image
     */
    private var originalDraggedCenter = CGPoint.zero

    /**
     Used for doing a different animation when dismissing in the middle of a dragging gesture
     */
    private var isDragging = false

    /**
     Keeps track of where the status bar should be hidden or not
     */
    private var shouldHideStatusBar = false

    /**
     Keeps track of where the status bar should be light or not
     */
    private var shouldUseLightStatusBar = true

    /**
     Critical button visibility state tracker, it's used to force the buttons to keep being hidden when they are toggled
     */
    private var buttonsAreVisible = false

    /**
     Tracks the index for the current viewer item controller
     */
    private(set) public var currentIndexPath: IndexPath

    /**
     A helper to prevent the paginated scroll view to be set up twice when is presented
     */
    private(set) public var isPresented = false

    private lazy var overlayView: UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .black
        view.alpha = 0
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        return view
    }()

    private lazy var pageController: UIPageViewController = {
        let controller = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        controller.dataSource = self
        controller.delegate = self

        return controller
    }()
    

    public var headerView: UIView?

    public var footerView: UIView?

    lazy var scrollView: PaginatedScrollView = {
        let view = PaginatedScrollView(frame: self.view.frame, parentController: self, initialPage: self.initialIndexPath.totalRow(self.collectionView))
        view.viewDataSource = self
        view.viewDelegate = self
        view.backgroundColor = .clear

        return view
    }()

    lazy var slideshowView: SlideshowView = {
        let view = SlideshowView(frame: self.view.frame, parentController: self, initialPage: self.initialIndexPath.totalRow(self.collectionView))
        view.dataSource = self
        view.delegate = self
        view.backgroundColor = .clear

        return view
    }()

    // MARK: View Lifecycle

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        OrientationManager.landscapeSupported = false
        //The code below will automatically rotate your device's orientation when you exit this ViewController
        let orientationValue = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(orientationValue, forKey: "orientation")
        viewableControllerCache.removeAllObjects()
        
       // NotificationCenter.default.removeObserver(self)
        //This method will remove all cache viewcontrollers..
        self.viewableControllerCache.removeAllObjects()
    }
    
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
      // self.addObsereverToCheckLockAndUnlockDevice()
        
        #if os(iOS)
            self.view.addSubview(self.scrollView)
        #else
            let menuTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.menu(gesture:)))
            menuTapRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue)]
            self.view.addGestureRecognizer(menuTapRecognizer)

            if self.isSlideshow {
                self.view.addSubview(self.slideshowView)
            } else {
                self.addChild(self.pageController)
                self.pageController.view.frame = UIScreen.main.bounds
                self.view.addSubview(self.pageController.view)
                self.pageController.didMove(toParent: self)

                let playPauseTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.playPause(gesture:)))
                playPauseTapRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue)]
                self.view.addGestureRecognizer(playPauseTapRecognizer)

                let selectTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.select(gesture:)))
                selectTapRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.select.rawValue)]
                self.view.addGestureRecognizer(selectTapRecognizer)

                let rightSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(rightSwipe(gesture:)))
                rightSwipeRecognizer.direction = .right
                self.view.addGestureRecognizer(rightSwipeRecognizer)

                let leftSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(leftSwipe(gesture:)))
                leftSwipeRecognizer.direction = .left
                self.view.addGestureRecognizer(leftSwipeRecognizer)
            }
        #endif

        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:)))
        self.view.addGestureRecognizer(recognizer)
    }

    #if os(tvOS)
    @objc func menu(gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else { return }

        self.dismiss(nil)
    }

    @objc func playPause(gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else { return }
        self.playIfVideo()
    }

    @objc func select(gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else { return }

        self.playIfVideo()
    }

    
    
    func playIfVideo() {
        let viewableController = self.findOrCreateViewableController(self.currentIndexPath)
        let isVideo = viewableController.viewable?.editableByMembers == .video
        if isVideo {
            viewableController.play()
        }
    }

    @objc func rightSwipe(gesture: UISwipeGestureRecognizer) {
        guard gesture.state == .ended else { return }
        self.scrollView.goRight()
    }

    @objc func leftSwipe(gesture: UISwipeGestureRecognizer) {
        guard gesture.state == .ended else { return }

        self.scrollView.goLeft()
    }
    
    public override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        let result = super.shouldUpdateFocus(in: context)
        if context.focusHeading == .up {
            return false
        }
        return result
    }
    #endif

    @objc func longPress(gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }

        self.delegate?.viewerController(self, didLongPressViewableAt: self.currentIndexPath)
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if self.isPresented {
            if self.isSlideshow {
                self.slideshowView.configure()
            } else {
                self.scrollView.configure()
            }
            if !self.collectionView.indexPathsForVisibleItems.contains(self.currentIndexPath) && self.collectionView.numberOfSections > self.currentIndexPath.section && self.collectionView.numberOfItems(inSection: self.currentIndexPath.section) > self.currentIndexPath.item {
                self.collectionView.scrollToItem(at: self.currentIndexPath, at: .bottom, animated: true)
            }
        }
    }

    
    
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let tabBarController = self.presentingViewController?.tabBarController as? TabBarViewController {
            print("got tab bar _---------")
            tabBarController.tabbarHandling(isHidden: true, controller: self)
        }
        OrientationManager.landscapeSupported = true
        self.present(with: self.initialIndexPath, completion: nil)
        
    }

    public func reload(at indexPath: IndexPath) {
        let viewableController = self.findOrCreateViewableController(indexPath)
        viewableController.display()
    }
}

extension ViewerController {
    #if os(iOS)
        public override var prefersStatusBarHidden: Bool {
            let orientation = UIApplication.shared.statusBarOrientation
            if orientation.isLandscape {
                return true
            }

            return self.shouldHideStatusBar
        }

        public override var preferredStatusBarStyle: UIStatusBarStyle {
            if self.shouldUseLightStatusBar {
                return .lightContent
            } else {
                return self.presentingViewController?.preferredStatusBarStyle ?? .default
            }
        }
    #endif

    private func presentedViewCopy() -> UIImageView {
        let presentedView = UIImageView()
        presentedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        presentedView.contentMode = .scaleAspectFill
        presentedView.clipsToBounds = true

        return presentedView
    }

    private func findOrCreateViewableController(_ indexPath: IndexPath) -> ViewableController {
        let viewable = self.dataSource!.viewerController(self, viewableAt: indexPath)
        var viewableController: ViewableController

        if let cachedController = self.viewableControllerCache.object(forKey: indexPath.description as NSString) {
            viewableController = cachedController
        } else {
            viewableController = ViewableController()
            viewableController.delegate = self
            viewableController.dataSource = self

            let gesture = UIPanGestureRecognizer(target: self, action: #selector(ViewerController.panAction(_:)))
            gesture.delegate = self
            viewableController.imageView.addGestureRecognizer(gesture)

            self.viewableControllerCache.setObject(viewableController, forKey: indexPath.description as NSString)
        }

        viewableController.update(with: viewable, at: indexPath)

        return viewableController
    }

    private func toggleButtons(_ shouldShow: Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            #if os(iOS)
                self.setNeedsStatusBarAppearanceUpdate()
            #endif
            self.headerView?.alpha = shouldShow ? 1 : 0
            self.footerView?.alpha = shouldShow ? 1 : 0
        })
    }

    private func fadeButtons(_ alpha: CGFloat) {
        self.headerView?.alpha = alpha
        self.footerView?.alpha = alpha
    }

    private func present(with indexPath: IndexPath, completion: (() -> Void)?) {
        guard let selectedCell = self.collectionView.cellForItem(at: indexPath) else { return }

        let viewable = self.dataSource!.viewerController(self, viewableAt: indexPath)
        let image = viewable.placeholder
        selectedCell.alpha = 0

        let presentedView = self.presentedViewCopy()
        presentedView.frame = self.view.convert(selectedCell.frame, from: self.collectionView)
        
        //comment1
        presentedView.image = image

        self.view.addSubview(self.overlayView)
        self.view.addSubview(presentedView)

        if let headerView = self.headerView {
            headerView.translatesAutoresizingMaskIntoConstraints = false
            headerView.alpha = 0
            self.view.addSubview(headerView)

            NSLayoutConstraint.activate([
                headerView.topAnchor.constraint(equalTo: view.compatibleTopAnchor),
                headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                headerView.heightAnchor.constraint(equalToConstant: ViewerController.HeaderHeight)
                ])
        }

        if let footerView = self.footerView {
            footerView.translatesAutoresizingMaskIntoConstraints = false
            footerView.alpha = 0
            self.view.addSubview(footerView)

            NSLayoutConstraint.activate([
                footerView.bottomAnchor.constraint(equalTo: view.compatibleBottomAnchor),
                footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                footerView.heightAnchor.constraint(equalToConstant: ViewerController.FooterHeight)
                ])
        }

        let centeredImageFrame = image.centeredFrame()
        UIView.animate(withDuration: 0.25, animations: {
            self.presentingViewController?.tabBarController?.tabBar.alpha = 0
            self.overlayView.alpha = 1.0
            #if os(iOS)
                self.setNeedsStatusBarAppearanceUpdate()
            #endif
            presentedView.frame = centeredImageFrame
        }, completion: { _ in
            self.toggleButtons(true)
            self.buttonsAreVisible = true
            self.currentIndexPath = indexPath
            presentedView.removeFromSuperview()
            self.overlayView.removeFromSuperview()
            self.view.backgroundColor = .black

            self.isPresented = true
            let controller = self.findOrCreateViewableController(indexPath)
            controller.display()

            self.delegate?.viewerController(self, didChangeFocusTo: indexPath)

            #if os(iOS)
                completion?()
            #else
                if self.isSlideshow {
                    self.slideshowView.start()

                    UIApplication.shared.isIdleTimerDisabled = true
                } else {
                    self.pageController.setViewControllers([controller], direction: .forward, animated: false, completion: { _ in
                        completion?()
                    })
                }
            #endif
        })
    }

    public func dismiss(_ completion: (() -> Void)?) {
        let controller = self.findOrCreateViewableController(self.currentIndexPath)
        self.dismiss(controller, completion: completion)
    }

    private func dismiss(_ viewableController: ViewableController, completion: (() -> Void)?) {
        if self.isSlideshow {
            self.slideshowView.stop()

            UIApplication.shared.isIdleTimerDisabled = false
        }

        guard let indexPath = viewableController.indexPath else { return }

        guard let selectedCellFrame = self.collectionView.layoutAttributesForItem(at: indexPath)?.frame else { return }

        let viewable = self.dataSource!.viewerController(self, viewableAt: indexPath)
        let image = viewable.placeholder
        viewableController.imageView.alpha = 0
        viewableController.view.backgroundColor = .clear
        viewableController.willDismiss()

        self.view.alpha = 0
        self.fadeButtons(0)
        self.buttonsAreVisible = false
        self.updateHiddenCellsUsingVisibleIndexPath(self.currentIndexPath)

        self.shouldHideStatusBar = false
        #if os(iOS)
            self.setNeedsStatusBarAppearanceUpdate()
        #endif
        self.overlayView.alpha = self.isDragging ? viewableController.view.backgroundColor!.cgColor.alpha : 1.0
        self.overlayView.frame = UIScreen.main.bounds

        let presentedView = self.presentedViewCopy()
        presentedView.frame = image.centeredFrame()
        
        //comment 2
        presentedView.image = image
        if self.isDragging {
            presentedView.center = viewableController.imageView.center
        }

        let window = self.applicationWindow()
        window.addSubview(self.overlayView)
        window.addSubview(presentedView)
        self.shouldUseLightStatusBar = false

        UIView.animate(withDuration: 0.30, animations: {
            self.presentingViewController?.tabBarController?.tabBar.alpha = 1
            self.overlayView.alpha = 0.0
            #if os(iOS)
                self.setNeedsStatusBarAppearanceUpdate()
            #endif
            presentedView.frame = self.view.convert(selectedCellFrame, from: self.collectionView)
        }, completion: { _ in
            if let existingCell = self.collectionView.cellForItem(at: indexPath) {
                existingCell.alpha = 1
            }

            self.headerView?.removeFromSuperview()
            self.footerView?.removeFromSuperview()
            presentedView.removeFromSuperview()
            self.overlayView.removeFromSuperview()
            self.dismiss(animated: false, completion: nil)

            // A small delay is required to avoid racing conditions between the dismissing animation and the
            // state change after the animation is completed.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.isPresented = false
                self.delegate?.viewerControllerDidDismiss(self)
                completion?()
            }
        })
    }

    @objc func panAction(_ gesture: UIPanGestureRecognizer) {
        let controller = self.findOrCreateViewableController(self.currentIndexPath)
        guard !controller.hasZoomed else { return }
        
        let viewHeight = controller.imageView.frame.size.height
        let viewHalfHeight = viewHeight / 2
        var translatedPoint = gesture.translation(in: controller.imageView)

        if gesture.state == .began {
            self.shouldHideStatusBar = false
            #if os(iOS)
                self.setNeedsStatusBarAppearanceUpdate()
            #endif
            self.view.backgroundColor = .clear
            self.originalDraggedCenter = controller.imageView.center
            self.isDragging = true
            self.updateHiddenCellsUsingVisibleIndexPath(self.currentIndexPath)
            controller.willDismiss()
        }

        translatedPoint = CGPoint(x: self.originalDraggedCenter.x, y: self.originalDraggedCenter.y + translatedPoint.y)
        let alphaDiff = ((translatedPoint.y - viewHalfHeight) / viewHalfHeight) * 2.5
        let isDraggedUp = translatedPoint.y < viewHalfHeight
        let alpha = isDraggedUp ? 1 + alphaDiff : 1 - alphaDiff

        controller.dimControls(alpha)
        controller.imageView.center = translatedPoint
        controller.view.backgroundColor = UIColor.black.withAlphaComponent(alpha)

        if self.buttonsAreVisible {
            self.fadeButtons(alpha)
        }

        if gesture.state == .ended {
            let centerAboveDraggingArea = controller.imageView.center.y < viewHalfHeight - ViewerController.DraggingMargin
            let centerBellowDraggingArea = controller.imageView.center.y > viewHalfHeight + ViewerController.DraggingMargin
            if centerAboveDraggingArea || centerBellowDraggingArea {
                self.dismiss(controller, completion: nil)
            } else {
                self.isDragging = false
                UIView.animate(withDuration: 0.20, animations: {
                    controller.imageView.center = self.originalDraggedCenter
                    controller.view.backgroundColor = .black
                    controller.dimControls(1.0)

                    if self.buttonsAreVisible {
                        self.fadeButtons(1)
                    }

                    self.shouldHideStatusBar = !self.buttonsAreVisible
                    self.shouldUseLightStatusBar = true

                    #if os(iOS)
                        self.setNeedsStatusBarAppearanceUpdate()
                    #endif
                }, completion: { _ in
                    controller.display()
                    self.view.backgroundColor = .black
                })
            }
        }
    }

    private func centerElementIfNotVisible(_ indexPath: IndexPath, animated: Bool) {
        if !self.collectionView.indexPathsForVisibleItems.contains(indexPath) {
            self.collectionView.scrollToItem(at: indexPath, at: .top, animated: animated)
        }
    }

    private func updateHiddenCellsUsingVisibleIndexPath(_ visibleIndexPath: IndexPath) {
        for indexPath in self.collectionView.indexPathsForVisibleItems {
            if let cell = self.collectionView.cellForItem(at: indexPath) {
                cell.alpha = indexPath == visibleIndexPath ? 0 : 1
            }
        }
    }

    private func evaluateCellVisibility(collectionView: UICollectionView, currentIndexPath: IndexPath, upcomingIndexPath: IndexPath) {
        if !collectionView.indexPathsForVisibleItems.contains(upcomingIndexPath) {
            var position: UICollectionView.ScrollPosition?
            if currentIndexPath.compareDirection(upcomingIndexPath) == .forward {
                position = .bottom
            } else if currentIndexPath.compareDirection(upcomingIndexPath) == .backward {
                position = .top
            }
            if let position = position {
                collectionView.scrollToItem(at: upcomingIndexPath, at: position, animated: true)
            }
        }
    }
}

extension ViewerController: ViewableControllerDelegate {

    func viewableControllerDidTapItem(_: ViewableController) {
        self.shouldHideStatusBar = !self.shouldHideStatusBar
        self.buttonsAreVisible = !self.buttonsAreVisible
        self.toggleButtons(self.buttonsAreVisible)
    }

    func viewableController(_: ViewableController, didFailDisplayingVieweableWith error: NSError) {
        self.delegate?.viewerController(self, didFailDisplayingViewableAt: self.currentIndexPath, error: error)
    }
}

extension ViewerController: ViewableControllerDataSource {

    func viewableControllerOverlayIsVisible(_: ViewableController) -> Bool {
        return self.buttonsAreVisible
    }

    func viewableControllerIsFocused(_ viewableController: ViewableController) -> Bool {
        let focusedViewableController = self.findOrCreateViewableController(self.currentIndexPath)

        return viewableController == focusedViewableController
    }

    func viewableControllerShouldAutoplayVideo(_: ViewableController) -> Bool {
        if (self.currentDuration > 0.0) {
          let viewableController = self.findOrCreateViewableController(self.currentIndexPath)
          viewableController.videoCurrentDuration = self.currentDuration
          self.currentDuration = 0.0
        }
        return self.autoplayVideos
    }
}

extension ViewerController: UIGestureRecognizerDelegate {

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer {
            let panGestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
            let velocity = panGestureRecognizer.velocity(in: panGestureRecognizer.view!)
            let allowOnlyVerticalScrolls = abs(velocity.y) > abs(velocity.x)

            return allowOnlyVerticalScrolls
        }

        return true
    }
}

extension ViewerController: ViewableControllerContainerDataSource {
    func numberOfPagesInViewableControllerContainer(_ viewableControllerContainer: ViewableControllerContainer) -> Int {
        return self.dataSource?.numberOfItemsInViewerController(self) ?? 0
    }

    func viewableControllerContainer(_ viewableControllerContainer: ViewableControllerContainer, controllerAtIndex index: Int) -> UIViewController {
        
        guard let indexPath = IndexPath.indexPathForIndex(self.collectionView, index: index) else {
            return UIViewController()
        }

        return self.findOrCreateViewableController(indexPath)
    }
}

extension ViewerController: ViewableControllerContainerDelegate {
    func viewableControllerContainer(_ viewableControllerContainer: ViewableControllerContainer, didMoveToIndex index: Int) {
        guard let indexPath = IndexPath.indexPathForIndex(self.collectionView, index: index) else {
            return
        }
        self.evaluateCellVisibility(collectionView: self.collectionView, currentIndexPath: self.currentIndexPath, upcomingIndexPath: indexPath)
        self.currentIndexPath = indexPath
        self.delegate?.viewerController(self, didChangeFocusTo: indexPath)
        let viewableController = self.findOrCreateViewableController(indexPath)
        viewableController.display()
    }

    func viewableControllerContainer(_ viewableControllerContainer: ViewableControllerContainer, didMoveFromIndex index: Int) {
        guard let indexPath = IndexPath.indexPathForIndex(self.collectionView, index: index) else {
            return
        }
        let viewableController = self.findOrCreateViewableController(indexPath)
        viewableController.willDismiss()
    }
}

extension ViewerController: UIPageViewControllerDelegate {
    public func pageViewController(_: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let controllers = pendingViewControllers as? [ViewableController] else { fatalError() }

        for controller in controllers {
            self.delegate?.viewerController(self, didChangeFocusTo: controller.indexPath!)
            self.proposedCurrentIndexPath = controller.indexPath!
        }
    }

    public func pageViewController(_: UIPageViewController, didFinishAnimating _: Bool, previousViewControllers _: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            self.delegate?.viewerController(self, didChangeFocusTo: self.proposedCurrentIndexPath)
            self.currentIndexPath = self.proposedCurrentIndexPath
            self.delegate?.viewerController(self, didChangeFocusTo: self.currentIndexPath)
            self.centerElementIfNotVisible(self.currentIndexPath, animated: false)
        }
    }
}

extension ViewerController: UIPageViewControllerDataSource {
    public func pageViewController(_: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let viewerItemController = viewController as? ViewableController, let newIndexPath = viewerItemController.indexPath?.previous(self.collectionView) {
            let controller = self.findOrCreateViewableController(newIndexPath)
            controller.display()

            return controller
        }
        return nil
    }

    public func pageViewController(_: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let viewerItemController = viewController as? ViewableController, let newIndexPath = viewerItemController.indexPath?.next(self.collectionView) {
            let controller = self.findOrCreateViewableController(newIndexPath)
            controller.display()
            return controller
        }
        return nil
    }
    
}//Extension.....

extension ViewerController: NSDiscardableContent {
    public func beginContentAccess() -> Bool {
        return true
    }
    
    public func endContentAccess() {
        
    }
    
    public func discardContentIfPossible() {
        
    }
    
    public func isContentDiscarded() -> Bool {
        return false
    }
}

//extension ViewerController {
//
//    func addObsereverToCheckLockAndUnlockDevice() {
//        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
//    }
//
//    @objc func applicationDidBecomeActive(notification: NSNotification) {
//        print("ACTIVE")
//    }
//    @objc func applicationDidEnterBackground(notification: NSNotification) {
//        print("BACKGROUND")
//
////        if !(UIInterfaceOrientation.portrait.isPortrait) {
////         let orientationValue = UIInterfaceOrientation.portrait.rawValue
////         UIDevice.current.setValue(orientationValue, forKey: "orientation")
////        }
//
//    }
//    //
//}
