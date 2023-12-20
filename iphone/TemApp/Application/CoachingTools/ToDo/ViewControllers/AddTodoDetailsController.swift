//
//  AddTodoDetailsController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 01/05/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import UIKit

class AddTodoDetailsController: UIViewController , NSAlertProtocol{


    //MARK: IBOutlet
    @IBOutlet weak var outerBgView: UIView!
    @IBOutlet weak var addItemTExtVIew: UITextView!

    //MARK: Variables
    var headerTitle = ""
    var itemName:StringCompletion?

    override func viewDidLoad() {
        super.viewDidLoad()
        addTitleLabel()
    }

    @IBAction func saveTapped(_ sender: UIButton) {
        if addItemTExtVIew.text != ""{
            itemName?(addItemTExtVIew.text)
            self.dismiss(animated: true)
        } else{
            self.showAlert(withTitle: "", message: "Please enter item name")
        }
    }

    @IBAction func cancelTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    private func addTitleLabel(){
        let myLabel = UILabel()
        myLabel.text = "    " + headerTitle + "     "
        let font = UIFont(name: UIFont.avenirNextMedium, size: 12)
        let heightOfString = headerTitle.heightOfString(usingFont: font!)
        let x_cord = 25
        let y_cord = 1//(wellnessOuterView.frame.origin.y)

        let widthofString = headerTitle.widthOfString(usingFont: font!)
        var widthOfLabel:CGFloat = widthofString - 20
        if widthofString > outerBgView.frame.width {
            widthOfLabel = widthofString
        }
        myLabel.frame = CGRect(x: CGFloat(x_cord), y: CGFloat(y_cord), width: widthOfLabel, height: heightOfString)
        myLabel.backgroundColor = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.262745098, alpha: 0.9)
        myLabel.textColor = #colorLiteral(red: 0.01568627451, green: 0.9137254902, blue: 0.8901960784, alpha: 1)
        myLabel.font = font
        myLabel.textAlignment = .left
        myLabel.sizeToFit()
        outerBgView.addSubview(myLabel)
        outerBgView.clipsToBounds = false
    }

}
