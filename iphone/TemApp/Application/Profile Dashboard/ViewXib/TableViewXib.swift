//
//  TableViewXib.swift
//  TemApp
//
//  Created by Harpreet_kaur on 02/05/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import UIKit
protocol TableViewXibDelegate {
    func setData(selectedData:ReportData,indexPath:IndexPath)
}

class TableViewXib: UIView {
    
    
    // MARK: Variables
    var xibTableArray = [ReportData]()
    var tableCellIdentifier:String = "cell"
    var delegate:TableViewXibDelegate?
    var tap:UITapGestureRecognizer!
    var selectedData:ReportData?
    var indexPath:IndexPath?
    
    
    // MARK: IBOulets.
    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var xibTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var xibTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    
    // MARK: UITableViewFunctions
    override func awakeFromNib() {
        xibTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: xibTableView.frame.size.width, height: 1))
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: IBActions.
    // MARK: CancelButtonAction
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0.0
        }) { (true) in
            self.removeXib()
        }
    }
    
    
    // MARK: Custom Functions.
    // MARK: Function to set view data.
    func setData(height:CGFloat) {
        xibTableView.delegate = self
        xibTableView.dataSource = self
        xibTableView.register(UITableViewCell.self, forCellReuseIdentifier: tableCellIdentifier)
        xibTableArray = Constant.reportHeadings
        xibTableViewHeightConstraint.constant = CGFloat(xibTableArray.count*44)
        if height == 812 {
            if CGFloat(xibTableArray.count*44) > height - 100 {
                xibTableViewHeightConstraint.constant = height - 150
                xibTableView.isScrollEnabled = true
            }
        }else{
            if CGFloat(xibTableArray.count*44) > height - 40 {
                xibTableViewHeightConstraint.constant = height - 100
                xibTableView.isScrollEnabled = true
            }
        }
        setTapGesture()
    }
    
    // MARK: CreateTapGesture to remove Xib from its superview.
    func setTapGesture() {
        tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction(sender:)))
        dimView.isUserInteractionEnabled = true
        dimView.addGestureRecognizer(tap)
    }
    
    // MARK: Function to remove Xib from its superview.
    func removeXib() {
        UIView.animate(withDuration: 0.2, animations: {
            self.removeFromSuperview()
        }) { (true) in
        }
    }
    
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        if tap != nil{
            dimView.removeGestureRecognizer(tap)
        }
        removeXib()
    }
}

// MARK: UITableViewDelegate&UITableViewDataSource
extension TableViewXib:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return xibTableArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier) else {
            return  UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.tintColor = appThemeColor
        cell.textLabel?.text = xibTableArray[indexPath.row].title
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedData = xibTableArray[indexPath.row]
        delegate?.setData(selectedData: self.selectedData ?? ReportData(), indexPath: self.indexPath ?? IndexPath(row: 0, section: 0))
            
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0.0
            
        }) { (true) in
            self.removeXib()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //  CellAnimator.animateCell(cell, withTransform: CellAnimator.TransformFlip, andDuration: 0.5)
    }
}

