//
//  StackView+Extensions.swift
//  TemApp
//
//  Created by Egor Shulga on 17.12.20.
//  Copyright © 2020 Capovela LLC. All rights reserved.
//

import Foundation

extension UIStackView {
    func removeFully(view: UIView) {
        removeArrangedSubview(view)
        view.removeFromSuperview()
    }

    func removeFullyAllArrangedSubviews() {
        arrangedSubviews.forEach { (view) in
            removeFully(view: view)
        }
    }
}
