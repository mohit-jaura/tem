//
//  DIWebLayerRetailAPI.swift
//  TemApp
//
//  Created by Shiwani Sharma on 15/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit

class DIWebLayerRetailAPI: DIWebLayer{
    
    
    func addtoCart(endPoint:String,parent:DIBaseController? = nil,  isLoader:Bool = true,  params:Parameters? = nil, completion: @escaping CompletionSuccessError){
      
        if isLoader { parent?.showLoader() }

        self.webManager.post(method: .post, function: endPoint, parameters: params) { data in
            // Parse Data Here & convert it into modal
            DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }
             //Check Error Once
            do {
                let modal   = try JSONDecoder().decode(DefaultModal.self, from: data)
                
                completion( modal.status == 1 ,modal.message)
                
            }
            catch let error {
                debugPrint(error.localizedDescription)
                completion(false,DIError.invalidData().message)
            }
            

            }
         failure: { error in
             DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }

            completion(false,error.message)
        }
    }
    
    
    
    func productDetails(endPoint:String,parent:DIBaseController? = nil,  isLoader:Bool = true,  params:Parameters? = nil, completion: @escaping CompletionWithData){
        
        if isLoader { parent?.showLoader() }

        self.webManager.post(method: .get, function: endPoint, parameters: params) { data in
            // Parse Data Here & convert it into modal
            DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }

             //Check Error Once
            do {
                let modal   = try JSONDecoder().decode(ProductModal.self, from: data)
                
                let isDataFound:ResponseIn =  modal.data?.data?.count ?? 0 > 0 ? .DataFound : .NoDataFound

                if modal.status == 1 {
                    completion(isDataFound,modal.data?.data,Constant.ErrorMsg.noDataFound)

                }else {
                    completion(isDataFound,modal.data?.data,modal.message)
                }
                
                completion(isDataFound,modal.data?.data,Constant.ErrorMsg.noDataFound)

            }
            catch let error {
                debugPrint(error.localizedDescription)
                completion(.Error,nil,DIError.invalidData().message)
            }
            

            }
         failure: { error in
             DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }

            completion(.Error,nil,error.message)
        }
    }
    
    func addWishlist(endPoint:String,parent:DIBaseController? = nil,  isLoader:Bool = true,  params:Parameters? = nil, completion: @escaping CompletionSuccessError){
      
        if isLoader { parent?.showLoader() }

        self.webManager.post(method: .post, function: endPoint, parameters: params) { data in
            // Parse Data Here & convert it into modal
            DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }

             //Check Error Once
            do {
                let modal   = try JSONDecoder().decode(DefaultModal.self, from: data)
                
                completion( modal.status == 1 ,modal.message)
                
            }
            catch let error {
                debugPrint(error.localizedDescription)
                completion(false,DIError.invalidData().message)
            }
            

            }
         failure: { error in
             DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }

            completion(false,error.message)
        }
    }
    
    func getCategories(endPoint:String,parent:DIBaseController? = nil,  isLoader:Bool = true,  params:Parameters? = nil, completion: @escaping CompletionDataApi){
        if isLoader { parent?.showLoader() }


        self.webManager.post(method: .get, function: endPoint, parameters: params) { data in
            // Parse Data Here & convert it into modal
            DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }

             //Check Error Once
            do {
                let modal   = try JSONDecoder().decode(CategoryData.self, from: data)
                //Look for data is there or not
                let isDataFound = modal.data?.count ?? 0 != 0
                                
                //Look for backend status 1 or 0
                
                let isSuccess = modal.status == 1
                
                let response:ResponseData = isSuccess ?  (isDataFound ?  .Success(modal.data,modal.message) : .NoDataFound ) :   .Failure(modal.message)

                completion(response)
                
            }
            catch let error {
                debugPrint(error)
                completion(.Failure(DIError.invalidData().message))
            }
            

            }
         failure: { error in
             DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }

             completion(.Failure(error.message))
        }
    }
    
    func getProductDetails(endPoint:String,parent:DIBaseController? = nil,  isLoader:Bool = true,  params:Parameters? = nil, completion: @escaping CompletionDataApi){
      
        if isLoader { parent?.showLoader() }

        self.webManager.post(method: .get, function: endPoint, parameters: params) { data in
            // Parse Data Here & convert it into modal
            DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }

             //Check Error Once
            do {
                let modal   = try JSONDecoder().decode(ProductDetailModal.self, from: data)
                //Look for data is there or not
                
                
                let isSuccess = modal.status == 1
                
                let isDataFound = modal.data != nil
                
                let response:ResponseData = isSuccess ?  (isDataFound ?  .Success(modal.data,modal.message) : .NoDataFound ) :   .Failure(modal.message)

                completion(response)
                
            }
            catch let error {
                debugPrint(error)
                completion(.Failure(DIError.invalidData().message))
            }
            

            }
         failure: { error in
             DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }

             completion(.Failure(error.message))
        }
    }
    
    func getCart(endPoint:String,parent:DIBaseController? = nil,  isLoader:Bool = true,  params:Parameters? = nil, completion: @escaping CompletionDataApi){
      
        if isLoader { parent?.showLoader() }

        self.webManager.post(method: .get, function: endPoint, parameters: params) { data in
            // Parse Data Here & convert it into modal
            DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }

             //Check Error Once
            do {
                let modal   = try JSONDecoder().decode(DefaultModal.self, from: data)
                //Look for data is there or not
                let isDataFound = modal.data?.count ?? 0 != 0
                
                Cart.addToCart(modal.data?.count ?? 0)
                
                //Look for backend status 1 or 0
                
                let isSuccess = modal.status == 1
                
                let response:ResponseData = isSuccess ?  (isDataFound ?  .Success(modal.data,modal.message) : .NoDataFound ) :   .Failure(modal.message)

                completion(response)
                
            }
            catch let error {
                debugPrint(error)
                completion(.Failure(DIError.invalidData().message))
            }
            

            }
         failure: { error in
             DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }

             completion(.Failure(error.message))
        }
    }
    
    func getProducts(endPoint:String,parent:DIBaseController? = nil,  isLoader:Bool = true,  params:Parameters? = nil, completion: @escaping CompletionWithData){
      
        if isLoader { parent?.showLoader() }

        self.webManager.post(method: .get, function: endPoint, parameters: params) { data in
            // Parse Data Here & convert it into modal
            DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }

             //Check Error Once
            do {
                let modal   = try JSONDecoder().decode(ProductsFullData.self, from: data)
                
                let isDataFound:ResponseIn =  modal.data?.data?.count ?? 0 > 0 ? .DataFound : .NoDataFound

                if modal.status == 1 {
                    completion(isDataFound,modal.data?.data,Constant.ErrorMsg.noDataFound)

                }else {
                    completion(isDataFound,modal.data?.data,modal.message)
                }
                
                completion(isDataFound,modal.data?.data,Constant.ErrorMsg.noDataFound)

            }
            catch let error {
                debugPrint(error)
                completion(.Error,nil,DIError.invalidData().message)
            }
            

            }
         failure: { error in
             DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }

            completion(.Error,nil,error.message)
        }
    }
    
    func getProductList(category: String, searchedText: String, completion: @escaping(_ response: [ProductList]) -> (Void), failure: @escaping(_ error: DIError) -> (Void)){
        //.8/retail/product?filterBy=watches&searchBy=son
        var subDomain = Constant.SubDomain.getProductList
        if searchedText != "" && category != ""{
           subDomain = "\(Constant.SubDomain.getProductList)?filterBy=\(category)&searchBy=\(searchedText)"
       }else if searchedText != ""{
            subDomain = "\(Constant.SubDomain.getProductList)?searchBy=\(searchedText)"
        }else if category != ""{
            subDomain = "\(Constant.SubDomain.getProductList)?filterBy=\(category)"
        }
        self.call(method: .get, function: subDomain, parameters: nil, success: { (response) in
            if let data = response["data"] as? Response {
                let decodedData = data["data"] as? [Parameters]
                //get data from object
                self.decodeFrom(data: decodedData, success: { (content) in
                    completion(content)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) { (error) in

            failure(error)
        }
    }
   // retail/removecart?cart_id=62ac0ce12314072f24a1e228

    func payment(endPoint:String,parent:DIBaseController? = nil,  isLoader:Bool = true,  params:Parameters? = nil, completion: @escaping CompletionResponse ) {
        if isLoader { parent?.showLoader() }

        self.webManager.post(method: .post, function: endPoint, parameters: params) { data in
            
            DispatchQueue.main.async {
                parent?.hideLoader()
            }

            do {
                let modal   = try JSONDecoder().decode(DefaultModal.self, from: data)
                
                completion( modal.status == 1 ? .Success(modal.url) : .Failure(modal.message))
                
            }
            catch let error {
                debugPrint(error)
                completion(.Failure(DIError.invalidData().message))
            }
            

            }
         failure: { error in
             DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }

             completion(.Failure(error.message))
             
         }}
    
    func deleteProduct(endPoint:String,parent:DIBaseController? = nil,  isLoader:Bool = true,  params:Parameters? = nil, completion: @escaping CompletionResponse ) {
        if isLoader { parent?.showLoader() }

        self.webManager.post(method: .delete, function: endPoint, parameters: params) { data in
            
            DispatchQueue.main.async {
                parent?.hideLoader()
            }

            do {
                let modal   = try JSONDecoder().decode(DefaultModal.self, from: data)
                
                completion( modal.status == 1 ? .Success(modal.message) : .Failure(modal.message))
                
            }
            catch let error {
                debugPrint(error)
                completion(.Failure(DIError.invalidData().message))
            }
            

            }
         failure: { error in
             DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }

             completion(.Failure(error.message))
             
         }}
    
    func getWishlist( completion: @escaping(_ response: [ProductInfo]) -> (Void), failure: @escaping(_ error: DIError) -> (Void)){
        
      
        self.call(method: .get, function: Constant.SubDomain.getWishlist, parameters: nil, success: { (response) in
            if let data = response["data"] as? Response {
                let decodedData = data["data"] as? [Parameters]
                //get data from object
                self.decodeFrom(data: decodedData, success: { (content) in
                    completion(content)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) { (error) in

            failure(error)
        }
       
        
    }
    
    func getCartList(subDomain:String,completion: @escaping(_ data:[ProductInfo]) -> Void,failure: @escaping(_ error:DIError) -> Void) {
        self.call(method: .get, function: subDomain, parameters: nil) { responseValue in
            if let data = responseValue["data"] as? [Parameters] {
                self.decodeFrom(data: data, success: { (products) in
                    completion(products)
                }, failure: { (error) in
                    failure(error)
                })
            }
        } failure: { error in
           failure(error)
        }
    }
    func setProductRating(params: Parameters,completion: @escaping(_ response: String) -> (Void),failure: @escaping(_ error: DIError) -> (Void)){
        //URL: /v1.8/retail/rate
        
        self.call(method: .post, function: Constant.SubDomain.setProductRating, parameters: params) { responseValue in
            if let msg = responseValue["message"] as? String {
                completion(msg)
            }
        } failure: { error in
           failure(error)
        }
    }

    func getPendingReviewProducts(completion: @escaping(_ response: [ReviewProductsModal]) -> (Void),failure: @escaping(_ error: DIError) -> (Void)){
        self.call(method: .get, function: Constant.SubDomain.getPendingRatingProducts, parameters: nil) { responseValue in

            if let data = responseValue["data"] as? Parameters , let data = data["data"] as? [Parameters]{
                    self.decodeFrom(data: data, success: { data in
                     completion(data)

                    }, failure: { (error) in
                      failure(error)
                    })
                }
            }failure: { error in
           failure(error)
        }
    }

    func getPublishedReviewProducts(completion: @escaping(_ response: [ReviewProductsModal]) -> (Void),failure: @escaping(_ error: DIError) -> (Void)){
        self.call(method: .get, function: Constant.SubDomain.getPublishRatingProducts, parameters: nil) { responseValue in
            if let data = responseValue["data"] as? Parameters ,let data = data["data"] as? [Parameters]{
                self.decodeFrom(data: data, success: { data in
                 completion(data)

                }, failure: { (error) in
                  failure(error)
                })
            }
        } failure: { error in
           failure(error)
        }
    }

        func getRetailNotifications(completion:@escaping(_ notifications:[RetailNotifications]) -> Void,failure: @escaping(_ error:DIError) -> Void){
        let subDomain = Constant.SubDomain.getRetailNotifications
        self.call(method: .get, function: subDomain, parameters: nil) { responseValue in
            if let data = responseValue["data"] as? [Parameters] {
                self.decodeFrom(data: data) { notifications in
                    completion(notifications)
                } failure: { error in
                    failure(error)
                }
            }
        } failure: { error in
            failure(error)
        }
        }
    
    func getOrderHistory(completion:@escaping(_ notifications:[OrderHistory]) -> Void,failure: @escaping(_ error:DIError) -> Void){
        let subDomain = Constant.SubDomain.getOrdersHistory
        self.call(method: .get, function: subDomain, parameters: nil) { responseValue in
            if let data = responseValue["data"] as? Parameters,let orders = data["data"] as? [Parameters] {
                print(data)
                self.decodeFrom(data: orders) { orders in
                    completion(orders)
                } failure: { error in
                    failure(error)
                }
            }
        } failure: { error in
            failure(error)
        }
    }
    
    func getFullOrderDetail(orderId:String,completion:@escaping(_ notifications:[ProductInfo],_ price:Int) -> Void,failure: @escaping(_ error:DIError) -> Void){
        let subDomain = "\(Constant.SubDomain.getOrderDetail)\(orderId)"
        self.call(method: .get, function: subDomain, parameters: nil) { responseValue in
            if let data = responseValue["data"] as? Parameters, let productData = data["productData"] as? [Parameters] , let price = data["totalPrice"] as? Int{
                self.decodeFrom(data: productData) { orders in
                    completion(orders,price)
                } failure: { error in
                    failure(error)
                }
            }
        } failure: { error in
            print(error)
        }
    }
}
