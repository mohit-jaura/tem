//
//  EpisodesViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 18/01/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

struct Episodes: Codable{
    var name: String
    var description: String
    var id: String
    var media: String
    var seriesId: String
 //   var fileType: String
  var previewUrl: String
    var mediaType: Int // 1->video, 2->audio
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case id = "_id"
        case media = "file"
        case seriesId
        case previewUrl = "preview_url"
        case mediaType
    }
}

class EpisodesViewController: DIBaseController {
    
    // MARK: IBOutlets
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var episodeNameLabel: UILabel!
    @IBOutlet weak var episodeDescriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var bgImageViewHeight: NSLayoutConstraint!
    // MARK: Variables
    
    private var seekTimeOfCurrentVideo: TimeInterval = 0
    var seriesData: TvSeries?
    var episodesData:[Episodes] = [Episodes]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        initialize()
    }
    
    // MARK: Helper Function
    func initialize(){
        tableView.registerNibs(nibNames: [TemTvTableViewCell.reuseIdentifier])
        tableView.isSkeletonable = true
        tableView.showSkeleton()
        getEpisodesData()
        configureView()
    }
    func configureView(){
        if let imageUrl = seriesData?.image,
           let url = URL(string: imageUrl){
            backgroundImageView.kf.setImage(with: url, placeholder: UIImage(named: "ImagePlaceHolder"))
        }
        if let bgImage = backgroundImageView.image{
            let ratio = bgImage.size.width / bgImage.size.height
            let newHeight = backgroundImageView.frame.width / ratio
//            if newHeight > 350{
//                bgImageViewHeight.constant = 350
//            }else{
            bgImageViewHeight.constant = newHeight
            view.layoutIfNeeded()
    //    }
     
        }
        episodeNameLabel.text = seriesData?.name?.capitalized
        episodeDescriptionLabel.text = seriesData?.description
        setGradientBackground()
    }
    
    func setGradientBackground() {
        let maskLayer = CAGradientLayer(layer: backgroundImageView.layer)
        maskLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        maskLayer.startPoint = CGPoint(x: 0, y: 0)
        maskLayer.endPoint = CGPoint(x: 0, y: 1.0)
        maskLayer.frame = backgroundImageView.bounds
        backgroundImageView.layer.mask = maskLayer
        
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getEpisodesData(){
        if Reachability.isConnectedToNetwork() {
            DIWeblayerTemTvAPI().getEpisodesData(seriesId: seriesData?.id ?? "", success: {  (data) in
                self.episodesData = data
                if self.episodesData.count == 0{
                    self.tableView.showEmptyScreen("No episodes added yet!")
                }
                self.tableView.reloadData()
                self.tableView.hideSkeleton()
            }, failure: { (error) in
                self.tableView.hideSkeleton()
            })}
        else{
            self.showAlert(message: AppMessages.AlertTitles.noInternet)
        }
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension EpisodesViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return episodesData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TemTvTableViewCell.reuseIdentifier) as? TemTvTableViewCell else{
            return UITableViewCell()
        }
        cell.setEpisodesData(episodeData: episodesData[indexPath.row])
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if episodesData[indexPath.row].mediaType == 1{ // will show the video
            let episodeVideoVC: EpisodeVideoViewController = UIStoryboard(storyboard: .temTv).initVC()
            episodeVideoVC.url = episodesData[indexPath.row].media
            self.navigationController?.pushViewController(episodeVideoVC, animated: false)
        } else{ // will show the audio
            
            let audioPlayVC: AudioPlayViewController = UIStoryboard(storyboard: .temTv).initVC()
            audioPlayVC.previewImage = episodesData[indexPath.row].previewUrl
            audioPlayVC.remoteUrl = episodesData[indexPath.row].media
            self.navigationController?.pushViewController(audioPlayVC, animated: false)
            
        }
    }
    
}
// MARK: SkeletonTableViewDataSource
extension EpisodesViewController: SkeletonTableViewDataSource{
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return TemTvTableViewCell.reuseIdentifier
    }
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
}
//protocol StopLoaderDelegate
