//
//  AffilativePDFView.swift
//  TemApp
//
//  Created by Developer on 25/04/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import PDFKit
class AffilativePDFView: UIViewController, LoaderProtocol, NSAlertProtocol {
    
    @IBOutlet weak var view1:UIView!
    var urlString:String = ""
    var screenFrom: Constant.ScreenFrom = Constant.ScreenFrom.activity
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showHUDLoader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getDocument { [weak self] document in
            self?.hideHUDLoader()
            if let document = document {
                self?.setDocumentToView(document: document)
            } else {
                self?.showAlert(withMessage: "Can't load pdf content at the moment")
            }
        }
    }
    
    private func getDocument(completion: @escaping(_ document: PDFDocument?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: self.urlString), let document = PDFDocument(url: url) {
                completion(document)
            } else {
                completion(nil)
            }
        }
    }
    
    private func setDocumentToView(document: PDFDocument?) {
        if let document = document {
            DispatchQueue.main.async {
                let pdfView = PDFView(frame: self.view1.bounds)
                self.view1.addSubview(pdfView)
                pdfView.document = document
            }
        }
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        if screenFrom == .event{
            self.dismiss(animated: true)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
}
