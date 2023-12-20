//
//  APIManager.swift
//  BaseProject
//
//  Created by narinder on 01/03/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import Foundation
//let token = UserDefaults.standard.value(forKey: Constant.UserDefaultKey.notificationToken) as? String ?? ""

struct Login: Codable {
    
    var facebookId: String = ""
    var snsType : Int = 0
    var snsId: String = ""
    var username: String = ""
    var password: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var dateOfBirth:String = ""
    var profilePicure:String = ""
    var gender: Int?
    var device_token : String = "abcd"
    //var address : String = ""
    var address = Address()
    var longlat : [Double] = []
    var dob : String = ""
    var activate = false
    var accountabilityMisssionn = ""
    //var profilePic : String = ""
    var isEmailVerified = EmailVerified.no.rawValue
    
    enum CodingKeys: String, CodingKey {
        case facebookId
        case snsType
        case snsId
        case username
        case password
        case firstName
        case lastName
        case dateOfBirth
        case profilePicure
        case gender
        case device_token
        case address
        case longlat
        case dob
        case isEmailVerified
        case activate
    }
    
    func getDictionary() -> Parameters {
        var dict:[String: Any] = ["username": username,
                                  "password": password,
                                  "sns_type" : 1]
        
        if activate {
            dict["activate"] = activate
        }
        /*let dict:[String: Any] = ["phone": self.userName,
         "password": self.password]*/
        
        //let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        return dict//jsonData
    }
    
    func getDictionaryForSociaSignUp() -> [String: Any] {
        let dict:[String: Any] = ["email": username,
                                  "sns_type": snsType,
                                  "first_name": firstName,
                                  "last_name": lastName,
                                  "sns_id": snsId,
                                  "profile_pic": profilePicure,
                                  "is_email_verified":isEmailVerified
        ]
        return dict
        
    }
    
    /* func getDictForProfile() -> [String: Any]{
     
     let dict : [String:Any] = ["address": address,
     "longlat":longlat ,
     "dob": dob,
     "gender": gender,
     "profile_pic": profilePic]
     return dict
     } */
    
    func getDictSocialExist() -> [String:Any]{
        var dict:[String: Any] = ["sns_type": snsType,
                                  "sns_id" : snsId]
        
        if activate {
            dict["activate"] = activate
        }
        return dict
    }
    
    ///save user to user defaults
    func saveEncodedInformation() {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(self) {
            UserDefaults.standard.set(encodedData, forKey: DefaultKey.socialLoginInfo.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    ///get the saved user information
    static func currentUserInfo() -> Login? {
        if let savedUser = UserDefaults.standard.value(forKey: DefaultKey.socialLoginInfo.rawValue) as? Data {
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode(Login.self, from: savedUser) {
                return decodedData
            }
        }
        return nil
    }
    
}

struct Registration {
    var firstName: String = ""
    var lastName : String = ""
    var email: String = ""
    var password: String = ""
    var snsType : Int = 1
    var phone:String = ""
    var countryCode : String = ""
    
    func getDictionary() -> [String: Any]? {
        let dict:[String: Any] = ["first_name": firstName,
                                  "last_name": lastName,
                                  "email": email,
                                  "password": password,
                                  "phone": phone,
                                  "country_code" :countryCode
        ]
        return dict
    }
}


struct OTPVerification {
    var otpCode:String = ""
    var username: String = ""
    var type: Int?
    func getDictionary() -> [String: Any]? {
        
        let dict:[String: Any] = [
            "username": username,
            "otp_code":otpCode
        ]
        //        if let _ = type {
        //            dict["type"] = type
        //        }
        return dict
    }
    
    func getForgotDictionary() -> [String: Any]? {
        let dict:[String: Any] = [
            "username": username
        ]
        return dict
    }
    
    func resendDict() -> [String: Any]? {
        var dict:[String: Any] = [
            "username": username
        ]
        if let typ = type {
            dict["type"] = typ
        }
        return dict
    }
    
    func getResendForgotDictionary() -> [String: Any]? {
        let dict:[String: Any] = [
            "username": username
        ]
        return dict
    }
    
}

struct ResetPassword {
    var password:String = ""
    var username: String = ""
    var resetToken : String = ""
    func getDictionary() -> [String: Any]? {
        let dict:[String: Any] = [
            "username": username,
            "reset_token":resetToken,
            "password":password
        ]
        return dict
    }
}
struct DeleteStory {
    var id:String?
    func getDictionary() -> [String: Any]? {
        var dict:[String: Any] = [String:Any]()
        if self.id != nil {
            dict["id"] = self.id
        }
        return dict
    }
}

struct ActivitiesLog: Codable{
    var activityName: String?
    var date: Int
    var duration: Double
    var distance: Double
    var user_id: String
    var activityImage: String
    var calories: Double
    var steps: Double
    var rating: Int
    var startDate: Int
    var endDate: Int
    var categoryType: String
    var activityId: Int?
    // var activityTypeId: String
    var activityType: Int
    var id : String?
    var isBinary : Bool?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case activityName
        case date
        case duration = "timeSpent"
        case distance = "distanceCovered"
        case  user_id = "userId"
        case activityImage
        case calories
        case steps
        case rating
        case startDate
        case endDate
        case activityId
        //   case activityTypeId
        case activityType
        case categoryType
        case isBinary
    }
}


struct AffilativeContentModel: Codable {
    var categoryName: String?
    var data:[ContentModel]
    
    enum CodingKeys: String, CodingKey {
        case categoryName = "category_name"
        case data =  "contentdata"
    }
}

struct AffilativeCommunityModel: Codable {
    var message: String?
    var data:[AffilativeCommunityDataModel] = [AffilativeCommunityDataModel]()
    
    enum CodingKeys: String, CodingKey {
        case message = "message"
        case data =  "contentlistwise"
    }
}


struct AffilativeCommunityDataModel: Codable {
    var data:[AffilativeCommunityContentParticularModel] = [AffilativeCommunityContentParticularModel]()
    var name:String?
    enum CodingKeys: String, CodingKey {
        case data =  "data"
        case name
    }
}

struct AffilativeCommunityContentParticularModel: Codable{
    var description:String?
    var image:String?
    var name:String?
    var id:String?
    var programName:String?
    var typecheck:Int?
    var programThumbnail: String?
    var startDate: String?
    var endDate: String?
    var rating: Int?
    var duration: Int?

    enum CodingKeys:String,CodingKey {
        case description = "description"
        case name
        case programName
        case image
        case id = "_id"
        case typecheck
        case programThumbnail = "programThumbnail"
        case startDate
        case endDate
        case rating,duration
    }
}

struct ContentModel: Codable{
    var description:String?
    var name:String?
    var preview:String?
    var file:String?
    var type: Int?
    var _id: String?
    var rating: Int?
    var duration: Int?

    enum CodingKeys:String,CodingKey {
        case description = "description"
        case name
        case file
        case type
        case preview = "preview"
        case _id
        case rating
        case duration
    }
}

struct SeeAllModel: Codable{
    var id: String?
    var image: String?
    var title: String?
    var description: String?
    var hashTags: String?
    var profile_pic: String?
    var store_image_thumbnail: String?
    var isAffiliateCoach: Int? // will specify if any affiliate converted himself into a coach, 0 means does'nt converted and 1 means he has converted.
    var tags:String{
        if let tags = hashTags{
            return tags.replacingOccurrences(of: "#", with: "", options: NSString.CompareOptions.literal, range: nil)  // returing tags after removing # symbol for search
        }
        else{
            return ""
        }
    }
    var logo: String?
    var text: String? // Different from description. It will show the affiliates text on affiliate landing screen
    var affiliateId: String?
    var isPlanPurchased: Int? // Will show the subscription plan purchased or not. Here 1 will notify the plan is purchased & 0 will notify the plan is not purchased
    var isPaid:Int? // Will show the subscription plan is paid or free. Here 1 will notify the plan is paid & 0 will notify the plan is free
    var websiteUrl: String?
    var instaUrl: String?
    var tiktokUrl: String?
    var isBookMark: Int?
    var studioUrl: String?
    var youTubeUrl: String?

    enum CodingKeys:String,CodingKey {
        case isAffiliateCoach
        case id = "_id"
        case image
        case store_image_thumbnail
        case title = "name"
        case description
        case hashTags = "tags"
        case logo
        case profile_pic
        case text
        case affiliateId = "_user"
        case isPlanPurchased
        case isPaid = "isPlanAdded"
        case websiteUrl
        case instaUrl
        case tiktokUrl
        case isBookMark
        case studioUrl
        case youTubeUrl
    }
}



struct SeeAllModelNew: Codable{
    var marketplacelogo, marketplaceimage:String?
    var marketplacename,file:String?
    var description, name, preview, image:String?
    var type: Int?
    
    
    enum CodingKeys:String,CodingKey {
        case marketplaceimage
        case marketplacelogo
        case preview
        case name
        case type
        case file
        case marketplacename = "marketplacename"
        case description
        case image
        
    }
}



// MARK: - Tile
struct Tile: Codable {
    let id, image, name: String
    let status, tileType, displayOn: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case status, tileType, displayOn, image, name
    }
}

struct JournalList:Codable{
    var date:Int
    var rating:Int
    var quote:String
    var id:String
    
    enum CodingKeys: String, CodingKey{
        case date
        case rating
        case quote
        case id = "_id"
    }
}

struct PaymentHistory:Codable{
    
    let affiliateName:String?
    let affiliateImage:String?
    let paymentAmout:Double?
    let currency:String?
    enum CodingKeys:String,CodingKey{
        case affiliateName = "affiliateName"
        case affiliateImage = "profile_pic"
        case paymentAmout = "amount"
        case currency = "usd"
    }
}

struct PlanList:Codable{
    
    var duration, name:String
    var amount: Double
    var planActiveStatus: Int    //1 for no plan active  // 2 for plan active//3 cancel plan(plan has been canceled but date not expired) // 4 UPgrade plan // 5 downgrade plan
    var expirydate: Int?
    var id: String
    var isUpComing:Int? // 0 for not upcoming & 1 for upcoming
    let displayName: String?
    let description: String?

    enum CodingKeys: String, CodingKey{
        case duration
        case amount
        case name
        
        case planActiveStatus = "isActive"
        case expirydate
        case id = "_id"
        case isUpComing
        case description = "pdescription"
        case displayName

    }
    
}
struct SubscriptionPlan{
    var affiliateId: String
    var id: String
    
    func getDictionary() -> [String: Any] {
        let dict:[String: Any] = ["_id": id,
                                  "affiliateid": affiliateId
        ]
        return dict
        
    }
}

struct SelectedPlan:Codable{
    
    var data:String
    
    
    enum CodingKeys: String, CodingKey{
        case data
    }
}

struct CardsDetails:Codable{
    
    let id:String?
    let card:CardDetails
    
    enum CodingKeys:String,CodingKey{
        case id = "_id"
        case card = "card"
    }
}

struct CardDetails:Codable{
    let name:String?
    let number:String?
    let isPrimary:Int?
    
    enum CodingKeys:String,CodingKey {
        case name = "brand"
        case number = "last4"
        case isPrimary = "primary"
    }
}

struct FriendRequest {
    
    var friendId:String = ""
    func getDictionary() -> [String: Any]? {
        let dict:[String: Any] = [
            "friend_id":friendId
        ]
        return dict
    }
}

struct BlockUser {
    
    var friendId:String = ""
    func getDictionary() -> [String: Any]? {
        let dict:[String: Any] = [
            "_id":friendId
        ]
        return dict
    }
}

struct FacebookFriends {
    
    var arrFriends:[String] = [String]()
    
    func getDictionary() -> [String: Any]? {
        let dict:[String: Any] = [
            "friends":arrFriends,
        ]
        return dict
    }
}

struct CreateProfile {
    
    var imgUrl:String = ""
    var dateOfBirth:String = ""
    var userName:String = ""
    var heightInFeet:Int = 0
    var heightInInch:Int = 0
    var weight:Int = 0
    var location:Address = Address()
    var gender:Int = 0
    var long:Double = 0.0
    var lat:Double = 0.0
    var profileCompletion = 0.0
    var gymLocation:Address = Address()
    var addressDict = GetAddressParamKey()
    var gymAddressDict = GetGymAddressParamKey()
    var gymAddressType: GymLocationType?
    var firstName:String!
    var lastName:String!
    var accountabilityMission:String = ""
    
    mutating func getDictionary() -> [String: Any]? {
        addressDict.address = location
        gymAddressDict.address = gymLocation
        var dict:[String: Any] = [
            "profile_pic":imgUrl,
            "dob" : dateOfBirth,
            "feet": heightInFeet,
            "inch": heightInInch,
            "weight": weight,
            "gender": gender,
            "username": userName,
            "profile_completion_percentage": profileCompletion*100,
            "first_name":firstName ?? "",
            "last_name" :lastName ?? ""
        ]
        if accountabilityMission != ""{
            dict["accountabilityMission"] = accountabilityMission
        }
        if location.lat != nil {
            dict["address"] = addressDict.getDictionary() ?? [:]
        }
        /*if gymLocation.lat != nil {
         dict["gym"] = gymAddressDict.getDictionary() ?? [:]
         } */
        if gymLocation.name != nil && gymLocation.name != "" {
            var gymAddress = gymAddressDict.getDictionary() ?? [:]
            if let gymType = gymAddressType {
                gymAddress["type"] = gymType.rawValue
            }
            dict["gym"] = gymAddress//gymAddressDict.getDictionary() ?? [:]
            
        }
        return dict
    }
}

struct GetAddressParamKey {
    var address = Address()
    func getDictionary() -> [String: Any]? {
        let dict:[String: Any] = [
            "city":address.city ?? "",
            "country": address.country ?? "",
            "line": address.formatted ?? "",
            "pincode": address.pinCode ?? "",
            "state": address.state ?? "",
            "lat": address.lat ?? "",
            "long": address.lng ?? "",
            "place_id": address.place_id ?? "",
            "name": address.name ?? ""
        ]
        return dict
    }
}

enum GymLocationType: Int, Codable {
    case home = 0
    case other = 1
}

struct GetGymAddressParamKey {
    var address = Address()
    func getDictionary() -> [String: Any]? {
        var dict:[String: Any] = [
            "place_id": address.place_id ?? "",
            "name": address.name ?? ""
        ]
        if let lat = address.lat {
            dict["lat"] = lat
        }
        if let long = address.lng {
            dict["long"] = long
        }
        return dict
    }
}

enum SyncContactsType: Int, CaseIterable {
    case phoneBook = 1
    case facebook = 2
}

struct PhoneContactsKey {
    var valuesArray:[String] = []
    var snsType = SyncContactsType.phoneBook
    func getDictionary() -> [String: Any]? {
        let dict:[String: Any] = [
            "friends":valuesArray,
            "type": snsType.rawValue
        ]
        return dict
    }
}

struct Comment {
    var postId:String = ""
    var comment:String = ""
    var taggedIds = [UserTag]()
    func getDictionary() -> [String: Any]? {
        var dict:[String: Any] = [
            "post_id":postId,
            "comment": comment ,
            "commentTagIds": taggedIds
        ]
        var tagIds: [[String: String]] = []
        
        for tagId in taggedIds {
            var tagDict: [String: String] = [:]
            tagDict["id"] = tagId.id ?? ""
            tagDict["text"] = tagId.text ?? ""
            tagIds.append(tagDict)
        }
        dict["commentTagIds"] = tagIds
        
        return dict
    }
}


struct ReportPost {
    var id:String = ""
    var description:String = ""
    var postId:String = ""
    
    func getDictionary() -> [String: Any]? {
        let dict:[String: Any] = [
            "description":description,
            "category_id": id ,
            "post_id": postId
        ]
        return dict
    }
}


struct CreateActivity {
    
    var activityType:ActivityMetric?
    var activityId:Int = 0
    var activityTarget:String = ""
    var distanceId:Int = 0
    var durationId:Int = 0
    var isScheduledActivity = CustomBool.no.rawValue
    
    func getDictionary() -> [String: Any]? {
        var dict:[String: Any] = [
            "activityType":activityType?.rawValue ?? 0,
            "activityId": activityId,
            "activityTarget": activityTarget,
            "isScheduled": isScheduledActivity
        ]
        if activityType == .distance {
            dict["distanceId"] = distanceId
        }else  if activityType == .duration {
            dict["durationId"] = durationId
        }
        return dict
    }
}

struct RateActivity{
    var id: Int
    var rating: Int
    
    func getDictionary() -> [String: Any]? {
        let dict:[String: Any] = [
            "id": id,
            "rating": rating
        ]
        return dict
    }
    
}
struct DeletePostApiKey {
    var id = ""
    
    func toDictionary() -> Parameters {
        let dict: Parameters = ["id": id]
        return dict
    }
}

struct CompleteActivity {
    
    var activityType:ActivityMetric?
    var activityId:Int = 0
    var activityTarget:String = ""
    var distanceId:Int = 0
    var durationId:Int = 0
    
    func getDictionary() -> [String: Any]? {
        var dict:[String: Any] = [
            "activityType":activityType?.rawValue ?? 0,
            "activityId": activityId,
            "activityTarget": activityTarget
        ]
        if activityType == .distance {
            dict["distanceId"] = distanceId
        }else  if activityType == .duration {
            dict["durationId"] = durationId
        }
        return dict
    }
    
}
struct DeleteFriendApiKey {
    var friendId = ""
    
    func toDictionary() -> Parameters {
        let dict: Parameters = ["friend_id": friendId]
        return dict
    }
}


// MARK: Activity Data.
struct CompeleteActivityData {
    var activityId : String?
    var status : ActivityStateStatus?
    var calories:Double?
    var timeSpent:Double?
    var distanceCovered:Double?
    var steps:Double?
    var isScheduledActivity: Int?
    var eventId:String?
    var eventactivityid:String?
    func getDictionary() -> [String: Any]? {
        var dict:[String: Any] = [
            "activityId":activityId ?? "",
            "status": status?.rawValue ?? 3 ,
            "calories": calories ?? 0.0,
            "timeSpent": timeSpent ?? "0" ,
            "distanceCovered": distanceCovered ?? 0.0,
            "steps": steps ?? 0.0,
            "event_id":eventId ?? "",
            "eventactivityid":eventactivityid ?? ""
            
        ]
        if let isScheduled = isScheduledActivity {
            dict["isScheduled"] = isScheduled
        }
        return dict
    }
}

struct JoinActivityApiKey {
    let id: String = UserManager.getCurrentUser()?.id ?? ""
    let memberType: ActivityMemberType = .temate
    
    func toDict() -> Parameters {
        let body: Parameters = ["id": self.id,
                                "memberType": self.memberType.rawValue]
        let params = ["members": [body]]
        return params
    }
}
struct ChangePasswordKey{
    var oldPassword:String?
    var newPassword:String?
    
    func toDict() -> Parameters {
        let params : Parameters = [
            "currentPassword": oldPassword ?? "",
            "newPassword": newPassword ?? "",
            "confirmPassword": newPassword ?? ""
        ]
        return params
    }
}

struct ContactUsKey{
    var email:String?
    var subject:String?
    var message:String?
    
    func toDict() -> Parameters {
        let params : Parameters = [
            "subject": subject ?? "",
            "description": message ?? ""
        ]
        return params
    }
}

struct Temmates: Equatable{
    var userId: String = ""
    var isUserAdded: Int = 1
    var todaysDate: Int = 0
    
    func getDictionary() -> [String: Any]? {
        let dict:[String: Any] = [
            "user_id": userId,
            "id_deleted":isUserAdded,
            "tag_date":todaysDate
        ]
        return dict
    }
}

struct ProductDetailModal: Codable{
    var status: Int?
    var message: String?
    var data:ProductInfo?
    enum CodingKeys:String,CodingKey{
        case status = "status"
        case message = "message"
        case data = "data"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        if let arr = try values.decodeIfPresent([ProductInfo].self, forKey: .data) {
            data = arr.first
        }

    }
}


struct ProductModal: Codable{
    var status: Int?
    var message: String?
    var data:ProductDataModal?
    
    enum CodingKeys:String,CodingKey{
        case status = "status"
        case message = "message"
        case data = "data"
    }
}



struct DefaultModal: Codable{
    var status: Int?
    var message: String?
    var data:[ProductInfo]?
    var url:String?
    enum CodingKeys:String,CodingKey{
        case status = "status"
        case message = "message"
        case data = "data"
        case url = "url"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        data = try values.decodeIfPresent([ProductInfo].self, forKey: .data)
        url = try values.decodeIfPresent(String.self, forKey: .url)

    }
}
struct ProductDataModal: Codable{
    var data:[ProductList]?
    enum CodingKeys:String,CodingKey{
        case data = "data"
    }
}

struct CartData: Codable{
    var name: String?
    var id:String?
    var price: Double?
    var isLiked:Bool?
    var image: [Image]?
    var quantity:Int?
   // var color_size:[SizeType]?
    var  size_type:String?
    var description:String?
    
    enum CodingKeys:String,CodingKey{
        case quantity = "quantity"
        case name = "product_name"
        case description  = "description"
        case id = "_id"
        case image = "image"
        case price = "price"
        case isLiked = "isLiked"
//        case color_size = "color_size"
        case size_type = "size_type"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        price = try values.decodeIfPresent(Double.self, forKey: .price)
        image = try values.decodeIfPresent([Image].self, forKey: .image)
        isLiked = try values.decodeIfPresent(Bool.self, forKey: .isLiked)
        quantity = try values.decodeIfPresent(Int.self, forKey: .quantity)
        size_type = try values.decodeIfPresent(String.self, forKey: .size_type)

        //{
            //isAddedInCart = arr.first
//        }else {
//            isAddedInCart = try values.decodeIfPresent(AddedInCart.self, forKey: .isAddedInCart)
//        }
//        color_size = try values.decodeIfPresent([SizeType].self, forKey: .color_size)
//        size_type = try values.decodeIfPresent([SizeType].self, forKey: .size_type)
            
        //cartTotal = Double(isAddedInCart?.quantity ?? 0) * (price ?? 0.0)

        
    }
    
}
struct ProductList: Codable{
    var name: String?
    var id:String?
    var price: Double?
    var isLiked:Bool?
    var image: [Image]?
    var quantity:Int?
    var isAddedInCart:[AddedInCart]?
   // var color_size:[SizeType]?
    var  size_type:[SizeType]?
    var description:String?
  //  var cartTotal:Double?
    
    enum CodingKeys:String,CodingKey{
        case quantity = "quantity"
        case name = "product_name"
        case description  = "description"
        case id = "_id"
        case image = "image"
        case price = "price"
        case isLiked = "isLiked"
        case isAddedInCart = "isAddedInCart"
//        case color_size = "color_size"
        case size_type = "size_type"
       // case cartTotal = "cartTotal"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        price = try values.decodeIfPresent(Double.self, forKey: .price)
        image = try values.decodeIfPresent([Image].self, forKey: .image)
        isLiked = try values.decodeIfPresent(Bool.self, forKey: .isLiked)
        isAddedInCart = try values.decodeIfPresent([AddedInCart].self, forKey: .isAddedInCart)
        quantity = try values.decodeIfPresent(Int.self, forKey: .quantity)
        //{
            //isAddedInCart = arr.first
//        }else {
//            isAddedInCart = try values.decodeIfPresent(AddedInCart.self, forKey: .isAddedInCart)
//        }
//        color_size = try values.decodeIfPresent([SizeType].self, forKey: .color_size)
        size_type = try values.decodeIfPresent([SizeType].self, forKey: .size_type)
            
        //cartTotal = Double(isAddedInCart?.quantity ?? 0) * (price ?? 0.0)

        
    }
    
}

struct SizeType :Codable {
    var id:String?
    var size:String?
    var isSelected :Bool = false
    
    enum CodingKeys:String,CodingKey{
        case size = "size"
        case id = "_id"
}
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        size = try values.decodeIfPresent(String.self, forKey: .size)
    }
}
struct AddedInCart:Codable {
    var quantity:Int?
    var size_type:String?
    enum CodingKeys: String, CodingKey {
        case quantity = "quantity"
        case size_type = "size_type"
    }
}

struct Image: Codable {
    let url: String
    let id: String

    enum CodingKeys: String, CodingKey {
        case url = "product_image"
        case id = "_id"
    }
}

struct CreatedRounds{
    var round:Rounds?
    var isOpened:Bool?
}

struct FetchedRounds{
    var round:EventRounds?
    var isOpened:Bool?
}


struct Rounds{
    var tasks:[Tasks]?
    var round_name:String?
    var roundId:String?
    
    func getDict() -> Parameters{
        var dict:Parameters = [:]
        var tasksDict = [Parameters]()
        if let tasks = self.tasks{
            for task in tasks {
                tasksDict.append(task.getDict())
            }
        }
        dict["tasks"] = tasksDict
        dict["round_name"] = self.round_name ?? ""
        if let id = roundId{
            dict["_id"] = id
        }
        return dict
    }
}

struct Tasks{
    var task_name:String?
    var file:String?
    var fileType:Int?
    var taskId:String?
    
    func getDict() -> Parameters{
        var dict:Parameters = [:]
        dict["task_name"] = self.task_name ?? ""
        dict["file"] = self.file ?? ""
        dict["fileType"] = self.fileType ?? 0
        if let id = taskId{
            dict["_id"] = id
        }
        return dict
    }
    
}

struct Checklist:Codable{
    var roundName:String?
    var roundId:String?
    var tasks:[ChecklistTasks]?
    
    enum CodingKeys:String,CodingKey{
        case roundName = "roundName"
        case roundId = "_id"
        case tasks = "tasks"
    }
}

struct ChecklistTasks: Codable{
    var isDone:Int?
    var task:EventRoundsTasks?
    
    enum CodingKeys:String, CodingKey{
        case isDone = "isDone"
        case task = "task"
    }
}
