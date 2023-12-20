//
//  AlertBox.swift
//  TemApp
//
//  Created by Shiwani Sharma on 04/03/23.
//  Copyright © 2023 Capovela LLC. All rights reserved.
//

import Foundation

protocol NSAlertProtocol {
    func showAlert(withTitle title: String, message: String)
    func showAlert(withMessage message: String)
    func showAlert(withTitle title: String, message: String, okayTitle: String, cancelTitle: String, okStyle: UIAlertAction.Style, okCall: @escaping () -> (), cancelCall: @escaping () -> ())
}

extension NSAlertProtocol where Self: UIViewController {
    func showAlert(withMessage message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: AppMessages.AlertTitles.Ok, style: .default, handler: { (action) in

        }))
        present(alert, animated: true, completion: nil)
    }

    func showAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: AppMessages.AlertTitles.Ok, style: .default, handler: { (action) in

        }))
        present(alert, animated: true, completion: nil)
    }

    func showAlert(withTitle title: String, message: String, okayTitle: String, cancelTitle: String, okStyle: UIAlertAction.Style, okCall: @escaping () -> (), cancelCall: @escaping () -> ()) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okayTitle, style: okStyle, handler: { (action) in
            okCall()
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: { (action) in
            cancelCall()
        }))
        present(alert, animated: true, completion: nil)
    }
}
