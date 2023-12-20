//
//  ProductFeaturesParentCell.swift
//  TemApp
//
//  Created by debut_mac on 14/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

struct Demo {
    var color :UIColor
    var isSelected:Bool
}
class ProductFeaturesParentCell: UITableViewCell {
    var variant : [CustomVarients]? {
        didSet {
            self.featureCollView.reloadData()
        }
    }
    var indexSelected:IndexSelected?
    var colorType : [SizeType]? {
        didSet {
            self.featureCollView.reloadData()
        }
    }
    let colors:[UIColor] = [.blue,.green,.red]
   // let size:[String] = ["M","XL","S"]
    var demo = [Demo]()
    var isColorInitialise:Bool = false
    @IBOutlet weak var featureCollView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialise()
    }
    func initialise() {
        featureCollView.delegate  = self
        featureCollView.dataSource  =  self
        featureCollView.registerCell(ProductFeatureCell.self)
        featureCollView.reloadData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
// MARK: CollectionView Methods
extension ProductFeaturesParentCell: UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = (isColorInitialise ? colorType?.count ?? 0 : variant?.count ?? 0)
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductFeatureCell.identifier, for: indexPath) as? ProductFeatureCell else {
            return UICollectionViewCell()
        }
        cell.titleLabels.isHidden = isColorInitialise
        cell.containerView.backgroundColor = isColorInitialise ? colors[indexPath.item] : .white
        
        var isSelected = variant?[indexPath.item].isSelected ?? false
        
        cell.containerView.layer.borderColor = isSelected ? UIColor.appThemeColor.cgColor : UIColor.lightGray.cgColor
        
        cell.containerView.layer.borderWidth = isSelected ? 3 : 1
        
        cell.titleLabels.text = isColorInitialise ? "\(variant?[indexPath.row].name ?? "0")" : "\(variant?[indexPath.row].name ?? "X")"
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isColorInitialise {
            colorType =   colorType?.map({$0
                var temp = $0
                temp.isSelected = false
                return temp
            })
            colorType?[indexPath.row].isSelected = true
            collectionView.reloadData()
        }else {
            variant =   variant?.map({$0
                var temp = $0
                temp.isSelected = false
                return temp
            })
            variant?[indexPath.item].isSelected = true
            indexSelected?(IndexPath(item: indexPath.item, section: self.tag))
            collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: featureCollView.frame.height ,height: featureCollView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
   
}

    

