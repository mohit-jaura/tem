//
//  ProductsVC.swift
//  TemApp
//
//  Created by debut_mac on 13/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
enum ProdCellDesign{
    case Price
    case Feature1
    case Feature2
    case Desc
    
    var isHeaderRequired:Bool {
        switch self {
        case .Price,.Desc:
            return false
        default:
            return true
        }
    }
    var str:String? {
        switch self {
        case .Feature1:
            return "Variant:"
        case .Feature2:
            return "Select Size:"
        default :
            return nil
        }
    }
}
class AllVariants {
    var variants : [CustomVarients]!
    init(_ variants:[CustomVarients]) {
        self.variants = variants
    }
}

class ProductsVC: DIBaseController {
    var productInfo: ProductInfo?
    var id:String?
    var prodCellDesign : [ProdCellDesign] =  [.Price,.Desc]
    var headerView:ProductDetailsHeaderView?
    var variantsArr = [AllVariants]()
    @IBOutlet weak var navBar: ProductNavbarView!
    @IBOutlet weak var tableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialise()
    }
    func initialise() {
        navBar.actionDelegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCell(ProductFeaturesParentCell.self)
        tableView.registerCell(ProductPriceCell.self)
        tableView.registerCell(DescCell.self)

        headerForDetails()
        navBar.cartMenuStackView.isHidden = false
        navBar.numberLabel.isHidden = false
  
        apiForDetails()

    }
    func notificationForLike(_ isLiked:Bool) {
        let notifData:[String:Any] = ["isLiked":isLiked,"id":productInfo?.id ?? ""]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.NotiName.wishListed), object: nil,userInfo: notifData)
    }
    func headerForDetails() {
        if let header = Bundle.main.loadNibNamed(ProductDetailsHeaderView.identifier, owner: self)?.first as? ProductDetailsHeaderView {
            self.headerView = header
            headerView?.images = productInfo?.image
            headerView?.initialse()
            headerView?.isLiked = productInfo?.isLiked
            headerView?.likeTapped = {
                self.apiForLike()
            }
            tableView.tableHeaderView = headerView
        }
    }
    
    func manageUI() {
        
        if let variants = productInfo?.variants,variants.first?.option1 != "Default Title" {
            let option1 = Array(Set(variants.map({return $0.option1 ?? ""})))
            let option2 = Array(Set(variants.map({return $0.option2 ?? ""})))
            let option3 = Array(Set(variants.filter({$0.option3 != nil }).map({   return $0.option3 ?? ""})))
            
            print(option1)
            print(option2)
            print(option3)
            var variant1:[CustomVarients] = []
            var variant2:[CustomVarients] = []
            var variant3:[CustomVarients] = []
            
            for i in 0..<option1.count {
                let sizeModal = CustomVarients(option1[i], i == 0 )
                variant1.append(sizeModal)
            }
            for i in 0..<option2.count {
                let sizeModal = CustomVarients(option2[i], i == 0 )
                variant2.append(sizeModal)
            }
            for i in 0..<option3.count {
                let sizeModal = CustomVarients(option3[i], i == 0 )
                variant3.append(sizeModal)
            }
                        
            if variant1.count > 0 {
                prodCellDesign.insert(.Feature1, at: 1)
                variantsArr.append(AllVariants( variant1))
            }
            if variant2.count > 0 {
                prodCellDesign.insert(.Feature1, at: 1)
                variantsArr.append(AllVariants( variant2))
            }
            if variant3.count > 0 {
                prodCellDesign.insert(.Feature1, at: 1)
                variantsArr.append(AllVariants(variant3))
            }
            tableView.reloadData()
        }
    }
    func noDataFound() {
        
    }
    
    @IBAction func addToCartAction(_ sender: Any) {
        apiForCartAdd()
    }
}

// MARK: UICollection Method
extension ProductsVC:UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return prodCellDesign.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cellAccToDesign( prodCellDesign[indexPath.section],indexPath)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 18))
        //view.backgroundColor = .blue
        let label = UILabel(frame: CGRect(x: 12, y: 0, width: tableView.frame.width, height: 18))
        label.text = "Variant \(section):"
        label.font = UIFont(name: UIFont.avenirNextRegular, size: 13)
        label.textAlignment = .left
        view.addSubview(label)
        return view
    }
    
    
    func cellAccToDesign(_ design:ProdCellDesign,_ indexPath:IndexPath) ->UITableViewCell {
        switch design {
        case .Price: return  priceCell(indexPath)
        case .Feature1: return  sizeCell(indexPath)
        case .Feature2: return  colorCell(indexPath)
        case .Desc: return descCell(indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  prodCellDesign[section].isHeaderRequired ? 18 : .leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
}
// MARK: Table Cells
extension ProductsVC {
    func descCell(_ indexPath:IndexPath) ->UITableViewCell {
        guard let descCell = tableView.dequeueReusableCell(withIdentifier: DescCell.identifier, for: indexPath) as? DescCell else {return UITableViewCell()}
        descCell.titleLabel.attributedText = productInfo?.body_html?.html2String
        
        return descCell
    }
    
    func colorCell(_ indexPath:IndexPath) ->UITableViewCell {
        guard let colorCell = tableView.dequeueReusableCell(withIdentifier: ProductFeaturesParentCell.identifier, for: indexPath) as? ProductFeaturesParentCell else {return UITableViewCell()}
        colorCell.isColorInitialise = true
        return colorCell
        
    }
    func sizeCell(_ indexPath:IndexPath) ->UITableViewCell {
        guard let sizeCell = tableView.dequeueReusableCell(withIdentifier: ProductFeaturesParentCell.identifier, for: indexPath) as? ProductFeaturesParentCell else {return UITableViewCell()}
        sizeCell.tag = indexPath.section - 1
        sizeCell.isColorInitialise = false
        sizeCell.variant = variantsArr[indexPath.section - 1].variants
        
        return sizeCell
    }
    func priceCell(_ indexPath:IndexPath) ->UITableViewCell {
        guard let priceCell = tableView.dequeueReusableCell(withIdentifier: ProductPriceCell.identifier, for: indexPath) as? ProductPriceCell else {return UITableViewCell()}
        priceCell.initialse(productInfo)
        return priceCell
        
    }
    
}
// MARK: Api Methods
extension ProductsVC {
    func apiForDetails() {
        let urlInfo = EndPoint.ProductDetails(id ?? "")
        DIWebLayerRetailAPI().getProductDetails(endPoint: urlInfo.url,parent:self) {[weak self] status in
            DispatchQueue.main.async {
                
                switch status {
                case .Success(let data, _):
                    if let data = data as? ProductInfo {
                        self?.productInfo = data
                        self?.headerForDetails()
                        self?.manageUI()
                        self?.tableView.reloadData()
                    }
                case .NoDataFound:self?.noDataFound()
                case .Failure(let error):
                    self?.alertOpt(error)
                }
            }
            
        }
    }
    func getVariantID() ->String{
        var selVarComb = [String]()
        for i in 0..<variantsArr.count {
            selVarComb.append(variantsArr[i].variants.filter({$0.isSelected}).first?.name ?? "")
        }
        var variants = productInfo?.variants
        for i in 0..<selVarComb.count {
            variants =    variants?.filter({$0.option1 == selVarComb[i] || $0.option2 == selVarComb[i] || $0.option3 == selVarComb[i]}) ?? []
        }
        print(variants?.first?.id)
        return "\(variants?.first?.id ?? 0)"
    }
    func apiForCartAdd() {
        guard let id = productInfo?.id  else {return}
        

        //let oldQnty = productInfo?.isAddedInCart?.first?.quantity ?? 0
        
        let apiInfo = EndPoint.AddCart(id: id, isAddedNew: true, variantID: getVariantID())

        
        DIWebLayerRetailAPI().addtoCart(endPoint: apiInfo.url,parent: self, params: apiInfo.params) {[weak self] status, optionalMsg in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                
                if status{
                    self.alertOpt(optionalMsg)
                    Cart.apiToGetCart()
                }else {
                    self.alertOpt(optionalMsg)
                }
            }
        }
    }
    func apiForLike() {
        guard let id = productInfo?.id  else {return}
        
        let isLiked = productInfo?.isLiked ?? false
        
        let apiInfo = EndPoint.AddWishList(id, isWishlist: !isLiked)
        
        DIWebLayerRetailAPI().addWishlist(endPoint: apiInfo.url,parent:self, params: apiInfo.params) {[weak self] status, optionalMsg in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                
                if status{
                    self.headerView?.isLiked = !isLiked
                    self.notificationForLike(!isLiked)
                    self.tableView.reloadData()
                }else {
                    self.alertOpt(optionalMsg)
                }
            }
        }
    }
}

extension ProductsVC: ActionsDelegate{
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
