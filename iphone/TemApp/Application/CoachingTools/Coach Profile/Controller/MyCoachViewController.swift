//
//  MyCoachViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 20/02/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import UIKit

class MyCoachViewController: UIViewController,LoaderProtocol {

    var coachListVM = CoachViewModal()

    // MARK: IBoutlets
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       initializer()
    }
    
   private func initializer(){
        getCoachList()
    }

   private func getCoachList(){
        self.showHUDLoader()
        coachListVM.getCoachList{[weak self] in
            self?.hideHUDLoader()
            if let error = self?.coachListVM.error{
                print(error.message)
            }
            if self?.coachListVM.coachList?.count ?? 0 == 0 {
                   self?.tableView.showEmptyScreen("No Data Found!", isWhiteBackground: false)
                return
            }
         self?.tableView.reloadData()
        }
    }

// MARK: IBAction
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK:  UITableViewDataSource,UITableViewDelegate
extension MyCoachViewController: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coachListVM.coachList?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: MyCoachTableViewCell = tableView.dequeueReusableCell(withIdentifier: MyCoachTableViewCell.reuseIdentifier) as? MyCoachTableViewCell else{
            return UITableViewCell()
        }
        if let listData = coachListVM.coachList{
            cell.setData(list: listData[indexPath.row] )
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let profileController: ProfileDashboardController = UIStoryboard(storyboard: .profile).initVC()
        profileController.otherUserId = coachListVM.coachList?[indexPath.row].id
        self.navigationController?.pushViewController(profileController, animated: true)
    }
}
