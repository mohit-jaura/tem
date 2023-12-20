//
//  ActivityTypeViewController.swift
//  TemApp
//
//  Created by Developer on 30/01/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
protocol ActivityTypeViewDelegate: AnyObject {
    func didSelectActivity(type: ActivityMembersType)
}
class ActivityTypeViewController: UIViewController {
    var arr:[String] = ["Individual vs Individual","Individual vs Tem", "Tem vs Tem" ]
    var delegate:ActivityTypeViewDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

extension ActivityTypeViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTypeCell", for: indexPath) as! ActivityTypeCell
        cell.label.text = arr[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let delegate = delegate else {
            return
        }
        if indexPath.row == 0 {
            delegate.didSelectActivity(type: .individual)
        } else if indexPath.row == 1{
            delegate.didSelectActivity(type: .individualVsTem)
        } else {
            delegate.didSelectActivity(type: .temVsTem)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}
