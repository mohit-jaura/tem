//
//  SkeletonReusableCell.swift
//  SkeletonView-iOS
//
//  Created by Juanpe Catalán on 30/03/2018.
//  Copyright © 2018 Capovela LLC. All rights reserved.
//

import UIKit

public protocol SkeletonReusableCell { }

extension UITableViewCell: SkeletonReusableCell { }

extension UICollectionViewCell: SkeletonReusableCell { }
