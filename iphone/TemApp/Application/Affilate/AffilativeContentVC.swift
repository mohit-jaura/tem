//
//  AffilativeContentVC.swift
//  TemApp
//
//  Created by Developer on 11/04/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

class AffilativeContentVC: DIBaseController {
    
    var marketPlaceId = ""
    @IBOutlet weak var tableView:UITableView!
    private var affilativeContentModel:[AffilativeContentModel] =  [AffilativeContentModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        getAffilativeContent()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    
    private func getAffilativeContent() {
        if self.isConnectedToNetwork() {
            self.showLoader()
            DIWebLayerReportsAPI().getAffilativeContent(id:marketPlaceId) { response in
                self.hideLoader()
                self.affilativeContentModel = response
                self.tableView.reloadData()
            } failure: { error in
                self.hideLoader()
                print("error\(error)")
            }
        }
        else{
            self.showAlert(message: AppMessages.AlertTitles.noInternet)
        }
    }

}

extension AffilativeContentVC:UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return affilativeContentModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AffilativeContentTVC", for: indexPath) as!
        AffilativeContentTVC
        cell.model = affilativeContentModel[indexPath.section].data
        cell.affilativeContentVC = self
        cell.collectionView1.tag = indexPath.row
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 70))

        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.text = affilativeContentModel[section].categoryName ?? ""
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        headerView.addSubview(label)
        headerView.backgroundColor = .black

        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 30))
        let sepratorView = UIView.init(frame: CGRect.init(x: 0, y: 25, width: footerView.frame.width, height: 0.6))
        sepratorView.backgroundColor = .darkGray
        footerView.addSubview(sepratorView)
        footerView.backgroundColor = .black
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    
}
