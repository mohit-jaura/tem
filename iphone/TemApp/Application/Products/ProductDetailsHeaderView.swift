//
//  ProductDetailsHeaderView.swift
//  TemApp
//
//  Created by debut_mac on 13/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import Cosmos
class ProductDetailsHeaderView: UIView {
   
    @IBOutlet weak var pageViewController: UIPageControl!
    @IBOutlet weak var imageCollView: UICollectionView!
    @IBOutlet weak var likeButOut: UIButton!

    var likeTapped:OnlySuccess?
    var images :[ImageInfo]?
    var isLiked:Bool? {
        didSet {
            let img = isLiked ?? false ? UIImage.fav : UIImage.nofav
            likeButOut.setImage(img, for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialse()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialse()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        likeButOut.shadowVer1()
    }
    func initialse() {
        imageCollView?.delegate = self
        imageCollView?.dataSource = self
        imageCollView?.registerCell(ProImgCarouselCell.self)
        pageViewController?.isHidden = images?.count ?? 0 <= 1
        likeButOut?.shadowVer1()
        pageContManaged()

    }
    
    
    func pageContManaged() {
        pageViewController?.numberOfPages = images?.count ?? 0
        pageViewController?.isHidden = images?.count ?? 0 <= 1
    }
    
    @IBAction func likeButAction(_ sender: Any) {
        likeButOut.animateTapEffect(1.7)
        likeTapped?()
    }
    
}
// MARK: UICollectionViewDelegate,UICollectionViewDataSource
extension ProductDetailsHeaderView: UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images?.count ?? 1
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()

        visibleRect.origin = imageCollView.contentOffset
        visibleRect.size = imageCollView.bounds.size

        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)

        guard let indexPath = imageCollView.indexPathForItem(at: visiblePoint) else { return }
        pageViewController.currentPage = indexPath.item

        print(indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProImgCarouselCell.identifier, for: indexPath) as? ProImgCarouselCell else {
            return UICollectionViewCell()
        }
        let imageURL = images?[indexPath.row].src
        cell.proImgView.setImg(imageURL)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //pageViewController.currentPage = indexPath.item
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: imageCollView.frame.width , height: imageCollView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    

   
   
}
extension UICollectionView {
    func registerCell(_ type:UICollectionViewCell.Type) {
        register(type.nib, forCellWithReuseIdentifier: type.identifier)
    }
    func deque(_ type:UICollectionViewCell.Type,_ indexPath:IndexPath) -> UICollectionViewCell? {
        return self.dequeueReusableCell(withReuseIdentifier: type.reuseIdentifier, for: indexPath)
    }
    }

extension UITableView {
    func registerCell(_ type:UITableViewCell.Type) {
        register(type.nib, forCellReuseIdentifier: type.identifier)
    }
}
