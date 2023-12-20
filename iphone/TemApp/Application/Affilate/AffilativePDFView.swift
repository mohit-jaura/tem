//
//  AffilativePDFView.swift
//  TemApp
//
//  Created by Developer on 25/04/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import PDFKit
class AffilativePDFView: DIBaseController {
    @IBOutlet weak var view1:UIView!
    var urlString:String = ""
    var screenFrom: Constant.ScreenFrom = Constant.ScreenFrom.activity
    override func viewDidLoad() {
        super.viewDidLoad()
        let pdfView = PDFView(frame: view1.bounds)
                view1.addSubview(pdfView)

                if let url = URL(string: urlString), let document = PDFDocument(url: url) {
                    pdfView.document = document
                }
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
    @IBAction func backTapped(_ sender: UIButton) {
        if screenFrom == .event{
            self.dismiss(animated: true)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
}
