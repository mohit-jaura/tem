//
//  ProductModal.swift
//  TemApp
//
//  Created by PrabSharan on 23/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//


import Foundation
class CustomVarients {
    var name:String?
    var isSelected:Bool = false
    init(_ name:String,_ isSelected:Bool) {
        self.name = name
        self.isSelected = isSelected
    }
}
//struct ProductViewModal {
//
//
//    init(_ productInfo:ProductInfo) {
//
//    }
//}


struct ProductsFullData : Codable {
    let status : Int?
    let message : String?
    let data : ProductData?

    enum CodingKeys: String, CodingKey {

        case status = "status"
        case message = "message"
        case data = "data"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        data = try values.decodeIfPresent(ProductData.self, forKey: .data)
    }

}
struct ProductData : Codable {
    let data : [ProductInfo]?
    let count : Int?
   

    enum CodingKeys: String, CodingKey {

        case data = "data"
        case count = "count"
      
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent([ProductInfo].self, forKey: .data)
        count = try values.decodeIfPresent(Int.self, forKey: .count)
      
    }

}

struct RetailNotifications: Codable{
    let notificationId: String?
    let message: String?
    let createdAt: String?
    let orderData: OrderData?
    
    enum CodingKeys: String, CodingKey{
        case notificationId = "_id"
        case message = "message"
        case createdAt = "created_at"
        case orderData = "orderdata"
    }
}

struct OrderData:Codable{
    let productData:[ProductInfo]?
    
    enum CodingKeys:String, CodingKey{
        case productData = "productData"
    }
}

struct ProductInfo : Codable {
    let id : String?
    let product_id:String?
    let variant_id:Int?
    var rating :Double? = 0
    let product_name : String?
    let body_html : String?
    let image : [ImageInfo]?
    let variants : [Variants]?
    var isLiked : Bool?
    var quantity:Int?
    var average_rating:Double?
    let isAddedInCart : [AddedInCart]?

    enum CodingKeys: String, CodingKey {
        case  quantity = "quantity"
        case average_rating = "average_rating"
        case id = "_id"
        case rating = "rating"
        case variant_id = "variant_id"
        case product_id = "product_id"
        case product_name = "product_name"
        case body_html = "body_html"
        case image = "image"
        case variants = "variants"

        case isLiked = "isLiked"
       case isAddedInCart = "isAddedInCart"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        quantity = try values.decodeIfPresent(Int.self, forKey: .quantity)
        product_id = try values.decodeIfPresent(String.self, forKey: .product_id)
        rating = try values.decodeIfPresent(Double.self, forKey: .rating)
        average_rating = try values.decodeIfPresent(Double.self, forKey: .average_rating)
        variant_id = try values.decodeIfPresent(Int.self, forKey: .variant_id)
        product_name = try values.decodeIfPresent(String.self, forKey: .product_name)
        body_html = try values.decodeIfPresent(String.self, forKey: .body_html)
        image = try values.decodeIfPresent([ImageInfo].self, forKey: .image)
        variants = try values.decodeIfPresent([Variants].self, forKey: .variants)
        isLiked = try values.decodeIfPresent(Bool.self, forKey: .isLiked)
        isAddedInCart = try values.decodeIfPresent([AddedInCart].self, forKey: .isAddedInCart)
    }

}
struct ImageInfo : Codable {
    let id : Int?
    let product_id : Int?
    let src : String?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case product_id = "product_id"
        case src = "src"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        product_id = try values.decodeIfPresent(Int.self, forKey: .product_id)
        src = try values.decodeIfPresent(String.self, forKey: .src)
    }

}



struct Variants : Codable {
    let id : Int?
    let product_id : Int?
    let title : String?
    let price : String?
    let sku : String?
    let option1 : String?
    let option2 : String?
    let option3 : String?
    let grams : Double?
    let weight : Double?
    let weight_unit : String?

   
    enum CodingKeys: String, CodingKey {

        case id = "id"
        case product_id = "product_id"
        case title = "title"
        case price = "price"
        case sku = "sku"
        case option1 = "option1"
        case option2 = "option2"
        case option3 = "option3"
        case grams = "grams"
        case weight = "weight"
        case weight_unit = "weight_unit"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        product_id = try values.decodeIfPresent(Int.self, forKey: .product_id)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        price = try values.decodeIfPresent(String.self, forKey: .price)
        sku = try values.decodeIfPresent(String.self, forKey: .sku)
        option1 = try values.decodeIfPresent(String.self, forKey: .option1)
        option2 = try values.decodeIfPresent(String.self, forKey: .option2)
        option3 = try values.decodeIfPresent(String.self, forKey: .option3)
        grams = try values.decodeIfPresent(Double.self, forKey: .grams)
        weight = try values.decodeIfPresent(Double.self, forKey: .weight)
        weight_unit = try values.decodeIfPresent(String.self, forKey: .weight_unit)
    }

}
