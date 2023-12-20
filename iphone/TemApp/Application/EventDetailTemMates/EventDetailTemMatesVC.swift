//
//  EventDetailTemMatesVC.swift
//  TemApp
//
//  Created by Developer on 27/09/21.
//  Copyright © 2021 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView
class EventDetailTemMatesVC: DIBaseController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var temmatesView: SSNeumorphicView!{
        didSet{
    setShadow(view: temmatesView, shadowType: .innerShadow)
    }
    }
    
    func setShadow(view: SSNeumorphicView, shadowType: ShadowLayerType){
        view.viewDepthType = shadowType
        view.viewNeumorphicMainColor = UIColor.newAppThemeColor.cgColor
        view.viewNeumorphicLightShadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        view.viewNeumorphicCornerRadius = 8
        view.viewNeumorphicShadowRadius = 3
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

extension EventDetailTemMatesVC:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
