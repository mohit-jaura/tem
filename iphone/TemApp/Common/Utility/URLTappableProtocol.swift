//
//  URLTappableProtocol.swift
//  TemApp
//
//  Created by shilpa on 13/08/20.
//  Copyright © 2020 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit
protocol URLTappableProtocol where Self: UIViewController {
    func pushToSafariVCOnUrlTap(url: URL)
}

extension URLTappableProtocol {
    func pushToSafariVCOnUrlTap(url: URL) {
        var urlStr = url.absoluteString
        if !urlStr.lowercased().contains("http://") {
            if !urlStr.lowercased().contains("https://") {
                urlStr = "http://".appending(urlStr)
            }
        }
        if urlStr.first == "." {
            urlStr.removeFirst()
        }
        if let url = URL(string: urlStr) {
            DispatchQueue.main.async {
                let vc = SFSafariViewController(url: url)
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
}
