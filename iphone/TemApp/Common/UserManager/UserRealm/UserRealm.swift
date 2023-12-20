//
//    UserRealm.swift
//    Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport


import RealmSwift

class UserRealm: Object {
    
    @Persisted var id: String?
    @Persisted var accountabilityMission: String?
    @Persisted var address: AddresRealm?
    @Persisted var admintype: Int?
    @Persisted var algoType: Int?
    @Persisted var calenderNotification: Int?
    @Persisted var countryCode: String?
    @Persisted var createdAt: String?
    @Persisted var deviceToken: String?
    @Persisted var dob: String?
    @Persisted var email: String?
    @Persisted var fbConnected: Int?
    @Persisted var firstName: String?
    @Persisted var gender: Int?
    @Persisted var gym: GymRealm?
    @Persisted var height: HeightRealm?
    @Persisted var interest: List<String>
    @Persisted var isCompanyAccount: Int?
    @Persisted var isPrivate: Int?
    @Persisted var lastName: String?
    @Persisted var location: List<Double>
    @Persisted var phone: String?
    @Persisted var profileCompletionStatus: Int?
    @Persisted var profilePic: String?
    @Persisted var pushNotification: Int?
    @Persisted var socialMedia: List<SocialMediaRealm>
    @Persisted var status: Int?
    @Persisted var tagIds: List<TagIdRealm>
    @Persisted var token: String?
    @Persisted var tracker: Int?
    @Persisted var trackerStatus: Int?
    @Persisted var username: String?
    @Persisted var verifiedStatus: Int?
    @Persisted var weight: Int?
    override init() {
        super.init()
    }
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    class func fromDictionary(dictionary: [String:Any]) -> UserRealm    {
        let this = UserRealm()
        if let idValue = dictionary["_id"] as? String{
            this.id = idValue
        }
        if let accountabilityMissionValue = dictionary["accountabilityMission"] as? String{
            this.accountabilityMission = accountabilityMissionValue
        }
        if let addressData = dictionary["address"] as? [String:Any]{
            this.address = AddresRealm.fromDictionary(dictionary: addressData)
        }
        if let admintypeValue = dictionary["admintype"] as? Int{
            this.admintype = admintypeValue
        }
        if let algoTypeValue = dictionary["algo_type"] as? Int{
            this.algoType = algoTypeValue
        }
        if let calenderNotificationValue = dictionary["calender_notification"] as? Int{
            this.calenderNotification = calenderNotificationValue
        }
        if let countryCodeValue = dictionary["country_code"] as? String{
            this.countryCode = countryCodeValue
        }
        if let createdAtValue = dictionary["created_at"] as? String{
            this.createdAt = createdAtValue
        }
        if let deviceTokenValue = dictionary["device_token"] as? String{
            this.deviceToken = deviceTokenValue
        }
        if let dobValue = dictionary["dob"] as? String{
            this.dob = dobValue
        }
        if let emailValue = dictionary["email"] as? String{
            this.email = emailValue
        }
        if let fbConnectedValue = dictionary["fb_connected"] as? Int{
            this.fbConnected = fbConnectedValue
        }
        if let firstNameValue = dictionary["first_name"] as? String{
            this.firstName = firstNameValue
        }
        if let genderValue = dictionary["gender"] as? Int{
            this.gender = genderValue
        }
        if let gymData = dictionary["gym"] as? [String:Any]{
            this.gym = GymRealm.fromDictionary(dictionary: gymData)
        }
        if let heightData = dictionary["height"] as? [String:Any]{
            this.height = HeightRealm.fromDictionary(dictionary: heightData)
        }
        if let interestArray = dictionary["interest"] as? [String]{
            var interestItems = List<String>()
            for value in interestArray{
                interestItems.append(value)
            }
            this.interest = interestItems
        }
        if let isCompanyAccountValue = dictionary["isCompanyAccount"] as? Int{
            this.isCompanyAccount = isCompanyAccountValue
        }
        if let isPrivateValue = dictionary["is_private"] as? Int{
            this.isPrivate = isPrivateValue
        }
        if let lastNameValue = dictionary["last_name"] as? String{
            this.lastName = lastNameValue
        }
        if let locationArray = dictionary["location"] as? [Double]{
            var locationItems = List<Double>()
            for value in locationArray{
                locationItems.append(value)
            }
            this.location = locationItems
        }
        if let phoneValue = dictionary["phone"] as? String{
            this.phone = phoneValue
        }
        if let profileCompletionStatusValue = dictionary["profile_completion_status"] as? Int{
            this.profileCompletionStatus = profileCompletionStatusValue
        }
        if let profilePicValue = dictionary["profile_pic"] as? String{
            this.profilePic = profilePicValue
        }
        if let pushNotificationValue = dictionary["push_notification"] as? Int{
            this.pushNotification = pushNotificationValue
        }
        if let socialMediaArray = dictionary["social_media"] as? [[String:Any]]{
            var socialMediaItems = List<SocialMediaRealm>()
            for dic in socialMediaArray{
                let value = SocialMediaRealm.fromDictionary(dictionary: dic)
                socialMediaItems.append(value)
            }
            this.socialMedia = socialMediaItems
        }
        if let statusValue = dictionary["status"] as? Int{
            this.status = statusValue
        }
        if let tagIdsArray = dictionary["tagIds"] as? [[String:Any]]{
            var tagIdsItems = List<TagIdRealm>()
            for dic in tagIdsArray{
                let value = TagIdRealm.fromDictionary(dictionary: dic)
                tagIdsItems.append(value)
            }
            this.tagIds = tagIdsItems
        }
        if let tokenValue = dictionary["token"] as? String{
            this.token = tokenValue
        }
        if let trackerValue = dictionary["tracker"] as? Int{
            this.tracker = trackerValue
        }
        if let trackerStatusValue = dictionary["tracker_status"] as? Int{
            this.trackerStatus = trackerStatusValue
        }
        if let usernameValue = dictionary["username"] as? String{
            this.username = usernameValue
        }
        if let verifiedStatusValue = dictionary["verified_status"] as? Int{
            this.verifiedStatus = verifiedStatusValue
        }
        if let weightValue = dictionary["weight"] as? Int{
            this.weight = weightValue
        }
        return this
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if id != nil{
            dictionary["_id"] = id
        }
        if accountabilityMission != nil{
            dictionary["accountabilityMission"] = accountabilityMission
        }
        if let address = address{
            dictionary["address"] = address.toDictionary()
        }
        dictionary["admintype"] = admintype
        dictionary["algo_type"] = algoType
        dictionary["calender_notification"] = calenderNotification
        if countryCode != nil{
            dictionary["country_code"] = countryCode
        }
        if createdAt != nil{
            dictionary["created_at"] = createdAt
        }
        if deviceToken != nil{
            dictionary["device_token"] = deviceToken
        }
        if dob != nil{
            dictionary["dob"] = dob
        }
        if email != nil{
            dictionary["email"] = email
        }
        dictionary["fb_connected"] = fbConnected
        if firstName != nil{
            dictionary["first_name"] = firstName
        }
        dictionary["gender"] = gender
        if let gym = gym{
            dictionary["gym"] = gym.toDictionary()
        }
        if let height = height{
            dictionary["height"] = height.toDictionary()
        }
        var dictionaryElements = [String]()
        for i in 0 ..< interest.count {
            let interestElement = interest[i]
            dictionaryElements.append(interestElement)
            
        }
        dictionary["interest"] = dictionaryElements
        dictionary["isCompanyAccount"] = isCompanyAccount
        dictionary["is_private"] = isPrivate
        if lastName != nil{
            dictionary["last_name"] = lastName
        }
        var locationDictionaryElements = [Double]()
        for i in 0 ..< location.count {
            let locationElement = location[i]
            locationDictionaryElements.append(locationElement)
            
        }
        dictionary["location"] = locationDictionaryElements
        if phone != nil{
            dictionary["phone"] = phone
        }
        dictionary["profile_completion_status"] = profileCompletionStatus
        if profilePic != nil{
            dictionary["profile_pic"] = profilePic
        }
        dictionary["push_notification"] = pushNotification
        if socialMedia != nil{
            var dictionaryElements = [[String:Any]]()
            for i in 0 ..< socialMedia.count {
                if let socialMediaElement = socialMedia[i] as? SocialMediaRealm{
                    dictionaryElements.append(socialMediaElement.toDictionary())
                }
            }
            dictionary["social_media"] = dictionaryElements
        }
        dictionary["status"] = status
        var tagIdsDictionaryElements = [[String:Any]]()
        for i in 0 ..< tagIds.count {
            let tagIdsElement = tagIds[i]
            tagIdsDictionaryElements.append(tagIdsElement.toDictionary())
            
        }
        dictionary["tagIds"] = tagIdsDictionaryElements
        if token != nil{
            dictionary["token"] = token
        }
        dictionary["tracker"] = tracker
        dictionary["tracker_status"] = trackerStatus
        if username != nil{
            dictionary["username"] = username
        }
        dictionary["verified_status"] = verifiedStatus
        dictionary["weight"] = weight
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        id = aDecoder.decodeObject(forKey: "_id") as? String
        accountabilityMission = aDecoder.decodeObject(forKey: "accountabilityMission") as? String
        address = aDecoder.decodeObject(forKey: "address") as? AddresRealm
        admintype = aDecoder.decodeObject(forKey: "admintype") as? Int
        algoType = aDecoder.decodeObject(forKey: "algo_type") as? Int
        calenderNotification = aDecoder.decodeObject(forKey: "calender_notification") as? Int
        countryCode = aDecoder.decodeObject(forKey: "country_code") as? String
        createdAt = aDecoder.decodeObject(forKey: "created_at") as? String
        deviceToken = aDecoder.decodeObject(forKey: "device_token") as? String
        dob = aDecoder.decodeObject(forKey: "dob") as? String
        email = aDecoder.decodeObject(forKey: "email") as? String
        fbConnected = aDecoder.decodeObject(forKey: "fb_connected") as? Int
        firstName = aDecoder.decodeObject(forKey: "first_name") as? String
        gender = aDecoder.decodeObject(forKey: "gender") as? Int
        gym = aDecoder.decodeObject(forKey: "gym") as? GymRealm
        height = aDecoder.decodeObject(forKey: "height") as? HeightRealm
        interest = aDecoder.decodeObject(forKey: "interest") as? List<String> ?? List<String>()
        isCompanyAccount = aDecoder.decodeObject(forKey: "isCompanyAccount") as? Int
        isPrivate = aDecoder.decodeObject(forKey: "is_private") as? Int
        lastName = aDecoder.decodeObject(forKey: "last_name") as? String
        location = aDecoder.decodeObject(forKey: "location") as? List<Double> ?? List<Double>()
        phone = aDecoder.decodeObject(forKey: "phone") as? String
        profileCompletionStatus = aDecoder.decodeObject(forKey: "profile_completion_status") as? Int
        profilePic = aDecoder.decodeObject(forKey: "profile_pic") as? String
        pushNotification = aDecoder.decodeObject(forKey: "push_notification") as? Int
        socialMedia = aDecoder.decodeObject(forKey: "social_media") as? List<SocialMediaRealm> ?? List<SocialMediaRealm>()
        status = aDecoder.decodeObject(forKey: "status") as? Int
        tagIds = aDecoder.decodeObject(forKey: "tagIds") as? List<TagIdRealm> ?? List<TagIdRealm>()
        token = aDecoder.decodeObject(forKey: "token") as? String
        tracker = aDecoder.decodeObject(forKey: "tracker") as? Int
        trackerStatus = aDecoder.decodeObject(forKey: "tracker_status") as? Int
        username = aDecoder.decodeObject(forKey: "username") as? String
        verifiedStatus = aDecoder.decodeObject(forKey: "verified_status") as? Int
        weight = aDecoder.decodeObject(forKey: "weight") as? Int
        
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        if id != nil{
            aCoder.encode(id, forKey: "_id")
        }
        if accountabilityMission != nil{
            aCoder.encode(accountabilityMission, forKey: "accountabilityMission")
        }
        if address != nil{
            aCoder.encode(address, forKey: "address")
        }
        admintype = aCoder.decodeObject(forKey: "admintype") as? Int
        algoType = aCoder.decodeObject(forKey: "algo_type") as? Int
        calenderNotification = aCoder.decodeObject(forKey: "calender_notification") as? Int
        if countryCode != nil{
            aCoder.encode(countryCode, forKey: "country_code")
        }
        if createdAt != nil{
            aCoder.encode(createdAt, forKey: "created_at")
        }
        if deviceToken != nil{
            aCoder.encode(deviceToken, forKey: "device_token")
        }
        if dob != nil{
            aCoder.encode(dob, forKey: "dob")
        }
        if email != nil{
            aCoder.encode(email, forKey: "email")
        }
        fbConnected = aCoder.decodeObject(forKey: "fb_connected") as? Int
        if firstName != nil{
            aCoder.encode(firstName, forKey: "first_name")
        }
        gender = aCoder.decodeObject(forKey: "gender") as? Int
        if gym != nil{
            aCoder.encode(gym, forKey: "gym")
        }
        if height != nil{
            aCoder.encode(height, forKey: "height")
        }
        aCoder.encode(interest, forKey: "interest")
        isCompanyAccount = aCoder.decodeObject(forKey: "isCompanyAccount") as? Int
        isPrivate = aCoder.decodeObject(forKey: "is_private") as? Int
        if lastName != nil{
            aCoder.encode(lastName, forKey: "last_name")
        }
        aCoder.encode(location, forKey: "location")
        if phone != nil{
            aCoder.encode(phone, forKey: "phone")
        }
        profileCompletionStatus = aCoder.decodeObject(forKey: "profile_completion_status") as? Int
        if profilePic != nil{
            aCoder.encode(profilePic, forKey: "profile_pic")
        }
        pushNotification = aCoder.decodeObject(forKey: "push_notification") as? Int
        if socialMedia != nil{
            aCoder.encode(socialMedia, forKey: "social_media")
        }
        status = aCoder.decodeObject(forKey: "status") as? Int
        aCoder.encode(tagIds, forKey: "tagIds")
        if token != nil{
            aCoder.encode(token, forKey: "token")
        }
        tracker = aCoder.decodeObject(forKey: "tracker") as? Int
        trackerStatus = aCoder.decodeObject(forKey: "tracker_status") as? Int
        if username != nil{
            aCoder.encode(username, forKey: "username")
        }
        verifiedStatus = aCoder.decodeObject(forKey: "verified_status") as? Int
        weight = aCoder.decodeObject(forKey: "weight") as? Int
    }
}

