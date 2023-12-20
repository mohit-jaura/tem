//
//  ProgramDetailsController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 07/12/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class ProgramDetailsController: DIBaseController {
    
    // MARK: IBOutlet
    @IBOutlet weak var tableView: UITableView!
    var currentAlpha = 0.45
    var programID: String?
    
    @IBOutlet weak var addCalendarButton: UIButton!
    @IBOutlet weak var numberOfDaysLabel: UILabel!
    @IBOutlet weak var daysActivityView: SSNeumorphicView!
    @IBOutlet weak var nameLabel: UILabel!
    var programDetails:ProgramDataModal?

    override func viewDidLoad() {
        super.viewDidLoad()
        initilise()
    }

    func tableInitlise() {
        tableView.registerNibs(nibNames: [ProgramTableViewCell.reuseIdentifier])
        tableView.registerHeaderFooter(nibNames: [ProgramHeaderView.reuseIdentifier, ProgramHeaderView.reuseIdentifier])
    }
    func initilise() {
        tableInitlise()
        initliseViews()
        apiForProgramDetails()
    }
    func initialiseAfterApi() {
        nameLabel.text = programDetails?.programName?.capitalized
        numberOfDaysLabel.text = "\(programDetails?.programDuration ?? 0)"
        if programDetails?.isStarted == 1 {
            addCalendarButton.isHidden = true
        } else{
            addCalendarButton.isHidden = false
        }
            
        self.tableView.reloadData()
    }
    func initliseViews() {
        self.daysActivityView.cornerRadius = self.daysActivityView.frame.height/2
             self.daysActivityView.viewDepthType = .innerShadow
             daysActivityView.viewNeumorphicCornerRadius = self.daysActivityView.frame.width/2
             self.daysActivityView.viewNeumorphicMainColor = UIColor.black.cgColor
             self.daysActivityView.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
             self.daysActivityView.viewNeumorphicDarkShadowColor = UIColor.darkGray.cgColor

    }

    @IBAction func addToCalendarTapped(_ sender: UIButton) {
        self.showLoader()
        DIWebLayerContentMarket().addProgram(programId: programDetails?._id ?? "", parameter: nil, success: { msg in
            self.hideLoader()
            self.showAlert(withTitle: msg ?? "")
            self.addCalendarButton.isHidden = true
        }, failure: { error in
            self.hideLoader()
            self.showAlert(withTitle: error?.message ?? "")
            
        })
    }

    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: Api for program Details
    func apiForProgramDetails() {
        self.showLoader()
            guard let programID = programID else {return}

                let apiInfo = EndPoint.ProgramDetails(programID)
                DIWebLayerEvent().programDetails(endPoint: apiInfo.url) {[weak self] status in
                    DispatchQueue.main.async {
                        switch status {
                        case .Success(let data,_):
                            self?.hideLoader()
                            if let dataGet = data as? ProgramDataModal {
                                self?.programDetails = dataGet
                                self?.initialiseAfterApi()
                            }
                        case .NoDataFound:
                            self?.hideLoader()
                            debugPrint("No data found")
                            DispatchQueue.main.async {
                                self?.alertOpt("No data found",  okCall: {
                                    self?.navigationController?.popViewController(animated: true)
                                }, parent: self)
                            }
                        case .Failure(let err):
                            self?.hideLoader()
                            debugPrint("No data found")
                            DispatchQueue.main.async {
                                self?.alertOpt(err,  okCall: {
                                    self?.navigationController?.popViewController(animated: true)
                                }, parent: self)
                            }
                        }
                    }
            }
    }
}
// MARK: After installation
extension ProgramDetailsController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return programDetails?.programs?.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if programDetails?.programs?[section].isOpened ?? false{
            return 1
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: ProgramTableViewCell = tableView.dequeueReusableCell(withIdentifier: ProgramTableViewCell.reuseIdentifier, for: indexPath) as? ProgramTableViewCell else {
            return UITableViewCell()
        }
        let modal = programDetails?.programs?[indexPath.section]
       // cell.bgView.alpha = modal.isDisabl ?? false ? currentAlpha : 1
        cell.setData(data: modal)
        cell.showMediaDelegate = self
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ProgramHeaderView.reuseIdentifier) as! ProgramHeaderView
        let modal = programDetails?.programs?[section]
        headerView.setData(data:modal)
        headerView.arrowButton.tag = section
        headerView.showEventDetailsDelegate = self
//        headerView.durationLabel.font = modal.isDisabl ?? false ? UIFont(name: UIFont.avenirNextRegular, size: 16) : UIFont(name: UIFont.avenirNextMedium, size: 17)
//        headerView.nameLAbel.font = modal.isDisabl ?? false ? UIFont(name: UIFont.avenirNextRegular, size: 16) : UIFont(name: UIFont.avenirNextMedium, size: 17)
     //   headerView.bgView.backgroundColor = modal.isDisabl ?? false ? UIColor(rgb: (r: 62, g: 62, b: 62)) : .black
        
        //headerView.bgView.alpha = modal.isDisabl ?? false ? currentAlpha : 1
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = #colorLiteral(red: 0.2431372702, green: 0.2431372702, blue: 0.2431372702, alpha: 1)
   }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ProgramDetailsController: ShowEventDetailsDelegate{
    func openDetails(at index: Int) {
        if let isOpened =  programDetails?.programs?[index].isOpened {
            programDetails?.programs?[index].isOpened = !isOpened
        }
        UIView.performWithoutAnimation {
            self.tableView.reloadSections(IndexSet(integer: index), with: .none)
        }

    }
}
extension UIView {
    func addBorder(toEdges edges: UIRectEdge, color: UIColor, thickness: CGFloat) {

        func addBorder(toEdge edges: UIRectEdge, color: UIColor, thickness: CGFloat) {
            let border = CALayer()
            border.backgroundColor = color.cgColor

            switch edges {
            case .top:
                border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
            case .bottom:
                border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
            case .left:
                border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
            case .right:
                border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
            default:
                break
            }

            layer.addSublayer(border)
        }

        if edges.contains(.top) || edges.contains(.all) {
            addBorder(toEdge: .top, color: color, thickness: thickness)
        }

        if edges.contains(.bottom) || edges.contains(.all) {
            addBorder(toEdge: .bottom, color: color, thickness: thickness)
        }

        if edges.contains(.left) || edges.contains(.all) {
            addBorder(toEdge: .left, color: color, thickness: thickness)
        }

        if edges.contains(.right) || edges.contains(.all) {
            addBorder(toEdge: .right, color: color, thickness: thickness)
        }
    }
}

extension ProgramDetailsController: ShowMediaDelegate{
    func showMedia(media type: Int, url: String) {
        switch EventMediaType(rawValue: type){
        case .video:
            let episodeVideoVC: EpisodeVideoViewController = UIStoryboard(storyboard: .temTv).initVC()
            episodeVideoVC.url =  url
            self.navigationController?.pushViewController(episodeVideoVC, animated: false)
        case .pdf:
            let selectedVC:AffilativePDFView = UIStoryboard(storyboard: .affilativeContentBranch).initVC()
            selectedVC.urlString =  url
           self.navigationController?.pushViewController(selectedVC, animated: true)
        default:
            break
        }
    }
    
    
}
