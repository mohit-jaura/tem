//
//  UITableView+Extension.swift
//  Spot_me
//
//  Created by Shilpa on 30/08/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    
    func scrollWithKeyboard(keyboardHeight: CGFloat, inputView: UITextView, extraOffset: CGFloat? = 0.0) {
        let keyboardEndPoint = self.frame.height - keyboardHeight
        let pointInTable = inputView.superview?.convert(inputView.frame.origin, to: self) ?? CGPoint.zero//inputView.superview!.superview!.convert(inputView.frame.origin, to: self)
        
        var safeArea: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            safeArea = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        } else {
            // Fallback on earlier versions
        }
        
        var textFieldBottomPoint = pointInTable.y + inputView.frame.size.height + 10 - safeArea// + 50
        if extraOffset! != 0 {
            textFieldBottomPoint = textFieldBottomPoint - extraOffset! + safeArea
        }
        
        //if keyboardEndPoint <= textFieldBottomPoint {
        var contentOffset = self.contentOffset
        contentOffset.y = textFieldBottomPoint - keyboardEndPoint
        DispatchQueue.main.async {
            //            print("setting offset--------> \(contentOffset.y)")
            print("keyboard size: \(keyboardHeight)")
            self.setContentOffset(contentOffset, animated: true)
        }
        
    }
    
    ///Changes rendering of tableview from bottom
    func renderObjectsFromBottom() {
        let numRows = self.numberOfRows(inSection: 0)
        var contentInsetTop = self.bounds.size.height
        for i in 0..<numRows {
            let rowRect = self.rectForRow(at: IndexPath(item: i, section: 0))
            contentInsetTop -= rowRect.size.height
            if contentInsetTop <= 0 {
                contentInsetTop = 0
            }
        }
        self.contentInset = UIEdgeInsets.init(top: contentInsetTop, left: 0, bottom: 0, right: 0)
    }
    
    ///This method is used to get current indexpath of cell.
    func getCurrentIndexPath() -> IndexPath{
        var visibleRect = CGRect()
        visibleRect.origin = self.contentOffset
        visibleRect.size = self.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath: IndexPath = self.indexPathForRow(at: visiblePoint) ?? IndexPath()
        return visibleIndexPath
    }
    
    func showCenterBackgroundView(view:UIView,isTabBar:Bool = false,centerY:CGFloat) {
        backgroundView = UIView(frame:CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        let height = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var y = centerY
        if isTabBar {
            y = y - 44
        }
        view.frame =  CGRect(x: 0, y: y , width: self.bounds.size.width , height: height)
        self.backgroundView?.addSubview(view)
        
    }
    
    //returns the empty footer view for table
    func emptyFooterView(withBackground color: UIColor? = UIColor.clear) -> UIView {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: 20)
        view.backgroundColor = color!
        return view
    }
    
    func pullToRefresh(_ vc: UIViewController, callBack: @escaping () -> Void) {
        let animator = ArrowRefreshAnimator(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        addPullToRefresh(66.0, animator: animator) {
            callBack()
        }
    }
    
    func endRefresh() {
        endRefreshing()
    }
    func endInfiniteScroll() {
        endInfiniteScrolling()
    }
    func enableInfiniteScrolling(status: Bool) {
        enableInfiniteScroll = status
    }
    
    func endPull2RefreshAndInfiniteScrolling(count: Int) {
        if count >= 15 {
            enableInfiniteScroll = true
        } else {
            enableInfiniteScroll = false
        }
        endRefreshing()
        endInfiniteScrolling()
        reloadData()
    }
    
    func infiniteScrolling(_ vc: UIViewController, callBack: @escaping () -> Void) {
        let animator = DefaultInfiniteAnimator(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        addInfiniteScroll(60, animator: animator) {
            callBack()
        }
    }
    
    
    
    func showEmptyScreen(_ message: String, isWhiteBackground: Bool? = true, fontSize: CGFloat = 18) {
        //backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        let noDataLabel: UILabel = UILabel(frame: CGRect(x: 20, y: 0, width: self.bounds.size.width - 20, height: self.bounds.size.height))
        noDataLabel.text = message
        noDataLabel.textColor = #colorLiteral(red: 0.7302808762, green: 0.7317310572, blue: 0.7744688392, alpha: 1)
        if !isWhiteBackground! {
            noDataLabel.textColor = UIColor.textBlackColor
        }
        noDataLabel.font = UIFont(name: UIFont.avenirNextMedium, size: fontSize)//UIFont(name: "SFProText-Bold", size: 18)
        noDataLabel.textAlignment = .center
        noDataLabel.numberOfLines = 0
        //self.backgroundView?.addSubview(noDataLabel)
        self.backgroundView = noDataLabel
        //        self.separatorStyle = .none
    }
    
    func restore() {
        self.backgroundView = nil
    }
    
    func registerNibs(nibNames: [String]) {
        for nibName in nibNames {
            let nib = UINib(nibName: nibName, bundle: nil)
            self.register(nib, forCellReuseIdentifier: nibName)
        }
    }
    
    func registerHeaderFooter(nibNames: [String]) {
        for nibName in nibNames {
            let nib = UINib(nibName: nibName, bundle: nil)
            self.register(nib, forHeaderFooterViewReuseIdentifier: nibName)
        }
    }
    
//    func fadeEdges(with modifier: CGFloat) {
//        let visibleCells = self.visibleCells
//        
//        guard !visibleCells.isEmpty else { return }
//        guard let topCell = visibleCells.first else { return }
//        guard let bottomCell = visibleCells.last else { return }
//        
//        visibleCells.forEach {
//            $0.contentView.alpha = 1
//        }
//        
//        let cellHeight = topCell.frame.height - 1
//        let tableViewTopPosition = self.frame.origin.y
//        let tableViewBottomPosition = self.frame.maxY
//        
//        guard let topCellIndexpath = self.indexPath(for: topCell) else { return }
//        let topCellPositionInTableView = self.rectForRow(at:topCellIndexpath)
//        
//        guard let bottomCellIndexpath = self.indexPath(for: bottomCell) else { return }
//        let bottomCellPositionInTableView = self.rectForRow(at: bottomCellIndexpath)
//        
//        let topCellPosition = self.convert(topCellPositionInTableView, to: self.superview).origin.y
//        let bottomCellPosition = self.convert(bottomCellPositionInTableView, to: self.superview).origin.y + cellHeight
//        let topCellOpacity = (1.0 - ((tableViewTopPosition - topCellPosition) / cellHeight) * modifier)
//        let bottomCellOpacity = (1.0 - ((bottomCellPosition - tableViewBottomPosition) / cellHeight) * modifier)
//        
//        topCell.contentView.alpha = topCellOpacity
//        bottomCell.contentView.alpha = bottomCellOpacity
//    }
}//Class....

extension UITableViewCell {
    
    func hideSeparator() {
        self.separatorInset = UIEdgeInsets(top: 0, left: self.bounds.size.width, bottom: 0, right: 0)
    }
    
    func showSeparator() {
        self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func removeSectionSeparators() {
        for subview in subviews {
            if subview != contentView && subview.frame.width == frame.width {
                subview.removeFromSuperview()
            }
        }
    }
    
}//Extension.....
extension UITableView {
    func updateHeaderViewHeight(){
        if let headerView = self.tableHeaderView {
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var headerFrame = headerView.frame
            //Comparison necessary to avoid infinite loop
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                DispatchQueue.main.async {
                    self.tableHeaderView?.layoutIfNeeded()
                    self.tableHeaderView = headerView
                    self.layoutIfNeeded()
                }
            }
            headerView.translatesAutoresizingMaskIntoConstraints = true
        }
    }
}

extension UITableView{
    
    func PlacholderCell() ->  PlaceholderCell{
        if  let dict = self.value(forKey: "_nibMap") as? [String:UINib]{
            let check = dict["PlaceholderCell"]
            if check?.isKind(of: PlaceholderCell.self) == true{
                let cell = self.dequeueReusableCell(withIdentifier: "PlaceholderCell") as! PlaceholderCell
                //                cell.viewBackground.startShimmering()
                cell.viewBackground.startLayerAnimation()
                
                return cell
            }
        }
        
        self.register(UINib.init(nibName: "PlaceholderCell", bundle: nil), forCellReuseIdentifier: "PlaceholderCell")
        let cell = self.dequeueReusableCell(withIdentifier: "PlaceholderCell") as! PlaceholderCell
        //        cell.viewBackground.startShimmering()
        cell.viewBackground.startLayerAnimation()
        
        return cell
    }
    
    func MessagePlacholderCell() ->  MessagePlaceholderCell {
        if  let dict = self.value(forKey: "_nibMap") as? [String:UINib]{
            let check = dict["MessagePlaceholderCell"]
            if check?.isKind(of: PlaceholderCell.self) == true{
                let cell = self.dequeueReusableCell(withIdentifier: "MessagePlaceholderCell") as! MessagePlaceholderCell
                cell.backView.startShimmering()
                cell.shimmerView.startLayerAnimation()
                
                return cell
            }
        }
        
        self.register(UINib.init(nibName: "MessagePlaceholderCell", bundle: nil), forCellReuseIdentifier: "MessagePlaceholderCell")
        let cell = self.dequeueReusableCell(withIdentifier: "MessagePlaceholderCell") as! MessagePlaceholderCell
        cell.backView.startShimmering()
        cell.shimmerView.startLayerAnimation()
        
        return cell
    }
    
    func removePlaceHolder(){
        self.stopShimmering()
    }
}
extension UIScrollView {
    func showEmptyScreen(_ message: String, isWhiteBackground: Bool? = true) {
        //backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        let noDataLabel: UILabel = UILabel(frame: CGRect(x: 20, y: 0, width: self.bounds.size.width - 20, height: self.bounds.size.height))
        noDataLabel.text = message
        noDataLabel.textColor = #colorLiteral(red: 0.7302808762, green: 0.7317310572, blue: 0.7744688392, alpha: 1)
        if !isWhiteBackground! {
            noDataLabel.textColor = #colorLiteral(red: 0.7302808762, green: 0.7317310572, blue: 0.7744688392, alpha: 1)//.black
        }
        noDataLabel.font = UIFont(name: UIFont.robotoBold, size: 18)//UIFont(name: "SFProText-Bold", size: 18)
        noDataLabel.textAlignment = .center
        noDataLabel.numberOfLines = 0
        if let tableview = self as? UITableView {
            tableview.backgroundView = noDataLabel
        } else if let collectionview = self as? UICollectionView {
            collectionview.backgroundView = noDataLabel
        }
    }
}

extension UICollectionView {
    func rectForItem(at indexPath: IndexPath) -> CGRect? {
        if let attributes = self.layoutAttributesForItem(at: indexPath) {
            return attributes.frame
        }
        return nil
    }
}
extension UITableView {

    func fadeEdges(with modifier: CGFloat) {

        let visibleCells = self.visibleCells

        guard !visibleCells.isEmpty else { return }
        guard let topCell = visibleCells.first else { return }
        guard let bottomCell = visibleCells.last else { return }


        let topMOstCells = visibleCells[0..<3]
        let topMOstCellss = Array(topMOstCells)

        visibleCells.forEach {
            $0.contentView.alpha = 1
        }
        var cellHeight2 = CGFloat(0.0)
        for cell in topMOstCellss{
            if (cell.index(ofAccessibilityElement: 2) != 0){
                cellHeight2 = cell.frame.height - 1
            }

        }




        let cellHeight = topCell.frame.height - 1
        let tableViewTopPosition = self.frame.origin.y
        let tableViewBottomPosition = self.frame.maxY

        guard let topCellIndexpath = self.indexPath(for: topCell) else { return }
        let topCellPositionInTableView = self.rectForRow(at:topCellIndexpath)

        guard let bottomCellIndexpath = self.indexPath(for: bottomCell) else { return }
        let bottomCellPositionInTableView = self.rectForRow(at: bottomCellIndexpath)

        let topCellPosition = self.convert(topCellPositionInTableView, to: self.superview).origin.y
        let bottomCellPosition = self.convert(bottomCellPositionInTableView, to: self.superview).origin.y + cellHeight
        let topCellOpacity = (1.0 - ((tableViewTopPosition - topCellPosition) / cellHeight) * modifier)
        let bottomCellOpacity = (1.0 - ((bottomCellPosition - tableViewBottomPosition) / cellHeight) * modifier)

        topCell.contentView.alpha = topCellOpacity
        bottomCell.contentView.alpha = bottomCellOpacity
    }

}
