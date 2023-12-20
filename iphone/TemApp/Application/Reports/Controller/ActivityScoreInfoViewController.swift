//
//  ActivityScoreInfoViewController.swift
//  TemApp
//
//  Created by shilpa on 30/04/20.
//

import UIKit

class ActivityScoreInfoViewController: UIViewController {

    // MARK: Properties
    let callibrationContent = """
    During the calibration period (typically the first 30 days depending on consistency) you will see vast fluctuations in your score. This is normal as TĒM begins to understand your behaviors. Physical Activity and Health Biomarkers are the main drivers during this period. Nutrition plays a smaller role in calibration.
    """
    
    let managementContent = """
    During the management period you will begin to see smaller but more impactful changes in your score. Day 31 and beyond is when you have established your baseline and the app and TĒMai will help you manage and improve your score. With an understanding of your physical activity and accountability index, nutrition will take focus to help balance out your behavioral health and maximize its impact on your total health and HAIS.
    """
    
    // MARK: IBOutlets
    @IBOutlet weak var callibrationContentLabel: UILabel!
    @IBOutlet weak var mangementContentLabel: UILabel!
    
    // MARK: IBActions
    @IBAction func crossButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.callibrationContentLabel.text = callibrationContent
        self.mangementContentLabel.text = managementContent
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
