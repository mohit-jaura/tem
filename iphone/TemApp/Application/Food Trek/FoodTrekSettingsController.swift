//
//  FoodTrekSettingsController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 11/03/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

enum PostShareStatus: Int, CaseIterable{
    case privateStatus = 0
    case publicStatus = 1
    case tematesStatus = 2
}

class FoodTrekSettingsController: DIBaseController {
    
    @IBOutlet weak var lineShadowView:  SSNeumorphicView! {
        didSet{
            setShadow(view: lineShadowView, mainColor: lightShadowColor, lightColor: lightShadowColor, darkColor:darkShadowColor)
        }
    }
    @IBOutlet weak var privateBAckView: SSNeumorphicView!{
        didSet{
            setBackViews(view: privateBAckView)
        }
    }
    @IBOutlet weak var publicBackView: SSNeumorphicView!{
        didSet{
            setBackViews(view: publicBackView)
        }
    }
    @IBOutlet weak var tematesBackView: SSNeumorphicView!{
        didSet{
            setBackViews(view: tematesBackView)
        }
    }
    @IBOutlet var privateBtn: CustomButton!
    @IBOutlet var publicBtn: CustomButton!
    @IBOutlet var temmatesBtn: CustomButton!
    @IBOutlet weak var screenTitleLbl: UILabel!
    // MARK: Variables
    
    var darkShadowColor = UIColor(red: 163.0 / 255.0, green: 177.0 / 255.0, blue: 198.0 / 255.0, alpha: 0.5).cgColor
    var lightShadowColorWithLessAlpha = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.3).cgColor
    var lightShadowColor = #colorLiteral(red: 0.2431372702, green: 0.2431372702, blue: 0.2431372702, alpha: 1).cgColor
    var sharingStatus = 0
    var screenFrom: Constant.ScreenFrom = .foodTrek
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        self.showLoader()
        //   configureViews(status: .privateStatus)
        // getPostShaingStatus()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getSettingsFromAPI()
    }
    // MARK: IBAction
    
    @IBAction func backTapped(_ sender: UIButton) {
//        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true)
    }
    
    @IBAction func privateButtonTapped(_ sender: CustomButton) {
        sharingStatus = 0
        configureViews(status: .privateStatus)
        setSettingsFromAPI()
        
    }
    @IBAction func publicButtonTapped(_ sender: CustomButton) {
        sharingStatus = 1
        configureViews(status: .publicStatus)
        setSettingsFromAPI()
    }
    
    @IBAction func temmatesButtonTappped(_ sender: CustomButton) {
        sharingStatus = 2
        configureViews(status: .tematesStatus)
        setSettingsFromAPI()
        let selectedVC:TemmatesViewController = UIStoryboard(storyboard: .settings).initVC()
        selectedVC.screenFrom = screenFrom
//        self.navigationController?.pushViewController(selectedVC, animated: true)
        self.present(selectedVC, animated: true)
    }
    
    // MARK: Helper Functions
    
    private func initUI() {
        screenTitleLbl.text = "Share your \(screenFrom.title) with your community."
    }
    func setBackViews(view: SSNeumorphicView){
        view.viewDepthType = .outerShadow
        view.viewNeumorphicCornerRadius = 12
        view.viewNeumorphicMainColor = #colorLiteral(red: 0.2431372702, green: 0.2431372702, blue: 0.2431372702, alpha: 1).cgColor
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.1).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
    }

    func setButtonsView(button: CustomButton, isSelected: Bool){
        if isSelected{
            button.setBackgroundImage(#imageLiteral(resourceName: "complete"), for: .normal)
            button.setTitle("ACTIVE", for: .normal)
        }else{
            button.setBackgroundImage(#imageLiteral(resourceName: "gray-honey"), for: .normal)
            button.setTitle("INACTIVE", for: .normal)
        }
    }
    
    func setShadow(view: SSNeumorphicView, mainColor: CGColor, lightColor: CGColor,darkColor: CGColor){
        view.viewDepthType = .outerShadow
        view.viewNeumorphicMainColor = lightShadowColor
        view.viewNeumorphicLightShadowColor = UIColor.clear.cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        view.viewNeumorphicCornerRadius = 0
    }
    
    func configureViews(status: PostShareStatus){
        switch status{
        case .privateStatus:
            setButtonsView(button: privateBtn, isSelected: true)
            setButtonsView(button: publicBtn, isSelected: false)
            setButtonsView(button: temmatesBtn, isSelected: false)
        case .publicStatus:
            setButtonsView(button: publicBtn, isSelected: true)
            setButtonsView(button: privateBtn, isSelected: false)
            setButtonsView(button: temmatesBtn, isSelected: false)
        case .tematesStatus:
            setButtonsView(button: temmatesBtn, isSelected: true)
            setButtonsView(button: publicBtn, isSelected: false)
            setButtonsView(button: privateBtn, isSelected: false)
        }
    }
    private func getSettingsFromAPI() {
        if screenFrom == .weightGoal {
            getWeightGoalSharingStatus()
        } else {
            getPostShaingStatus()
        }
    }
    
    private func setSettingsFromAPI() {
        if screenFrom == .weightGoal {
            setWeightGoalSharingStatus()
        } else {
            setPostSharingStatus()
        }
    }
    func getPostShaingStatus(){
        DIWebLayerFoodTrek().getPostSharingStatus(success: { (response) in
            self.hideLoader()
            self.sharingStatus = response
            self.configureViews(status: (.init(rawValue: response) ?? .privateStatus))
        })  { (error) in
            self.hideLoader()
            self.showAlert( message: error.message , okayTitle: "ok")
        }
    }
    
    func setPostSharingStatus(){
        self.showLoader()
        DIWebLayerFoodTrek().setPostSharingStatus(params:["isfoodsetting": sharingStatus], success: { (response) in
            self.hideLoader()
            print(response)
        }) { (error) in
            print(error)
            self.hideLoader()
            self.showAlert(message: "\(error.message)", okayTitle: "ok")
        }
    }
    
    func getWeightGoalSharingStatus(){
        DIWebLayerWeightGoal().getGoalSharingStatus(completion: { (response) in
            self.hideLoader()
            self.sharingStatus = response
            self.configureViews(status: (.init(rawValue: response) ?? .privateStatus))
        })  { (error) in
            self.hideLoader()
            self.showAlert( message: error.message , okayTitle: "ok")
        }
    }
    
    func setWeightGoalSharingStatus(){
        self.showLoader()
        DIWebLayerWeightGoal().setPostSharingStatus(params:["trackSettings": sharingStatus], completion: { (response) in
            self.hideLoader()
            print(response)
        }) { (error) in
            print(error)
            self.hideLoader()
            self.showAlert(message: "\(error.message)", okayTitle: "ok")
        }
    }
}
