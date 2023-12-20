//
//	User.swift
//

import Foundation

enum UserConfirmation: Int, Codable {
    case email = 1
    case textMessage = 2
    
    var name: String {
        switch self {
            case .email:
                return "email"
            default:
                return "phone number"
        }
    }
}

enum UserProfileCompletion: Int, Codable {
    case notDone = 0
    case createProfile = 1
    case selectInterests = 2
}

enum Proprivate : Int, Codable  {
    case isPrivate = 1
    case notPrivate = 0
}

enum pushStatus : Int, Codable  {
    case on = 1
    case off = 0
}

enum NewsFeedAlgoOption: Int, Codable {
    case new = 1
    case old = 2
}

enum AdminType:Int{
    case admin = 1
    case appUser = 2
    case affiliate = 3
}

class User: NSObject, NSCoding, Codable {
    static var sharedInstance = User()
    
    // MARK: Properties
    var deviceType: String?
    var hasCreatedShopifyAccount: Int? = 0
    var deviceToken: String?
    var oauthToken: String?
    var firebaseProfileImageName: String?
    var snsType: Int?
    var snsID: String?
    var deviceId:String?
    var isCompanyAccount: Int? // admin flag
    var cartCount: Int?
    //New Attributes
    var email: String?
    var id: String?
    var firstName: String?
    var lastName: String?
    var phoneNumber: String?
    var password: String?
    var profilePicUrl: String?
    var dateOfBirth: String?
    var address:Address?
    var gymAddress:Address?
    var countryCode:String?
    var deviceID:String?
    var fbConnected:Int?
    var isPrivate:Int?
    var pushNotification:Int?
    var status:Int?
    var userName:String?
    var verifiedStatus:Int?
    var gender:Int?
    var feet:Int?
    var inch:Int?
    var weight:Int?
    var interests:[String] = [String]()
    var createdAt:String?
    var postCount:Int?
    var tematesCount:Int?
    var temsCount:Int?
    var profileCompletionStatus: Int? = 0
    var pushNotificationStatus:Int?
    var calenderNotificationStatus:Int?
    var socialMedia: [Parameters]?
    var trackerStatus: Int?
    var tracker: Int?
    var isFromSignUp: Bool = false
    var accountabilityMission : String?
    var unreadNotiCount: Int? = 0
    var chatRoomId: String?
    /// 1 indicates the new algorithm and 2 mtlb old algorithm
    var algoOption: NewsFeedAlgoOption? = .new
    var adminType: Int?
    var temAdminId: String?
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let email = "email"
        static let id = "id"
        static let cartCount = "cart"
        static let hasCreatedShopifyAccount = "is_shopify"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let phoneNumber = "phoneNumber"
        static let profilePicUrl = "profile_pic"
        static let dateOfBirth = "dateOfBirth"
        static let gender = "gender"
        static let countryCode = "countryCode"
        static let userName = "userName"
        static let verifiedStatus = "verified_status"
        static let status = "status"
        static let feet = "feet"
        static let inch = "inch"
        static let weight = "weight"
        static let accountabilityMission = "accountabilityMission"
        static let oauthToken = "oauthToken"
        static let deviceToken = "deviceToken"
        static let firebaseProfileImageName = "firebaseProfileImageName"
        static let deviceType = "deviceType"
        static let deviceId = "deviceId"
        static let interest = "interest"
        static let address = "address"
        static let gymAddress = "gym"
        static let profileCompletionPercent = "profile_completion_percentage"
        static let profileCompletionStatus = "profile_completion_status"
        static let socialMedia = "socialMedia"
        static let createdAt = "createdAt"
        static let isPrivate = "is_private"
        static let pushNotification = "pushNotification"
        static let calenderNotification = "calenderNotification"
        static let trackerStatus = "trackerStatus"
        static let tracker = "tracker"
        static let unreadNotiCount = "unreadNotiCount"
        static let algoOption = "algoOption"
        static let isCompanyAccount = "isCompanyAccount"
        static let chatRoomId = "chat_room_id"
        static let userType = "admintype"
        static let tematesCount = "tematesCount"
        static let temAdminId = "adminId"
    }
    
    func resetUserInstance() {
        self.email = nil
        self.id = nil
        self.cartCount = nil
        self.lastName = nil
        self.firstName = nil
        self.chatRoomId = nil
        self.deviceToken = nil
        self.oauthToken = nil
        self.profilePicUrl = nil
        self.firebaseProfileImageName = nil
        self.countryCode = nil
        self.userName = nil
        self.phoneNumber = nil
        self.dateOfBirth = nil
        self.gender = nil
        self.feet = nil
        self.weight = nil
        self.inch = nil
        self.profileCompletionStatus = 0
        self.socialMedia?.removeAll()
        self.socialMedia = nil
        self.trackerStatus = nil
        self.tracker = nil
        self.interests.removeAll()
        self.unreadNotiCount = 0
        self.hasCreatedShopifyAccount = 0
        self.accountabilityMission = nil
        self.algoOption = nil
        self.isCompanyAccount = 0
        self.adminType = nil
        self.tematesCount = nil
        self.temAdminId = nil
    }
    
    // MARK: Default Initializer
    override init () {
        // uncomment this line if your class has been inherited from any other class
        //super.init()
    }
    
    convenience init(_ dictionary: Parameters) {
        self.init()
        id = dictionary["_id"] as? String ?? ""
        email = dictionary["email"] as? String ?? ""
        firstName = dictionary["first_name"] as? String ?? ""
        chatRoomId = dictionary["chat_room_id"] as? String ?? ""
        lastName = dictionary["last_name"] as? String ?? ""
        countryCode = dictionary["country_code"] as? String ?? ""
        phoneNumber = dictionary["phone"] as? String ?? ""
        userName = dictionary["username"] as? String ?? ""
        profilePicUrl = dictionary["profile_pic"] as? String ?? ""
        dateOfBirth = dictionary["dob"] as? String ?? ""
        deviceToken = dictionary["device_token"] as? String ?? ""
        deviceType = dictionary["device_type"] as? String ?? ""
        deviceID = dictionary["device_id"] as? String ?? ""
        createdAt = dictionary["created_at"] as? String ?? ""
        gender = dictionary["gender"] as? Int ?? 1
        hasCreatedShopifyAccount = dictionary[CodingKeys.cartCount.rawValue] as? Int ?? 0
        isPrivate = dictionary["is_private"] as? Int ?? 0
        calenderNotificationStatus = dictionary["calender_notification"] as? Int ?? 0
        pushNotificationStatus = dictionary["push_notification"] as? Int ?? 0
        isPrivate = dictionary["is_private"] as? Int ?? 0
        if let height = dictionary["height"] as? Parameters {
            feet = height["feet"] as? Int ?? 0
            inch = height["inch"] as? Int ?? 0
        }
        weight = dictionary["weight"] as? Int ?? 0
        interests = dictionary["interest"] as? [String] ?? []
        firebaseProfileImageName = dictionary["firebaseProfileImageName"] as? String ?? ""
        verifiedStatus = dictionary["verified_status"] as? Int ?? nil
        trackerStatus = dictionary["tracker_status"] as? Int
        tracker = dictionary["tracker"] as? Int
        if let option = dictionary["algo_type"] as? Int,
           let algoType = NewsFeedAlgoOption(rawValue: option) {
            self.algoOption = algoType
        }
        
        if let userAddress = dictionary["address"] as? Parameters {
            address = Address(json: userAddress)
        }
        if let userGymAddress = dictionary["gym"] as? Parameters {
            gymAddress = Address(json: userGymAddress)
            if let type = userGymAddress["type"] as? Int,
               let typeOfGym = GymLocationType(rawValue: type) {
                gymAddress?.gymType = typeOfGym
            }
            if let value = userGymAddress["gym_type_mandatory"] as? Int,
               let hasGymType = CustomBool(rawValue: value) {
                gymAddress?.hasGymType = hasGymType
            }
        }
        self.accountabilityMission = dictionary["accountabilityMission"] as? String ?? ""
        self.profileCompletionStatus = dictionary["profile_completion_status"] as? Int ?? 0
        if let socialMediaArr = dictionary["social_media"] as? [Parameters] {
            self.socialMedia = []
            self.socialMedia?.append(contentsOf: socialMediaArr)
        }
        isCompanyAccount = dictionary["isCompanyAccount"] as? Int
        self.adminType = dictionary["admintype"] as? Int
        self.tematesCount = dictionary["tematesCount"] as? Int
        self.temAdminId = dictionary["adminId"] as? String
    }
    
    required public init(coder aDecoder: NSCoder) {
        self.accountabilityMission = aDecoder.decodeObject(forKey: SerializationKeys.accountabilityMission) as? String
        self.hasCreatedShopifyAccount = aDecoder.decodeObject(forKey: CodingKeys.hasCreatedShopifyAccount.rawValue) as? Int
        self.phoneNumber = aDecoder.decodeObject(forKey: SerializationKeys.phoneNumber) as? String
        self.countryCode = aDecoder.decodeObject(forKey: SerializationKeys.countryCode) as? String
        self.dateOfBirth = aDecoder.decodeObject(forKey: SerializationKeys.dateOfBirth) as? String
        self.email = aDecoder.decodeObject(forKey: SerializationKeys.email) as? String
        self.id = aDecoder.decodeObject(forKey: SerializationKeys.id) as? String
        self.lastName = aDecoder.decodeObject(forKey: SerializationKeys.lastName) as? String
        self.createdAt = aDecoder.decodeObject(forKey: SerializationKeys.createdAt) as? String
        self.firstName = aDecoder.decodeObject(forKey: SerializationKeys.firstName) as? String
        self.chatRoomId = aDecoder.decodeObject(forKey: SerializationKeys.chatRoomId) as? String
        self.userName = aDecoder.decodeObject(forKey: SerializationKeys.userName) as? String
        self.deviceToken = aDecoder.decodeObject(forKey: SerializationKeys.deviceToken) as? String
        self.deviceId = aDecoder.decodeObject(forKey: SerializationKeys.deviceId) as? String
        self.deviceType = aDecoder.decodeObject(forKey: SerializationKeys.deviceType) as? String
        self.oauthToken = aDecoder.decodeObject(forKey: SerializationKeys.oauthToken) as? String
        self.profilePicUrl = aDecoder.decodeObject(forKey: SerializationKeys.profilePicUrl) as? String
        self.gender = aDecoder.decodeObject(forKey: SerializationKeys.gender) as? Int
        self.isPrivate = aDecoder.decodeObject(forKey: SerializationKeys.isPrivate) as? Int
        self.pushNotificationStatus = aDecoder.decodeObject(forKey: SerializationKeys.pushNotification) as? Int
        self.calenderNotificationStatus = aDecoder.decodeObject(forKey: SerializationKeys.calenderNotification) as? Int
        self.feet = aDecoder.decodeObject(forKey: SerializationKeys.feet) as? Int
        self.inch = aDecoder.decodeObject(forKey: SerializationKeys.inch) as? Int
        self.weight = aDecoder.decodeObject(forKey: SerializationKeys.weight) as? Int
        self.firebaseProfileImageName = aDecoder.decodeObject(forKey: SerializationKeys.firebaseProfileImageName) as? String
        self.address = aDecoder.decodeObject(forKey: SerializationKeys.address) as? Address
        self.gymAddress = aDecoder.decodeObject(forKey: SerializationKeys.gymAddress) as? Address
        self.profileCompletionStatus = aDecoder.decodeObject(forKey: SerializationKeys.profileCompletionStatus) as? Int
        self.verifiedStatus = aDecoder.decodeObject(forKey: SerializationKeys.verifiedStatus) as? Int
        self.interests = aDecoder.decodeObject(forKey: SerializationKeys.interest) as? [String] ?? []
        self.socialMedia = aDecoder.decodeObject(forKey: SerializationKeys.socialMedia) as? [Parameters]
        self.trackerStatus = aDecoder.decodeObject(forKey: SerializationKeys.trackerStatus) as? Int
        self.tracker = aDecoder.decodeObject(forKey: SerializationKeys.tracker) as? Int
        self.unreadNotiCount = aDecoder.decodeObject(forKey: SerializationKeys.unreadNotiCount) as? Int
        self.algoOption = NewsFeedAlgoOption(rawValue: aDecoder.decodeObject(forKey: SerializationKeys.algoOption) as? Int ?? 1)
        self.isCompanyAccount = aDecoder.decodeObject(forKey: SerializationKeys.isCompanyAccount) as? Int
        self.adminType = aDecoder.decodeObject(forKey: SerializationKeys.userType) as? Int
        self.tematesCount = aDecoder.decodeObject(forKey: SerializationKeys.tematesCount) as? Int
        self.temAdminId = aDecoder.decodeObject(forKey: SerializationKeys.temAdminId) as? String
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(hasCreatedShopifyAccount, forKey: CodingKeys.hasCreatedShopifyAccount.rawValue)
        
        aCoder.encode(accountabilityMission, forKey: SerializationKeys.accountabilityMission)
        aCoder.encode(email, forKey: SerializationKeys.email)
        aCoder.encode(phoneNumber, forKey: SerializationKeys.phoneNumber)
        aCoder.encode(countryCode, forKey: SerializationKeys.countryCode)
        aCoder.encode(id, forKey: SerializationKeys.id)
        aCoder.encode(createdAt, forKey: SerializationKeys.createdAt)
        aCoder.encode(lastName, forKey: SerializationKeys.lastName)
        aCoder.encode(firstName, forKey: SerializationKeys.firstName)
        aCoder.encode(chatRoomId, forKey: SerializationKeys.chatRoomId)
        aCoder.encode(userName, forKey: SerializationKeys.userName)
        aCoder.encode(deviceToken, forKey: SerializationKeys.deviceToken)
        aCoder.encode(oauthToken, forKey: SerializationKeys.oauthToken)
        aCoder.encode(deviceType, forKey: SerializationKeys.deviceType)
        aCoder.encode(profilePicUrl, forKey: SerializationKeys.profilePicUrl)
        aCoder.encode(dateOfBirth, forKey: SerializationKeys.dateOfBirth)
        aCoder.encode(deviceID, forKey: SerializationKeys.deviceId)
        aCoder.encode(gender, forKey: SerializationKeys.gender)
        aCoder.encode(feet, forKey: SerializationKeys.feet)
        aCoder.encode(inch, forKey: SerializationKeys.inch)
        aCoder.encode(weight, forKey: SerializationKeys.weight)
        aCoder.encode(firebaseProfileImageName, forKey: SerializationKeys.firebaseProfileImageName)
        aCoder.encode(address, forKey: SerializationKeys.address)
        aCoder.encode(gymAddress, forKey: SerializationKeys.gymAddress)
        aCoder.encode(profileCompletionStatus, forKey: SerializationKeys.profileCompletionStatus)
        aCoder.encode(verifiedStatus, forKey: SerializationKeys.verifiedStatus)
        aCoder.encode(interests, forKey: SerializationKeys.interest)
        aCoder.encode(socialMedia, forKey: SerializationKeys.socialMedia)
        aCoder.encode(isPrivate, forKey: SerializationKeys.isPrivate)
        aCoder.encode(pushNotificationStatus, forKey: SerializationKeys.pushNotification)
        aCoder.encode(calenderNotificationStatus, forKey: SerializationKeys.calenderNotification)
        aCoder.encode(trackerStatus, forKey: SerializationKeys.trackerStatus)
        aCoder.encode(tracker, forKey: SerializationKeys.tracker)
        aCoder.encode(unreadNotiCount, forKey: SerializationKeys.unreadNotiCount)
        aCoder.encode(algoOption?.rawValue, forKey: SerializationKeys.algoOption)
        aCoder.encode(isCompanyAccount, forKey: SerializationKeys.isCompanyAccount)
        aCoder.encode(adminType, forKey: SerializationKeys.userType)
        aCoder.encode(tematesCount, forKey: SerializationKeys.tematesCount)
        aCoder.encode(temAdminId, forKey: SerializationKeys.temAdminId)
    }
    
    func equals (compareTo:User) -> Bool {
        return
        self.firstName == compareTo.firstName &&
        self.lastName == compareTo.lastName &&
        self.userName == compareTo.userName &&
        self.dateOfBirth == compareTo.dateOfBirth &&
        self.address?.formatAddress() == compareTo.address?.formatAddress() &&
        self.gymAddress?.formatAddress() == compareTo.gymAddress?.formatAddress() &&
        self.gender == compareTo.gender &&
        self.gymAddress?.gymType == compareTo.gymAddress?.gymType
    }
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case userName = "username"
        case profilePicUrl = "profile_pic"
        case chatRoomId = "chat_room_id"
        case hasCreatedShopifyAccount = "is_shopify"
        case cartCount = "cart"
        case tematesCount = "tematesCount"
    }
}
