//
//  TemTvViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 14/01/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

struct TvSeries: Codable{
    var name: String?
    var description: String?
    var image: String?
    var episodes: Int?
    var id: String?
    var about: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case image
        case episodes = "numOfEpisodes"
        case id = "_id"
        case about = "about"
    }
}

class TemTvViewController: DIBaseController {
    
    
    var seriesData:[TvSeries] = [TvSeries]()
    
    // MARK: IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    // MARK: IBAction
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func searchTapped(_ sender: UIButton) {
        let searchVc: SearchViewController = UIStoryboard(storyboard: .search).initVC()
        self.navigationController?.pushViewController(searchVc, animated: true)
    }
    
    // MARK: Helper Function
    func initialize(){
        tableView.registerNibs(nibNames: [TemTvTableViewCell.reuseIdentifier])
        tableView.isSkeletonable = true
        tableView.showAnimatedSkeleton()
        getSeriesData()
        
       
    }
    
    func getSeriesData(){
        if Reachability.isConnectedToNetwork() {
        DIWeblayerTemTvAPI().getSeriesData(success: {  (data) in
            self.seriesData = data
            if self.seriesData.count == 0{
                self.tableView.showEmptyScreen("No episodes added yet !")
            }
            self.tableView.reloadData()
            self.tableView.hideSkeleton()
        }, failure: { (error) in
            self.tableView.hideSkeleton()
            print("error\(error)")
        })
        } else{
            self.showAlert(message: AppMessages.AlertTitles.noInternet)
        }
    }
    
}

// MARK: UITableViewDelegate, UITableViewDataSource
    extension TemTvViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return seriesData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: TemTvTableViewCell.reuseIdentifier) as! TemTvTableViewCell 
        cell.setSeriesData(seriesData: seriesData[indexPath.row])
            
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episodesVC: EpisodesViewController = UIStoryboard(storyboard: .temTv).initVC()
       episodesVC.seriesData = self.seriesData[indexPath.row]
        self.navigationController?.pushViewController(episodesVC, animated: true)
    }
}

extension TemTvViewController: SkeletonTableViewDataSource{
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return TemTvTableViewCell.reuseIdentifier
    }
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

}
