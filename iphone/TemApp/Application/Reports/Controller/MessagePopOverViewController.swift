//
//  MessagePopOverViewController.swift
//  TemApp
//
//  Created by shilpa on 29/04/20.
//

import UIKit
enum MessagePopOverType: Int {
    case radar, hais
}
class MessagePopOverViewController: UIViewController {

    // MARK: Properties
    let radarDescription = """
    This is a color-coded representation of how balanced each area of health is in relation to your other areas. It captures six major categories: Social, Medical, Physical Activity, Mental, Nutrition and Cardiovascular. As you engage with the app you will begin to fill the blue honeycomb with green from the middle out.
    """
    
    let haisDescription = "Press on your HAIS number to see and add more detail."
    var popOverType: MessagePopOverType = .hais
    
    // MARK: IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainViewLeading: NSLayoutConstraint!
    @IBOutlet weak var mainViewTrailing: NSLayoutConstraint!
    
    // MARK: IBActions
    @IBAction func crossTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setData()
    }

    // MARK: INitializer
    private func setData() {
        switch self.popOverType {
        case .radar:
            self.contentLabel.textAlignment = .justified
            self.contentLabel.text = radarDescription
        case .hais:
            self.mainViewLeading.constant = 30
            self.mainViewTrailing.constant = 30
            self.contentLabel.textAlignment = .center
            self.titleLabel.isHidden = true
            self.contentLabel.text = haisDescription
        }
    }

}
