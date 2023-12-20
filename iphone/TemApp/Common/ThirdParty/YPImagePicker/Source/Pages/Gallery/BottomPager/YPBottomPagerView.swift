//
//  YPBottomPagerView.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 24/01/2018.
//  Copyright © 2016 Capovela LLC. All rights reserved.
//

import UIKit

final class YPBottomPagerView: UIView {
    
    var header = YPPagerMenu()
    var scrollView = UIScrollView()
    
    convenience init() {
        self.init(frame: .zero)
        backgroundColor = UIColor(red: 239/255, green: 238/255, blue: 237/255, alpha: 1)
        
        sv(
            scrollView,
            header
        )
        
        layout(
            0,
            |scrollView|,
            0,
            |header| ~ 44
        )
        
        if #available(iOS 11.0, *) {
            header.Bottom == safeAreaLayoutGuide.Bottom
        } else {
            header.bottom(0)
        }
        header.heightConstraint?.constant = YPConfig.hidesBottomBar ? 0 : 44
        
        clipsToBounds = false
        setupScrollView()
    }

    private func setupScrollView() {
        scrollView.clipsToBounds = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.bounces = false
    }
}
