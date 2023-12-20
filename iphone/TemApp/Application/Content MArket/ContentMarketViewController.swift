//
//  ContentMarketViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 11/04/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//
import UIKit

class ContentMarketViewController: DIBaseController {

    // MARK: IBAction
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var thirdButton: UIButton!

    // MARK: Variables
    var isPlanAdded = 0
    var contentMarketData:SeeAllModel?
    var marketPlaceId = ""
    var affiliateId = ""
    var selectedIcon = "Oval Copy 12"
    var unselectedIcon = "Oval Copy 13"
    var contentPageViewController: ContentMarketPageViewController? {
        didSet {
            contentPageViewController?.tutorialDelegate = self
            contentPageViewController?.id = self.marketPlaceId
            contentPageViewController?.updateViewsDelegate = self
            contentPageViewController?.affiliateId = self.affiliateId
            contentPageViewController?.isPlanAdded  = self.isPlanAdded
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkHostLive()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Stream.connect.resetAllBanners()
    }
    func initialize(){
        configureViews(selectedBtn: firstButton, unselectedBtns: [secondButton,thirdButton])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tutorialPageViewController = segue.destination as? ContentMarketPageViewController {
            self.contentPageViewController = tutorialPageViewController
        }
    }

    func checkHostLive(){
        Stream.connect.toServer(affiliateId,false,nil, {[weak self] isStreamOn,modal  in
            DispatchQueue.main.async {
                Stream.connect.showHeader(modal: modal)
            }
        })
    }

    // MARK: IBActions
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true
        )
    }
    @IBAction func firstButtonTapped(_ sender: UIButton) {
        configureViews(selectedBtn: firstButton, unselectedBtns: [secondButton,thirdButton])
        contentPageViewController?.scrollToNextViewController(controllerIndex: sender.tag)
    }

    @IBAction func secondButtonTapped(_ sender: UIButton) {
        configureViews(selectedBtn: secondButton, unselectedBtns: [firstButton,thirdButton])
        contentPageViewController?.scrollToNextViewController(controllerIndex: sender.tag)
    }
    
    @IBAction func thirdButtonTapped(_ sender: UIButton) {
        configureViews(selectedBtn: thirdButton, unselectedBtns: [secondButton,firstButton])
        contentPageViewController?.scrollToNextViewController(controllerIndex: sender.tag)
    }
    
    func configureViews(selectedBtn: UIButton, unselectedBtns: [UIButton]){
        selectedBtn.setBackgroundImage(UIImage(named: selectedIcon), for: .normal)
        for button in unselectedBtns{
            button.setBackgroundImage(UIImage(named: unselectedIcon), for: .normal)
        }
    }
    @objc func didChangePageControlValue() {
        contentPageViewController?.scrollToViewController(index: pageControl.currentPage)
    }
}

extension ContentMarketViewController: TutorialPageViewControllerDelegate {

    func tutorialPageViewController(tutorialPageViewController: ContentMarketPageViewController,
                                    didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }

    func tutorialPageViewController(tutorialPageViewController: ContentMarketPageViewController,
                                    didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
        switch index{
            case 0:
                configureViews(selectedBtn: firstButton, unselectedBtns: [secondButton,thirdButton])
            case 1:
                configureViews(selectedBtn: secondButton, unselectedBtns: [firstButton,thirdButton])
            case 2:
                configureViews(selectedBtn: thirdButton, unselectedBtns: [secondButton,firstButton])
            default:
                break
        }
    }
}
extension ContentMarketViewController: UpdateViewsDelegate{
    func updateViews(index: Int) {
        switch index{
            case 0:
                configureViews(selectedBtn: firstButton, unselectedBtns: [secondButton,thirdButton])
            case 1:
                configureViews(selectedBtn: secondButton, unselectedBtns: [firstButton,thirdButton])
            case 2:
                configureViews(selectedBtn: thirdButton, unselectedBtns: [secondButton,firstButton])
            default:
                break
        }
    }
}
