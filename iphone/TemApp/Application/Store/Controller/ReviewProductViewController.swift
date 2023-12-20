//
//  ReviewProductViewController.swift
//  TemApp
//
//  Created by Shiwani Sharma on 23/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit
import SSNeumorphicView


// MARK: - DataClass
struct Productssss: Codable {
    let data: [Products]?
    let count: Int?
    let pageNo: [Int]?
    let current: Int?
//    let next: JSONNull?
    let last: Int?
//    let prev: JSONNull?
    let sr: Int?
}

struct Products: Codable {
    let productID: String?
    let rating: Int
    let image: [ProductImage]
    let variant: [Variant]
    let name: String?
    let id: String?
    
    enum CodingKeys: String, CodingKey {
        case productID = "product_id"
        case  rating, image
        case variant = "variants"
        case name = "product_name"
        case id  = "_id"
    }
}

struct ReviewProductsModal:Codable{
    let orderId:String?
    let product:Products?
    
    enum CodingKeys:String, CodingKey{
        case orderId = "order_id"
        case product = "product"
    }
}

// MARK: - Image
struct ProductImage: Codable {
    let id, product_id: Int
    let src: String
   
  
    enum CodingKeys: String, CodingKey {
        case id
        case product_id = "product_id"
     
        case  src
       
    }
}

// MARK: - Variant
struct Variant: Codable {
    let id, productID: Int
    let title, price: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case productID = "product_id"
        case title, price
    }
}
class ReviewProductViewController: DIBaseController {
    
    // MARK: @IBOutlet
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pendingButton: UIButton!
    @IBOutlet weak var publishedButton: UIButton!
    
    @IBOutlet  var ratingButton1: UIButton!
    @IBOutlet  var ratingButton2: UIButton!
    @IBOutlet  var ratingButton3: UIButton!
    @IBOutlet  var ratingButton4: UIButton!
    @IBOutlet  var ratingButton5: UIButton!
    
    @IBOutlet var lineShadowView: SSNeumorphicView! {
        didSet {
            lineShadowView.viewDepthType = .innerShadow
            lineShadowView.viewNeumorphicMainColor = lineShadowView.backgroundColor?.cgColor
            lineShadowView.viewNeumorphicLightShadowColor = UIColor.clear.cgColor
            lineShadowView.viewNeumorphicDarkShadowColor = UIColor.black.withAlphaComponent(0.8).cgColor
            lineShadowView.viewNeumorphicCornerRadius = 0
        }
    }
    
    // MARK: Variables
    var productList: [ReviewProductsModal] = [ReviewProductsModal]()
    var rating = 0
    lazy var ratingButtons = [ratingButton1,ratingButton2,ratingButton3,ratingButton4,ratingButton5]
    var selectedProduct: Int?
    var isPendingReviewSelected = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNibs(nibNames: [ProductReviewTableCell.reuseIdentifier])
        ratingView.isHidden = true
        getPendingReviewProducts()
        
    }
    
    // MARK: IBAction
    @IBAction func pendingButtonTapped(_ sender: UIButton) {
        configureViews(selectedBtn: sender, unselectedBtn: publishedButton)
        getPendingReviewProducts()
        isPendingReviewSelected = true
    }
    
    @IBAction func backTapped(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func crossTapped(_ sender: UIButton) {
        ratingView.isHidden = true
    }
    
    @IBAction func ratingButtonTapped(_ sender: UIButton) {
        rating = sender.tag
        for button in ratingButtons {
            if button?.tag ?? 0 <= sender.tag{
                button?.setBackgroundImage(UIImage(named: "star"), for: .normal)
            }else{
                button?.setBackgroundImage(UIImage(named: "star-2"), for: .normal)
            }
        }
        
    }
    @IBAction func publishedButtonTapped(_ sender: UIButton) {
        configureViews(selectedBtn: sender, unselectedBtn: pendingButton)
        getPublishedReviewProducts()
        isPendingReviewSelected = false
    }
    
    @IBAction func saveRatingTapped(_ sender: UIButton) {
        if rating == 0{
            showAlert(withTitle: "", message: "Please give at least one rating", okayTitle: AppMessages.AlertTitles.Ok)
        }else{
         //   self.showLoader()
            let params: [String : Any] = ["product_id": productList[selectedProduct ?? 0].product?.productID ?? 0, "rating": rating, "order_id":productList[selectedProduct ?? 0].orderId ?? "", "_id": productList[selectedProduct ?? 0].product?.id]
            DIWebLayerRetailAPI().setProductRating(params: params, completion: { msg in
                print("----------------\(msg)")
                self.hideLoader()
                self.showAlert(withTitle: "", message: msg, okayTitle: AppMessages.AlertTitles.Ok)
              self.getPendingReviewProducts()
            
            }, failure: { error in
                self.hideLoader()
                self.showAlert(withError: DIError(message: error.message), okayTitle: AppMessages.AlertTitles.Ok)
            })
            ratingView.isHidden = true
        }
        for button in ratingButtons{
            button?.setBackgroundImage(UIImage(named: "star-2"), for: .normal)
        }
    }
   
    
    // MARK: Helper Functions
    func configureViews(selectedBtn: UIButton, unselectedBtn: UIButton){
        selectedBtn.setBackgroundImage(UIImage(named: "blueRectangle"), for: .normal)
        selectedBtn.setTitleColor(.white, for: .normal)
        unselectedBtn.setBackgroundImage(UIImage(named: "whiteRectangle"), for: .normal)
        unselectedBtn.setTitleColor(.black, for: .normal)
    }
    
    func getPendingReviewProducts(){
        self.showLoader()
        DIWebLayerRetailAPI().getPendingReviewProducts(completion: { data in
            self.hideLoader()
            self.productList = data
            self.showTableStatus(dataCount: data.count)
            self.tableView.reloadData()
        }, failure: { error in
            self.hideLoader()
            self.showAlert(withError: DIError(message: error.message), okayTitle: AppMessages.AlertTitles.Ok)
        })
    }
    
    func getPublishedReviewProducts(){
        DIWebLayerRetailAPI().getPublishedReviewProducts(completion:{ data in
            self.hideLoader()
            self.productList = data
            self.showTableStatus(dataCount: data.count)
            self.tableView.reloadData()
        }, failure: { error in
            self.hideLoader()
            self.showAlert(withError: DIError(message: error.message), okayTitle: AppMessages.AlertTitles.Ok)
        })
    }
    
    private func showTableStatus(dataCount: Int){
        if dataCount == 0{
            self.tableView.showEmptyScreen("No Reviews available !")
        }else{
            self.tableView.showEmptyScreen("")
        }
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension ReviewProductViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: ProductReviewTableCell = tableView.dequeueReusableCell(withIdentifier: ProductReviewTableCell.reuseIdentifier) as? ProductReviewTableCell else{
            return UITableViewCell()
        }
        cell.setData(products: productList[indexPath.row].product)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isPendingReviewSelected{
            ratingView.isHidden = false
            self.selectedProduct = indexPath.row
        }else{
            ratingView.isHidden = true
         
        }
        
       
    }
    
}
