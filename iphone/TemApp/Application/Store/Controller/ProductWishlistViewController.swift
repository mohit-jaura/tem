//
//  ProductWishlistViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 15/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

class ProductWishlistViewController: DIBaseController {
    // MARK: Variables
    
    var productList: [ProductInfo] = [ProductInfo]()
    var screenFrom:Constant.ScreenFrom = .checkoutCart
    
    // MARK: IBOutlets
    
    @IBOutlet weak var productListingCollectionView: UICollectionView!
    @IBOutlet var lineShadowView: SSNeumorphicView! {
        didSet {
          setShadow(view: lineShadowView)
        }
    }
    
    @IBOutlet weak var titleLbl:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        productListingCollectionView.registerNibsForCollectionView(nibNames: [ProductListCell.reuseIdentifier])
   //     notiForWishlistRefresh()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if screenFrom == .retailNotification{
            titleLbl.text = screenFrom.title
        }else{
            getWishlist()
        }
    }
    // MARK: Helper Functions
    
    func setShadow(view: SSNeumorphicView){
        view.viewDepthType = .innerShadow
        view.viewNeumorphicMainColor = view.backgroundColor?.cgColor
        view.viewNeumorphicLightShadowColor = UIColor.clear.cgColor
        view.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.8).cgColor
        view.viewNeumorphicCornerRadius = 0
    }
    func getWishlist(){
        self.showLoader()
        DIWebLayerRetailAPI().getWishlist( completion: { data in
            self.hideLoader()
            self.productList = data
            if data.count == 0{
                self.productListingCollectionView.showEmptyScreen("No product added yet!")
            }
            self.productListingCollectionView.reloadData()
            
        }, failure: { error in
            self.hideLoader()
            
        })

    }
    
//    func notiForWishlistRefresh() {
//        NotificationCenter.default.addObserver(self, selector: #selector(refreshWishlist), name: NSNotification.Name(rawValue: Constant.NotiName.wishListed), object: nil)
//    }
//
//    @objc func refreshWishlist( _ userInfo:Notification) {
//        if let wishListdata = userInfo.userInfo as? [String:Any] {
//            if let isLiked = wishListdata["isLiked"] as? Bool,let id = wishListdata["id"] as? String {
//                if let index =  productList.firstIndex(where: {$0.id == id}) {
//                    productList[index].isLiked = isLiked
//                    self.productListingCollectionView.reloadData()
//                }
//
//            }
//        }
//    }
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func apiForWishlistAdd(_ indexPath:IndexPath) {
        guard let id = productList[indexPath.item].id  else {return}
        
        let isLiked = productList[indexPath.item].isLiked ?? false
        
        let apiInfo = EndPoint.AddWishList(id, isWishlist: !isLiked)
        
        DIWebLayerRetailAPI().addWishlist(endPoint: apiInfo.url,params: apiInfo.params) {[weak self] status, optionalMsg in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                
                if status{
                    
                    self.productList[indexPath.item].isLiked = !isLiked
                    
                    self.productListingCollectionView.reloadItems(at: [indexPath])
                    
                    self.getWishlist()
                }else {
                    self.showAlert(withError: DIError(message: optionalMsg), okayTitle: "Ok", cancelTitle: nil) {
                        } cancelCall: {}
                }
            }
        }
    }
    func apiForCartAdd(_ indexPath:IndexPath,_ variantId:Int? = nil) {
        //Need to open variants screen
        if productList[indexPath.item].variants?.count ?? 0 > 1 && variantId == nil {
            
            let VC = loadVC(.PopVariantsVC) as! PopVariantsVC
            VC.variants = productList[indexPath.item].variants
            VC.compleiton = {[weak self](id)in
                self?.apiForCartAdd(indexPath,id)
            }
           
            VC.modalTransitionStyle = .coverVertical
            VC.modalPresentationStyle = .overFullScreen
            
            self.present(VC, animated: true, completion: nil)
            
        }else {
        guard let id = productList[indexPath.item].id  else {return}

        let apiInfo = EndPoint.AddCart(id: id ,isAddedNew: true, variantID: "\(productList[indexPath.row].variants?.first?.id ?? 0)")
        
        DIWebLayerRetailAPI().addtoCart(endPoint: apiInfo.url,params: apiInfo.params) {[weak self] status, optionalMsg in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                
                if status{
                    self.alertOpt(optionalMsg)
                    Cart.apiToGetCart()
                }else {
                    self.showAlert(withError: DIError(message: optionalMsg), okayTitle: "Ok", cancelTitle: nil) {
                        } cancelCall: {}
                }
            }
        }
        }
    }
//    func apiForCartAdd(_ indexPath:IndexPath,_ variantId:Int? = nil) {
//        //Need to open variants screen
//        if productList[indexPath.item].variants?.count ?? 0 > 1 && variantId == nil {
//
//            let VC = loadVC(.PopVariantsVC) as! PopVariantsVC
//            VC.variants = productList[indexPath.item].variants
//            VC.compleiton = {[weak self](id)in
//                self?.apiForCartAdd(indexPath,id)
//            }
//
//            VC.modalTransitionStyle = .coverVertical
//            VC.modalPresentationStyle = .overFullScreen
//
//            self.present(VC, animated: true, completion: nil)
//
//        }else {
//            guard let id = productList[indexPath.item].id  else {return}
//
//            let apiInfo = EndPoint.AddCart(id: id ,isAddedNew: true, variantID: "\(productList[indexPath.row].variants?.first?.id ?? 0)")
//
//        DIWebLayerRetailAPI().addtoCart(endPoint: apiInfo.url,params: apiInfo.params) {[weak self] status, optionalMsg in
//
//            guard let self = self else {return}
//
//            DispatchQueue.main.async {
//
//                if status{
//                    self.alertOpt(optionalMsg)
//                    Cart.apiToGetCart()
//                }else {
//                    self.showAlert(withError: DIError(message: optionalMsg), okayTitle: "Ok", cancelTitle: nil) {
//                        } cancelCall: {}
//                }
//            }
//        }
//        }
//    }
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource
extension ProductWishlistViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
     
            return productList.count
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductListCell.reuseIdentifier, for: indexPath) as? ProductListCell else{
                return UICollectionViewCell()
            }
        cell.addToCartButton.tag = indexPath.item
        cell.favouriteButton.tag = indexPath.item
            cell.setData(data: productList[indexPath.row])
        cell.wishlistTapped = {[weak self](indexSel)in
            self?.apiForWishlistAdd(indexSel)
        }
        cell.cartTapped = {[weak self](indexSel)in
            self?.apiForCartAdd(indexSel)
        }
            return cell
        }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailPage = loadVC(.ProductsVC) as! ProductsVC
        detailPage.productInfo = productList[indexPath.row]
        detailPage.id = productList[indexPath.row].id
        NavigTO.navigateTo?.navigation?.pushViewController(detailPage, animated: true)
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension ProductWishlistViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let width  = (collectionView.frame.width)/2
        return CGSize(width: width, height: width * 1.24)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
}
