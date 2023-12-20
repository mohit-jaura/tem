//
//  SocialCollectionCell.swift
//  TemApp
//
//  Created by shivani on 08/07/21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

protocol SocialCollectionCellDelegate: AnyObject {
    func didTapOnViewFeed()
    func didTapOnNewPost()
    func didTapOnViewLeaderboard()
}

class SocialCollectionCell: UICollectionViewCell {

    // MARK: Properties
    var rightInset: CGFloat = 7
    weak var delegate: SocialCollectionCellDelegate?
    var leaderboard: MyLeaderboard? {
        didSet {
            if leaderboard != nil {
                self.activityIndicator.isHidden = true
            }
            self.leaderboardTableView.reloadData()
        }
    }
    
    // MARK: Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var myCommunityLabel: UILabel!
    @IBOutlet weak var labelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var leaderboardOuterView: SSNeumorphicView! {
        didSet {
            leaderboardOuterView.viewDepthType = .innerShadow
            leaderboardOuterView.viewNeumorphicLightShadowColor = UIColor(red: 163.0 / 255.0, green: 177.0 / 255.0, blue: 198.0 / 255.0, alpha: 0.3).cgColor
            leaderboardOuterView.viewNeumorphicDarkShadowColor = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.3).cgColor
            leaderboardOuterView.viewNeumorphicCornerRadius = 8.0
            leaderboardOuterView.viewNeumorphicMainColor = UIColor.blakishGray.cgColor
            leaderboardOuterView.viewNeumorphicShadowRadius = 2.0
        }
    }
    @IBOutlet weak var leaderboardInnerView: SSNeumorphicView! {
        didSet {
            leaderboardInnerView.viewDepthType = .innerShadow
            leaderboardInnerView.viewNeumorphicLightShadowColor = UIColor.clear.cgColor
            leaderboardInnerView.viewNeumorphicDarkShadowColor = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1).cgColor//UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.4).cgColor
            leaderboardInnerView.viewNeumorphicMainColor = UIColor.blakishGray.cgColor
            leaderboardInnerView.viewNeumorphicShadowOpacity = 0.25
            leaderboardInnerView.viewNeumorphicCornerRadius = 8.0
            leaderboardInnerView.viewNeumorphicShadowRadius = 1.5
        }
    }
    @IBOutlet weak var viewFeedGradientView: GradientDashedLineCircularView!
    @IBOutlet weak var newPostGradientView: GradientDashedLineCircularView!
    @IBOutlet weak var viewFeedShadowView: SSNeumorphicView! {
        didSet {
            setOuterShadows(view: viewFeedShadowView)
        }
    }
    @IBOutlet weak var newPostShadowView: SSNeumorphicView! {
        didSet {
            setOuterShadows(view: newPostShadowView)
        }
    }
    
    @IBOutlet var viewFeedLabel: UILabel!
    @IBOutlet var newPostLabel: UILabel!
    @IBOutlet var viewFeedGradientContainerView: UIView!
    @IBOutlet var newPostGradientContainerView: UIView!
    @IBOutlet var leaderboardTableView: UITableView!
    
    // MARK: Set layout
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.leaderboardTableView.register(UINib(nibName: HomeLeaderboardTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: HomeLeaderboardTableViewCell.reuseIdentifier)
        
        self.addTapGesturesOnGradientView()
    }
    
    private func setOuterShadows(view: SSNeumorphicView) {
        view.viewDepthType = .outerShadow
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.1).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.blakishGray.cgColor
        view.viewNeumorphicCornerRadius = 30
        view.viewNeumorphicMainColor =  UIColor.blakishGray.cgColor
        view.viewNeumorphicShadowRadius = 1.0
    }
    
    // MARK: Initialize data
    func initializeData() {
    }
    
    private func addTapGesturesOnGradientView() {
        let viewFeedTap = UITapGestureRecognizer(target: self, action: #selector(onFeedViewTap))
        let newPostTap = UITapGestureRecognizer(target: self, action: #selector(onNewPostViewTap))
    }
    
    @objc func onFeedViewTap() {
        self.delegate?.didTapOnViewFeed()
    }
    
    @objc func onNewPostViewTap() {
        self.delegate?.didTapOnNewPost()
    }
    
    // MARK: Set Gradient views
    private func setGradientViews() {
        viewFeedGradientView.configureViewProperties(colors: [UIColor(red: 50.0 / 255.0, green: 197.0 / 255.0, blue: 255.0 / 255.0, alpha: 1), UIColor.appPurpleColor, UIColor(red: 247.0 / 255.0, green: 181.0 / 255.0, blue: 0.0 / 255.0, alpha: 1)], gradientLocations: [0, 0.5, 1], startEndPint: GradientLocation(startPoint: CGPoint(x: 0.5, y: 0.5)))
        viewFeedGradientView.extraInstanceCount = 1
        viewFeedGradientView.instanceWidth = 1.5
        viewFeedGradientView.instanceHeight = 2.5
        
        newPostGradientView.configureViewProperties(colors: [UIColor(red: 11.0 / 255.0, green: 249.0 / 255.0, blue: 243.0 / 255.0, alpha: 1), UIColor(red: 199.0 / 255.0, green: 211.0 / 255.0, blue: 202.0 / 255.0, alpha: 1), UIColor(red: 11.0 / 255.0, green: 249.0 / 255.0, blue: 243.0 / 255.0, alpha: 1)], gradientLocations: [0.28, 0.30, 0.70])
        newPostGradientView.extraInstanceCount = 1
        newPostGradientView.instanceWidth = 1.5
        newPostGradientView.instanceHeight = 2.5
    }
}
 
// MARK: UITableViewDataSource
extension SocialCollectionCell: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.leaderboard == nil ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.leaderboard?.addedTemates?.prefix(3).count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeLeaderboardTableViewCell.reuseIdentifier) as? HomeLeaderboardTableViewCell else {
            return UITableViewCell()
        }
        if indexPath.row == 0{
            cell.rankLabel.backgroundColor = #colorLiteral(red: 0.9858387113, green: 1, blue: 0.00324295368, alpha: 1)
        } else if indexPath.row == 1{
            
         cell.rankLabel.backgroundColor = #colorLiteral(red: 0.8588235974, green: 0.8588235974, blue: 0.8588235974, alpha: 1)
    } else {
        cell.rankLabel.backgroundColor = #colorLiteral(red: 0.724856317, green: 0.6585546732, blue: 0, alpha: 1)
    }
        cell.setLeaderboardInfo(userInfo: self.leaderboard?.addedTemates?[indexPath.row] ?? Friends())
        return cell
    }
}

// MARK: UITableViewDelegate
extension SocialCollectionCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        //if leaderboard != nil {
        let bgView = UIView(frame: CGRect(x: 20, y: 0, width: tableView.frame.width + 35, height: 40))
        
        let view = SSNeumorphicView(frame: CGRect(x: 22, y: 5, width: tableView.frame.width - 42, height: 40))
        
        view.viewDepthType = .outerShadow
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.1).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = 4.0
        view.viewNeumorphicMainColor = UIColor.blakishGray.cgColor
        view.viewNeumorphicShadowRadius = 2.0
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        label.text = "See Leaderboard"
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont(name: UIFont.avenirNextBold, size: 15)
        label.addShadowToText(color: UIColor.black, radius: 3.0, opacity: 0.8, offset: CGSize(width: 1, height: 1))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(leaderboardAllActionTapped))
        label.isUserInteractionEnabled = true
        view.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapGesture)
        view.addSubview(label)
        bgView.addSubview(view)
        return bgView
        //}
        //return nil
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if leaderboard != nil {
            return 40
        }
        return CGFloat.leastNormalMagnitude
    }
    
    @objc func leaderboardAllActionTapped() {
        self.delegate?.didTapOnViewLeaderboard()
    }
    
    func setViewStateFor(loadingState: ApiLoadingState) {
        switch loadingState {
        case .hasError(let error):
            self.activityIndicator.isHidden = true
            self.leaderboardTableView.showEmptyScreen(error, isWhiteBackground: true, fontSize: 13)
        case .isLoaded:
            self.activityIndicator.isHidden = true
            self.leaderboardTableView.showEmptyScreen("", isWhiteBackground: true, fontSize: 13)
        case .isLoading:
            self.activityIndicator.isHidden = false
            self.leaderboardTableView.showEmptyScreen("", isWhiteBackground: true, fontSize: 13)
        }
    }
}
