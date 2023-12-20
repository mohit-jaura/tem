//
//  ProductListingViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 13/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView

// New branch
protocol CategoryUiDelegate{
    func updateUI(index: Int)
}


struct ProductCategories{
    var name: String?
    var isSelected: Bool?
}

class ProductListingViewController: DIBaseController {
    
    
    // MARK: IBOutlets
    @IBOutlet weak var navBar: ProductNavbarView!
    @IBOutlet weak var productsCollView: UICollectionView!
    @IBOutlet weak var categoryCollView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var lineShadowView: SSNeumorphicView! {
        didSet { ver1(lineShadowView)}
    }
    @IBOutlet weak var bottomLineShadowView: SSNeumorphicView!{
        didSet{ ver1(bottomLineShadowView) }
    }
    
    // MARK: Variables
    var isReachedOfEnd = false {
        didSet {
            if isReachedOfEnd {
                productsCollView.cr.removeFooter()
            }
        }
    }
    var MAX_ProductListCount = 15

    var page = 0
    var isApiInProcess = false
    var searchString:String?
    var productList: [ProductInfo]?
    var categoryList: [CategoryInfo]?

    var selectedCategory:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Cart.apiToGetCart()
        getProducts()
        getProductsServerHandling()
    }
    
    // MARK: Helper Functions
    
    func configureView(){
        navBar.actionDelegate = self
        searchBar.setUI()
        
        notiForWishlistRefresh()
        collViewInitlaise()
        refreshLoadMoreinitialse()
        apiForCategories()
    }
    
    func collViewInitlaise() {
        productsCollView.delegate = self
        productsCollView.dataSource = self
        
        productsCollView.registerCell(ProductListCell.self)
        
        categoryCollView.registerCell(CategoryCell.self)
        
    }
    
    func getProductsServerHandling(){// backend api no need to handle on our end
        DIWebLayerJournalAPI().getProducts(completion: { response in
            self.apiForCategories()
        })
    }
    
    func notiForWishlistRefresh() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshWishlist), name: NSNotification.Name(rawValue: Constant.NotiName.wishListed), object: nil)
    }
    @objc func refreshWishlist( _ userInfo:Notification) {
        if let wishListdata = userInfo.userInfo as? [String:Any] {
            if let isLiked = wishListdata["isLiked"] as? Bool,let id = wishListdata["id"] as? String {
                if let index =  productList?.firstIndex(where: {$0.id == id}) {
                    productList?[index].isLiked = isLiked
                    self.productsCollView.reloadData()
                }
               
            }
        }
    }
    // MARK: Load More & Pull to Refresh
    
    func refreshLoadMoreinitialse() {
        /// animator: your customize animator, default is NormalHeaderAnimator
        productsCollView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            guard let self = self else {return}
            self.getProductsServerHandling()
            self.getProducts(0, completion: {
                self.productsCollView.cr.endHeaderRefresh()
            })
          
        }
        productsCollView.cr.addFootRefresh(animator: NormalFooterAnimator()) { [weak self] in
            self?.loadMoreData(completion: {
                DispatchQueue.main.async {
                    self?.productsCollView.cr.endLoadingMore()
                }
            })
        }
    }
    
    func loadMoreData(completion:@escaping OnlySuccess) {
        if self.isReachedOfEnd,self.isApiInProcess {return}
        self.page += 1
        getProducts(page,completion: completion)
    }
    
    

    func noDataFound() {
        isReachedOfEnd = true
        if page == 0 {
            self.productList = nil
        }
        productsCollView.reloadData()
    }
        
    // MARK: IBAction
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

// MARK: , UICollectionViewDataSource
extension ProductListingViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollView{
            return categoryList?.count ?? 0
        } else{
            if (self.productList?.count == 0 || self.productList == nil) {
                   self.productsCollView.setEmptyMessage("No products found")
               } else {
                   self.productsCollView.restore()
               }
            return productList?.count ?? 0

        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == categoryCollView{
            return categoryCell(indexPath)
        } else{
            return productCell(indexPath)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollView {
            updateUI(index: indexPath.row)
        }else {
            let detailPage: ProductsVC = UIStoryboard(storyboard: .shopping).initVC()
            detailPage.productInfo = productList?[indexPath.row]
            detailPage.id = productList?[indexPath.row].id
            self.navigationController?.pushViewController(detailPage, animated: true)
        }
        
    }
    
    func categoryCell(_ indexPath:IndexPath) -> UICollectionViewCell{
        guard let cell = categoryCollView.dequeueReusableCell(withReuseIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as? CategoryCell else{
            return UICollectionViewCell()
        }
        cell.tag = indexPath.item
        cell.setData(data: categoryList?[indexPath.row])
       // cell.containerViewSetup()
        cell.selectedIndex = {[weak self](indexSelected) in
            guard let self = self else {return}
            self.updateUI(index: indexSelected.item)
        }
        return cell
    }
    
    
    func productCell(_ indexPath:IndexPath) -> UICollectionViewCell {
        
        guard let cell = productsCollView.dequeueReusableCell(withReuseIdentifier: ProductListCell.reuseIdentifier, for: indexPath) as? ProductListCell else{
            return UICollectionViewCell()
        }
        cell.tag = indexPath.item
        cell.favouriteButton.tag = indexPath.item
        cell.addToCartButton.tag = indexPath.item
        let modal = productList?[indexPath.row]
        cell.setData(data: modal)
        cell.wishlistTapped = {[weak self](indexSel)in
            self?.apiForWishlistAdd(indexSel)
        }
        cell.cartTapped = {[weak self](indexSel)in
            self?.apiForCartAdd(indexSel)
        }
        return cell
    }
    

    
}

// MARK: UICollectionViewDelegateFlowLayout
extension ProductListingViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        if collectionView == categoryCollView{
            let width  = getWidth(indexPath: indexPath)
            return CGSize(width: width, height: 50)
        }else{
            let width  = (productsCollView.frame.width)/2
            return CGSize(width: width, height: width * 1.24)
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == categoryCollView {
            return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        }
        return UIEdgeInsets.zero
    }
    func getWidth( indexPath:IndexPath) ->CGFloat{
        let str  =  categoryList?[indexPath.item].categoryname
        let width = (str?.widthOfString(usingFont: UIFont(name: UIFont.avenirNextMedium, size: 15) ?? UIFont.systemFont(ofSize: 15)) ?? 150) + 35 + 20
        return width
        
    }
}

// MARK: UpdateUiDelegate
extension ProductListingViewController: CategoryUiDelegate{
    func updateUI(index: Int) {
        
        ///Avoid being hit api again if same category found
        if selectedCategory != categoryList?[index].categoryname  {
            categoryList = categoryList?.map({
                var temp = $0
                temp.isSelected = false
                return temp
                
            })
            page = 0
            selectedCategory =  categoryList?[index].categoryname ?? ""
            if selectedCategory == "All" {
                selectedCategory = "all"
            }
            
            let lastSel = categoryList?[index].isSelected ?? true
            
            categoryList?[index].isSelected = !lastSel
            
            categoryCollView.reloadData()
            
            getProducts()
            
        }
    }

}

extension ProductListingViewController: UISearchBarDelegate{
    @objc func searchByStr() {
        page = 0
        getProducts(page)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchString = searchBar.text?.trim
        
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(self.searchByStr), with: nil, afterDelay: 0.5)
    }
}

// MARK: Api Section
extension ProductListingViewController {
    func getProducts(_ page:Int = 0,completion:OnlySuccess?=nil){
       
        let searchCategory = selectedCategory?.trim
        
        let info = EndPoint.ProductSearch(category: searchCategory?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?.replacingOccurrences(of: "&", with: "%26") ?? "", str: searchString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?.replacingOccurrences(of: "&", with: "%26") ?? "",page)
        
        self.isApiInProcess = true
        
        DIWebLayerRetailAPI().getProducts(endPoint: info.url, parent:self) {[weak self] status, data, message in
            guard let self = self else  {return}
            self.isApiInProcess = false
            DispatchQueue.main.async {
                
                switch status {
                case .DataFound:
                    if let data = data as? [ProductInfo] {
                        self.isReachedOfEnd = data.count < self.MAX_ProductListCount
                        
                        if page == 0 {
                            self.productList = data
                        }else {
                            self.productList?.append(contentsOf: data)
                        }
                    }else {
                        if page == 0 {
                            self.productList = nil
                        }
                    }
                case .NoDataFound: self.noDataFound()
                case .Error:
                    self.showAlert(withTitle: "", message: message, okayTitle: AppMessages.CommanMessages.ok)
                    
                }
                self.productsCollView.reloadData()
                //If load more or refresh needed
                if completion != nil {   completion?()}
                
            }
        }
        
    }
    
    func apiForWishlistAdd(_ indexPath:IndexPath) {
        guard let id = productList?[indexPath.item].id  else {return}
        
        let isLiked = productList?[indexPath.item].isLiked ?? false
        
        let apiInfo = EndPoint.AddWishList(id, isWishlist: !isLiked)
        
        DIWebLayerRetailAPI().addWishlist(endPoint: apiInfo.url,params: apiInfo.params) {[weak self] status, optionalMsg in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                
                if status{
                    
                    self.productList?[indexPath.item].isLiked = !isLiked
                    
                    self.productsCollView.reloadItems(at: [indexPath])
                    
                }else {
                    self.showAlert(withError: DIError(message: optionalMsg), okayTitle: "Ok", cancelTitle: nil) {
                        } cancelCall: {}
                }
            }
        }
    }
    
    func apiForCategories() {
        let urlInfo = EndPoint.GetCategories
        
        DIWebLayerRetailAPI().getCategories(endPoint: urlInfo.url,params: nil) {[weak self] status in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                
                switch status {
                case .Success(let data, _):
                    if let data = data as? [CategoryInfo] {
                        self.categoryList = data
                        
                        let all = CategoryInfo("All")
                        self.categoryList?.insert(all, at: 0)
                        
                        self.categoryCollView.reloadData()
                        self.getProducts(0) {
                            Cart.apiToGetCart()
                        }
                    }
                case .NoDataFound:self.noDataFound()
                case .Failure(let error):
                    self.alertOpt(error)
                }
            }
        }
    }
    
    func apiForCartAdd(_ indexPath:IndexPath,_ variantId:Int? = nil) {
        //Need to open variants screen
        var variant_id = 0
        if variantId != nil{
            variant_id = variantId ?? 0
        }else{
            variant_id = productList?[indexPath.row].variants?.first?.id ?? 0
        }
        if productList?[indexPath.item].variants?.count ?? 0 > 1 && variantId == nil {
            
            let VC = loadVC(.PopVariantsVC) as! PopVariantsVC
            VC.variants = productList?[indexPath.item].variants
            VC.compleiton = {[weak self](id)in
                self?.apiForCartAdd(indexPath,id)
            }
           
            VC.modalTransitionStyle = .coverVertical
            VC.modalPresentationStyle = .overFullScreen
            
            self.present(VC, animated: true, completion: nil)
            
        }else {
        guard let id = productList?[indexPath.item].id  else {return}

            let apiInfo = EndPoint.AddCart(id: id ,isAddedNew: true, variantID: "\(variant_id)")
        
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
}

extension ProductListingViewController: ActionsDelegate{
    func navBarButtonsTapped(actionType: ActionType) {
        switch actionType {
        case .backAction:
            self.navigationController?.popViewController(animated: true)
        case .cartAction:
            let cartVC: CartManagementViewController = UIStoryboard(storyboard: .shopping).initVC()
            self.navigationController?.pushViewController(cartVC, animated: true)
        case .menuAction:
            let retailVC: RetailSettingsViewController = UIStoryboard(storyboard: .managecards).initVC()
            self.navigationController?.pushViewController(retailVC, animated: true)
        }
    }
    
    
}
