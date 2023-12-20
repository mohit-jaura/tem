//
//
//  Created by Harmeet on 4/23/20.
//

import UIKit

class ProfileView: UIView {

   let titleArray = ["Welcome to TĒM","TĒMATES","Challenges/Goals","ACTIVITY SCORE","HAIS SCORE"]
   let descArray = ["We are excited that you joined us! Let’s get you started. \n There is a ton you can do on the app, but we think you’ll  \n really want to know about:","Search for and add your tēmates here.","Create challenges and set goals here.","This is your Activity Score. Press it to learn \n more.","Press the center honeycomb to see your \n HAIS. Press the logo to learn more. \n ENJOY!"]
   let subTitlestr = "TĒMATES \n CHALLENGES & GOALS \n SCORES"
   let subDesc = "We will let you play around with the other stuff."
  // let str2 = "ENJOY!"
let images = ["t-honeycomb1","tut3","tut2","tut4","tut5"]
   // @IBOutlet weak var strLblConstant: NSLayoutConstraint!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var imageBg: UIImageView!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var strLbl: UILabel!
    @IBOutlet weak var str1Lbl: UILabel!

    @IBOutlet weak var descLblConstant: NSLayoutConstraint!
    @IBOutlet weak var titleLblConstant: NSLayoutConstraint!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    func displayData(index: Int) {
        print("index= ",index)
       // strLblConstant.constant = 80
        imageBg.image = UIImage(named: images[index])
        imageBg.contentMode = .scaleAspectFit
        if index == 0 {
            titleLbl.text = titleArray[index]
            descLbl.text = descArray[index]
            strLbl.text = subTitlestr
            str1Lbl.text = subDesc
            
            descLblConstant.constant = 70
            titleLblConstant.constant = 20
        } else {
            descLbl.text = ""
            titleLbl.text = ""
            descLblConstant.constant = 10
            titleLblConstant.constant = 0
            strLbl.text = titleArray[index]
          //  strLblConstant.constant = 0
            str1Lbl.text = descArray[index]
            if index == 4 {
            //    strLblConstant.constant = 50            }
        }
        }
    }

}
