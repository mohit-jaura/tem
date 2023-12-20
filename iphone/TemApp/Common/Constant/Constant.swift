//
//  Constant.swift
//  BaseProject
//
//  Created by TpSingh on 22/03/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import UIKit


let oneSignalAppID = "2b08027d-b50b-4de6-8504-b7171231b0d0"
let phoneAccaptableCharacter = "0123456789"
let kShoppifyToken    = "shoppifyToken"
let streamClosedChannelKey = "streamClosedChannel"
let kCartValue    =  "CartValue"

let passwordAccaptableCharacter = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+-=;':?><,./"
let nameAccaptableCharacter = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz .-'"
let emailAccaptableCharacter = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@._-"
let userNameAcceptableCharacter = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789._"

let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
let linkedInUrl = NSString(string:"https://api.linkedin.com/v1/people/~:(id,industry,firstName,gender,,lastName,email,headline,summary,publicProfileUrl,specialties,positions:(id,title,summary,start-date,end-date,is-current,company:(id,name,type,size,industry,ticker)),pictureUrls::(original),location:(name))?format=json")
let appThemeColor = UIColor(red: 17/255, green: 129/255, blue: 222/255, alpha: 1.0)
let foodTrekColor = UIColor(red: 12/255, green: 37/255, blue: 62/255, alpha: 1.0)
let appThemeGrayColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)

let CLIENT_ID = "ad005b8c117cdeee58a1bdb7089ea31386cd489b21e14b19818c91511f12a086"
var localTimeZoneName: String { return TimeZone.current.identifier }
// Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
var RECORDS_PER_PAGE =  Constant.PageLimit.localApi  // use for pagination per page
let MILES_VALUE = 1609.344
let KM_VALUE =  1000.0
let utcTimezone = TimeZone(identifier: "UTC") ?? TimeZone.current
let deviceTimezone = TimeZone.current

enum UserType:Int{
    case simple = 1,fb = 2,google = 3,apple = 4
}
enum EditStatus:Int{
    case no = 0
    case yes
}
enum ResponseApi{
    case Success(_ msg:String?)
    case Failure(_ error:String?)
}

enum ResponseData{
    case Success(_ data:Any?, _ msg:String?)
    case NoDataFound
    case Failure(_ error:String?)
}
enum EmailVerified:Int{
    case no,yes
}
public enum ResponseIn {
    case DataFound
    case NoDataFound
    case Error
}



enum EventMemberType:Int{
    case owner = 0
    case member
}

var shoppifyToken:String{
    get{
        guard let shoppifyToken = UserDefaults.CTDefault(objectForKey: kShoppifyToken) as? String else { return "" }
        return shoppifyToken
    }
    set{
        UserDefaults.CTDefault(setObject: newValue, forKey: kShoppifyToken )
    }
}

typealias CompletionWithSuccessDataError = ((_ status:Bool,_ error:DIError?,_ optionalMsg:String?) -> Void)

typealias CompletionSuccessError = ((_ status:Bool,_ optionalMsg:String?) -> Void)

typealias CompletionResponse = ((_ status:ResponseApi) -> Void)
typealias CompletionDataResponse = ((_ status:ResponseData) -> Void)


typealias CompletionDataApi = ((_ status:ResponseData) -> ())
typealias CompletionOnlySuccess = ((_ status:Bool,_ error:DIError?,_ optionalMsg:String?) -> ())

typealias CompletionWithDataFound = ((_ status:ResponseIn,_ message:String?) -> ())

typealias H_M_S_Competion = ((_ h:Int,_ m:Int,_ s:Int) -> ())
typealias CompletionWithData = ((_ status:ResponseIn,_ data:Any?, _ message:String?) -> ())

typealias  OnlySuccess = (() -> Void)

typealias  DateChanged = ((Date) -> Void)

typealias  BoolCompletion = (Bool) -> Void

typealias  BoolStream = (Bool,StreamModal?) -> Void

typealias  BoolStreamArr = (Bool,[StreamModal]?) -> Void

typealias  AddOnCompetion = (ActivityAddOns?) -> Void

typealias  IndexSelected = (IndexPath) -> Void

typealias  HeightChanged = (CGFloat) -> Void
typealias IntCompletion = (Int,IndexPath) -> ()

typealias StringCompletion = (String) -> ()

typealias OnlyIntCompletion = (Int) -> ()

typealias OnlyDoublbeCompletion = (Double) -> ()
extension UIImage {
    static let sel_But = UIImage(named: "blueRectangle")
    static let unsel_But = UIImage(named: "whiteRectangle")
    static let radioSel = UIImage(named: "Oval Copy 3")

    static let placeHolder = #imageLiteral(resourceName: "ImagePlaceHolder")
    static let fav = #imageLiteral(resourceName: "Combined Shape")
    static let nofav = #imageLiteral(resourceName: "Shape")
}

enum EventInvitationStatus:Int{
    case accepted = 1
    case rejected
    case pending
    case removed
    func getImage() -> UIImage{
        switch self {
        case .accepted:return #imageLiteral(resourceName: "tick")
        case .rejected:return #imageLiteral(resourceName: "closeRed")
        case .pending,.removed:return UIImage()
        }
    }
}

enum DeleteEventType:Int,CaseIterable{
    case thisEventOnly = 0
    case allFutureEvents

    func getTitle() -> String{
        switch self {
        case .thisEventOnly:
            return "Delete This Event Only"
        case .allFutureEvents:
            return "Delete All Future Events"
        }
    }
}

enum EventAcceptRejectStatus:Int{
    case Accept = 1
    case Reject = 2
}

class Constant {
    static let CUR_Sign = "$"

    static let taggedSymbol = "@"
    static let hashSymbol = "#"

    static var reportHeadings = [ReportData]()
    static let contactDescriptionLength = 2000
    struct ApiKeys {

        static let google = "AIzaSyBaxuPBO7gp3HLrECWHvUz8RXQW7agvu00"
    }
    struct NotiName {
        static let cartUpdate = "cart_update"
        static let wishListed = "wishlisted"
        static let monthChanged = "monthChanged"
        static let editEvent = "editEvent"
        static let deleteEvent = "deleteEvent"
        static let refreshEvent = "refreshEvent"

    }

    struct ScreenSize {
        static let height = UIScreen.main.bounds.size.height
        static let width = UIScreen.main.bounds.size.width
        static let SCREEN_WIDTH = UIScreen.main.bounds.size.width
        static let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
        static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
        static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
        static let IPHONE_MAX_WIDTH : CGFloat = 414
    }

    struct Calendar{
        static let startDate = "2001 01 01"
        static let endDate : Date = Date().addYear(31)
    }

    struct DeviceType {
        static let IS_IPHONE_4_OR_LESS =  UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
        static let IS_IPHONE_5 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
        static let IS_IPHONE_6 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
        static let IS_IPHONE_6P = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
        static let IS_IPHONE_X = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 812.0
    }

    struct CoreData {
        static let postEntity = "Postinfo"
        static let FileEntity = "FilesInfo"
        static let AddressEntity = "PostAddress"
        static let userEntity = "UserDetail"
        static let likesEntity = "LikesInfo"
        static let tagEntity = "Tag"

        //enum storing the core data properties names
        //key names for PostInfo entity
        enum PostEntityKeys: String {
            case id = "id"
            case isuploaded = "isuploaded"
            case likedByMe = "likedByMe"
            case likesCount = "likesCount"
            case commentsCount = "commentsCount"
            case uploadingInProgress = "uploadingInProgress"
        }
        enum FileEntityKeys: String {
            case isuploaded = "isuploaded"
            case postId = "postId"
            case id = "id"
        }
    }
    struct MimeType {
        static let image = "image/jpg"
        static let video = "video/mp4"
        static let pdf = "application/pdf"
    }
    struct PageLimit {
        static let  searchThirdParty = 10
        static let localApi = 15
    }
    struct NotificationIdentifier {
        static let Notify  = "Notify"
        static let notificationObserve = "notificationObserve"
    }

    struct Time {
        let now = { round(NSDate().timeIntervalSince1970)} // seconds
    }
    struct App {
        static let delegate = UIApplication.shared.delegate as! AppDelegate
    }
    struct Keys {
        static let deeplinkUrl = "vizu.page.link"
    }
    struct GoogleKey {
        static let services = "AIzaSyDkerkuwcB_eY8jA_hj2oEcyucjubriw5o"
        static let client = "AIzaSyBwsRPq6gNyygdY0BhyvWQZrluriuhVYzw"
    }
    struct Socket {
        static let url = "http://192.168.0.125:3001" //live
    }
    struct CharacterSetForValidation {
        static let nameCharSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-. "
    }
    struct ErrorMsg {
        static let noDataFound = "No Data Found"
        static let noCategory = "Please select category"
        static let noActivity = "Please select activity"
        static let noDuration = "Please select duration more then 0 sec"
        static let noActivitiesFound = "You don't have any activities.Click below button to create."
        static let noEvents = "You don't have any events.Click plus button under calendar to create new event."


    }
    struct UserDefaultKeys {
        static let notificationToken = "notificationToken"
    }
    struct AppColor {
        static let navigationColor = UIColor.white
        static let navigationBarTintColor = UIColor.white
        static let navigationColorTextColor = UIColor.white

    }
    struct ButtonName {
        static let hide:String = "HIDE".localized
        static let show:String = "SHOW".localized
    }
    enum FacebookPermissions:String {
        case email = "email"
        case publicProfile = "public_profile"
        case birthday = "user_birthday"
    }
    enum DateFormates: String {
        case day = "EE"
        case shortDate = "MM-dd-yyyy"   // e.g. 12-04-1994
        case fullDate = "yyyy-MM-dd HH:mm:ss"
        case utcDate = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        case shortTime = "EE, h a"
        case shortTimeHM = "EE, h:mm a"
        case shrtTimeHMFormatted = "EEEE 'at' h:mm a" // e.g. Friday at 2:05 PM
        case dateTimeHMFormat = "MMM dd yyyy 'at' h:mm a"
        case timeHM = "h:mm a"
        case ratingDate = "dd, MMM yyyy"
        case month = "MMMM yyyy"
        case onlymonth = "MMMM"
        case preDefined = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        case calendar = "yyyy MM dd"
        case eventDate = "yyyyMMdd"
        case eventTime = "HHmmssZ"
        case eventSlot = "EEEE, MMM d yyyy"
        case eventUtcDate = "yyyyMMdd'T'HHmmssZ"
        case eventUtcDateString = "yyyy-MM-dd'T'HH:mm:ssZ"
        case editEventDate = "yyyy-MM-dd"
        case editEventTime = "HH:mm:ss.SSSZ"
        case weekSlot = "dd MMM"
        case dateDay = "dd"
        case recurrTime = "HH:mm"
        case fullTime = "HH:mm:ss"
    }

    // enum containing the types for challenges as well as goals
    enum UserActivityType: Int, Codable {
        case open = 1, completed = 2, upcoming = 3

        var value: String {
            switch self {
            case .open:
                return "Open".localized
            case .completed:
                return "Past".localized
            case .upcoming:
                return "Future".localized
            }
        }
    }

    struct Profile {
        static let accountabilityMission = "Describe your accountability mission."
    }
    struct ActivityConstants {
        static let name = "NAME".localized
        static let description = "DESCRIPTION".localized
        static let startDate = "START DATE".localized
        static let duration = "DURATION".localized
        static let activitySelection = "ACTIVITY SELECTION".localized
        static let activities = "ACTIVITIES".localized
        static let temates = "TĒMATES".localized
        static let tem1 = "TĒM 1".localized
        static let tem2 = "TĒM 2".localized
    }
    struct MetricsConstants {
        static let steps = "Steps".localized
        static let distance = "Distance".localized
        static let calories = "Calories".localized
        static let activities = "Activities".localized
        static let activityTime = "Activity Time".localized
    }

    struct SubDomain {

        // MARK: Cart
        static let addCart = "cart"
        static let getCartList = "cart/cartlist"
        static let deleteCartItem = "cart/delete_cart"
        static let kQuantity = "cart/increase_quantity"
        static let kOrder = "order"

        static let login:String = "login"
        static let isSocialMediaExist = "is_social_media_exists"
        static let signUp:String = "signup"
        static let updateFirebaseToken:String = "token"
        static let forgotPassword = "forgot_password"
        static let signupOtpVeify:String = "signup/otp_verify"
        static let forgotPasswordOtpVerify:String = "forgot_password/otp_verify"
        static let createProfile = "profile"
        static let foodTrekAdd = "food-trek/add"
        static let getInterest = "interests"
        static let saveInterest =  "interests/select"
        static let otpCode:String = "verify-otp"
        static let resendOtp:String = "resend-otp"
        static let resetPassword = "reset-password"
        static let changePassword:String = "users/changePassword"
        static let countryCode:String = "settings/countries"
        static let userSuggestion:String = "profile/suggestion"
        static let searchLocation = "profile/search_location"
        static let gymSearchLocation = "profile/gym_search_location"
        static let deletePost = "posts"
        static let reportCategories = "posts/reportCategories"
        static let reportPost = "posts/report"
        static let friendSuggestion = "network/suggestions"
        static let syncContacts = "network/sync_contacts"
        static let markProfileCompletionStatus = "users/profile_status"
        static let logout = "users/logout"
        static let getMyFriendList = "network/friendList"
        static let getMyPendingRequestList = "network/pendingRequest"
        static let getMySentRequestList = "network/sentRequest"
        static let sendFriendRequest = "network/sendRequest"
        static let unfriend = "network/friend"
        static let rejectFriendRequest = "network/rejectRequest"
        static let deleteSentRequest = "network/sentRequest"
        static let postComments = "comments?post_id="
        static let foodPostComments = "foodcomments?post_id="
        static let postLikes = "posts/likes?post_id="
        static let likeOrDislikePost = "posts/like"
        static let foodtreklike = "food-trek/like"

        static let searchPostLikes = "posts/likes/search?page="
        static let comments = "comments"
        static let foodComments = "foodcomments"
        static let remindFriendForSentRequest = "network/remind"
        static let updateEmailPhone = "profile/email_phone"
        static let getOtherUserFriendList = "network/otherFriendList"
        static let searchAllUsers = "network/search"
        static let inviteUsersLink = "settings/invite_link"
        static let sharePost = "posts/share"
        static let getPostDetails = "posts/detail"
        static let updateDeviceToken = "users/device_token"
        static let checkAppUpdate = "settings/version?type=1"

        //Food Trek
        static let setSettingStatus = "network/settingupdate"
        static let getSettingStatus = "network/getsettingdata"
        static let addFriends = "network/addfriend"
        static let getFoodTrekFriends = "network/trekfriendList"
        static let getFoodTrekPostDetail = "food-trek/trek_detail"
        static let getFoodTrekPostlikes = "food-trek/likes?post_id="
        static let saveWaterTrack = "food-trek/add_water_intake"
        //Journal
        static let createJournal = "posts/journaldata"
        static let getJournalsList = "posts/fetchdata"
        static let updateJournal = "posts/updatejournal"

        //ContentMarket
        static let getContentMarketListing = "users/activity/getmarketplace"


        static let selectedplan = "user-plans/selectedplan?id="

        static let contentplanlist = "user-plans/contentplanlist"


        static let getAffiliateMarketContent = "users/activity/getmarketplacedetail"
        static let getparticularcontentdata = "users/activity/getparticularcontentdata"
        static let getMyContentList = "tiles"
        static let addProgram = "program/add_to_calender"
        static let getAffiliateChatRoomId = "chat/chat-affiliate"
        static let addRemoveBookmark = "market-place/addBookMark"
        //Activity.
        static let createRating = "posts/today/rating-data"
        static let createActivity = "activity"
        static let startUserActivity = "users/activity/start"
        static let completeUserActivity = "users/activity/complete"
        static let importExternalUserActivities = "users/activity/import"
        static let getActivity = "activity"
        static let durationList = "activity/duration"
        static let distanceList = "activity/distance"
        static let updateSteps = "users/activity/updateSteps"
        static let rateActivity = "activity/activity_rating"
        static let createActivitiesLog = "users/activity/complete"
        static let getActivitiesLog = "users/activity/useractivitylist"
        static let getAffilativeContent = "users/activity/getcontentdata?marketplaceid="
        static let getAffilativeCommunity = "gnc/contentlist"


        //Payment
        static let getPaymentHistory = "user-plans/history" // to get payment history of user subscription
        static let cancelSubscription = "user-plans/cancelsubscription" // to cancel an active subscription
        static let getAddedCards = "user/get-cards/" // to get user's added cards for subscriptions payment
        static let removeCard = "user-plans/remove-cards" // to remove a card from user's added cards for subscription payment
        static let upgradeSubscription = "user-plans/upgrade-plan" // to upgrade user's active subscription plan
        static let downgradeSubscription = "user-plans/downgradeplan" // to downgrade user's active subscription plan

        //Challenge
        static let challenge = "users/challenge"

        //Goals
        static let createGoal:String = "goals"
        static let getGoals:String = "goals"
        static let getGoalsandChallenges:String = "gnc"
        //Event
        static let event:String = "events"
        static let mycontents:String = "mycontents"
        static let members:String = "members"
        static let eventByDate:String = "listByDate"
        static let join:String = "join"
        static let removeEvent:String = "events/remove_event"
        static let update:String = "update"
        static let listByDate:String = "listByDate"
        static let getWeeklyDays:String = "listparticularDate"
        static let getCompletedGoals = "goals/pendingPosts"
        static let deleteRound = "events/remove_round"
        static let deleteTask = "events/remove_task"
        static let getPaymentLink = "events/event-payment"
        static let getEventChecklist = "events/event_checklist/"
        static let updateTaskCheck = "events/completed_task"
        static let startProgramEvent = "events/event_check"
        static let completeProgramEvent = "program/complete-event"

        //Notifications.
        static let getNotifications:String = "notifications?page="
        static let readNotification:String = "notifications"
        static let getUnreadNotificationsCount = "notifications/count"
        static let clearNotifications = "notifications/clear"
        static let readAllNotification = "notifications/readall"
        static let getRetailNotifications = "notifications/productnotification"

        static let deleteActivity = "users/activity/delete"
        static let updateActivity = "users/activity/update"
        static let addActivity = "users/activity/addactivity"//"activity/addactivity"
        static let radar = "radar"
        static let reports = "reports"
        static let updateSleepTime = "reports/updateSleep"
        static let deleteAccount = "users/changeAccountStatus"
        static let blockedUser = "users/getBlockUserList"
        static let searchBlockedUser = "users/searchBlockedUser"
        static let faqs = "faqs"
        static let contactAdmin = "contactUs"
        static let setProprivate = "users/privateUser"
        static let pushNotificationToggle = "users/pushNotificationToggle"
        static let calenderNotification = "users/calendarNotificationToggle"
        //chat
        static let chatInit = "chat/init"
        static let getChatListing = "chat/chatList"
        static let searchTems = "chat/searchChatGroups"
        static let chatInfo = "chat/info"
        static let chatNotification = "chat/chat_notification"
        static let deleteChat = "chat/chat_delete"
        static let createGroup = "chat/create_group"
        static let editGroup = "chat/edit_group"
        static let getGroupMembersListing = "chat/participants/list"
        static let deleteParticipant = "chat/paticipants/delete"
        static let joinGroup = "chat/join"
        static let getChatFriendListing = "chat/friendList"
        static let makeGroupAdmin = "chat/change_admin"
        static let muteChatNotifications = "chat/paticipants/muteNotifications"
        static let getGroupsListing = "chat/groupList"
        static let getPublicGroupsListing = "chat/publicGroupList"
        static let getGroupLeaderboard = "chat/groupLeaderBoard"
        static let getGroupChallenges = "chat/groupChallengesList"
        static let chatOnlineStatus = "chat/active"
        static let goalChatNotification = "goals/chat/notification"
        static let challengeChatNotification = "users/challenge/chat/notification"
        static let goalOnlineStatus = "goals/chat/active"
        static let challengeOnlineStatus = "users/challenge/chat/active"
        static let muteGoalChat = "goals/chat/mute"
        static let muteChallengeChat = "users/challenge/chat/mute"

        static let getUserLeaderboard = "users/leaderBoardList"
        static let addMembersToLeaderboard = "users/addLeaderBoardMembers"
        static let deleteMemberFromLeaderboard = "users/removeLeaderBoardMembers"

        static let addShortcutToHome = "users/addUpdateHoneyComb"
        static let checkShortcutStatus = "users/checkHoneyCombScreen"
        static let getAllShortcuts = "users/getHoneyComb"

        static let updateBiomarkerPillar = "users/addBiomarkerPillar"
        static let getBiomarkerPillar = "users/getBiomarkerPillar"
        static let getNutritionTrackingPercent = "settings/nutrition_tracking_value"
        static let getHaisTotalScore = "users/haisTotalScore"

        static let getS3UrlForFileUpload = "settings/aws_s3_bucket"

        //tagging
        static let fetchChatGroupMembersToTag = "tag/searchGroupTag"
        static let searchTagUsers = "tag/searchTagUsers"
        static let updateUserTagList = "tag/updateUsertagList"
        static let goalChatMembersSearch = "goals/searchGroupTag"
        static let challengeChatMembersSearch = "users/challenge/searchGroupTag"

        //update tracker status
        static let updateTrackerStatus = "users/trackerStatus"

        static let updateAlgoType = "users/algo_update"


        // Store
        static let getProductList = "retail/product"
        static let getWishlist = "retail/wishlist"
        static let fetchProducts = "retail/product_fetch"
        static let setProductRating = "retail/rate"
        static let getPendingRatingProducts = "retail/pending-ratings"
        static let getPublishRatingProducts = "retail/publish-ratings"

        // Order Address
        static let getAllAddresses = "retail/get_address"
        static let addNewAddress = "retail/Add_address"
        static let updateAddress = "retail/update_address"
        static let getOrdersHistory = "retail/order-history"
        static let getOrderDetail = "retail/order-details/"

        //Coaching tools
        static let getCoachProfile = "coaching-tools/coach-data/"
        static let checkoutUrl = "coaching-tools/checkout"
        static let cancelSuscriptionCoach = "coaching-tools/cancel-subscription/"
        static let getCoachNotifications = "coaching-tools/notification-list"
        static let getCoachList = "coaching-tools/my-coaches"
        static let getStatsData = "coaching-tools/user-reports"
        static let getStatsDta = "coaching-tools/daily-journey-history"
        static let getFaqs = "coaching-tools/faqs?_affiliate="

        // MARK: CoachingTools TODO End Points
        static let toDoList = "coaching-tools/user-todos?page="
        static let toDoDetail = "coaching-tools/todo/"
        static let markToDoComplete = "coaching-tools/complete-todo"
        static let markTaskComplete = "coaching-tools/complete-task"
        static let subTaskComplete = "coaching-tools/complete-subtask"
        static let createTodo = "coaching-tools/user-add-todo"
        static let addBookmark = "coaching-tools/bookmarkadded"
        static let getBookmarkedList = "coaching-tools/bookmarkadded"
        static let saveInBookmark = "coaching-tools/bookmark-add-todo"
        static let editTodo = "coaching-tools/todo"
        static let acceptRejectTodo = "coaching-tools/update-todo-status"
        static let deleteTodo = "coaching-tools/delete-todo"
        // MARK: CoachingTools My Journey Notes End Points
        static let notesList = "coaching-tools/daily-journey"
        static let addNote = "coaching-tools/daily-journey"
        static let notesHistory = "coaching-tools/daily-journey-history?page="

        // MARK: Weight Goal Tracker End Points
        static let getWeightGoal = "profile/get_user_weight_tracker"
        static let getHealthGoalDetails = "profile/gethealthGoalTracker"
        static let addWeightGoal = "profile/add/weight_tracker/data"
        static let addHealthGoal = "profile/add/healthGoalTracker/data"
        static let addWeightGoalLog = "profile/update_log_data"
        static let getWeightGoalSharingStatus = "network/getSettingDataForGoal"
        static let setWeightGoalSharingStatus = "network/settingUpdateForGoal"
        static let getWeightFriendsList = ""
        // MARK: Active Public Tems/Goals/Challenges End Points
        static let getActivePublicTems = "chat/friendPublicChatList?type=2&friend_id="
        static let getActivePublicGoals = "goals/getFriendPublicGoal?status=3&friend_id="
        static let getActivePublicChallenges = "users/challenge/getFriendPublicChallange?status=3&friend_id="

    }

    struct KeyPathObserver {
        static let outputVolume = "outputVolume"    //the observer to detect the volume change in iPhone
    }

    struct WebViewsLink {
        static let termsAndConditions:String = "\(BuildConfiguration.shared.serverUrl)v1/termsConditions"
        static let aboutUs:String = "\(BuildConfiguration.shared.serverUrl)/v1/aboutUs"
        static let faq:String = "http://p2pelite.debutinfotech.com/faqs"
        static let privacyPolicy:String = "\(BuildConfiguration.shared.serverUrl)v1/privacy_policy"
    }

    struct CollectionCellIdentifier {
        static let friendSuggestionCollectionCell:String = "FriendSuggestionCollectionCell"
    }

    struct MaximumLength {
        static let postCaption = 2000
        static let hashTagsCount = 30
        static let userName = 20
        static let firstName = 20
        static let lastName = 40
        static let phoneNumber = 15
        static let password = 16
    }

    struct MinimumLength {
        static let firstLastName = 2
        static let phoneNumber = 8
        static let password = 8
    }

    struct Metrics {
        static let stepsCount = "eg. 1000 steps"
        static let distanceValue = "eg. 5.2 miles"
        static let maxCalories = "eg. 2500 calories"
        static let totalActivities = "eg. 10"
        static let totalActivityTime = "eg. 90 minutes"
    }

    struct GroupActivityConstants {
        //duration list for the challenge or goal
        static let durationList = ["1 day", "2 days", "3 days", "4 days", "5 days", "6 days", "1 week", "2 weeks", "3 weeks", "1 month", "2 months", "3 months"]
    }

    struct RadarMetrics {
        static let social = "Social".localized
        static let medical = "Medical".localized
        static let physicalActivity = "Physical Activity".localized
        static let mental = "Mental".localized
        static let nutrition = "Nutrition".localized
        static let cardiovascular = "Cardiovascular".localized
    }

    enum ScreenFrom {
        case signup
        case editProfile
        case forgotPassword
        case changePassword
        case termsOfService
        case privacyPolicy
        case searchLocation
        case createProfile
        case createPost
        case temates
        case postLikes
        case othersTemates
        case comments
        case searchAppUsers
        case search
        case activity
        case createChallenge
        case createGoal
        case all(type: Constant.UserActivityType?)
        case challenge(type: Constant.UserActivityType?)
        case goal(type: Constant.UserActivityType?)
        case addTemates
        case interest
        case profileRightSideMenu
        case notification
        case tem
        case event
        case eventInfo
        case editEvent
        case fitbitLogin
        case newsFeeds
        case reports
        case totalActivitiesFilter
        case totalActivities
        case activityLog
        case temInfo
        case selectFriend
        case disableAccount
        case account
        case privacySecurity
        case blockedUser
        case notificationSetting
        case about
        case aboutUs
        case faqs
        case contacts
        case contactUs
        case dashboard
        case createGroup
        case editGroup
        case addGroupParticipants
        case createGroupChallenge
        case createGroupEvent
        case editChallenge
        case editGoal
        case chat
        case groupActivityChat
        case apps
        case affiliativeContent
        case shippingAddress
        case checkoutCart
        case retailNotification
        case fromEventActivityOn
        case foodTrekLikes
        case weightGoal
        case foodTrek
        case todo

        var title: String {
            switch self {
            case .forgotPassword:
                return "Forgot Password".localized
            case .changePassword:
                return "Change Password".localized
            case .signup:
                return "Sign Up".localized
            case .editProfile:
                return "Edit Profile".localized
            case .termsOfService:
                return "Term Of Services".localized
            case .privacyPolicy:
                return "Privacy Policy".localized
            case .searchLocation:
                return "Location".localized.uppercased()
            case .createProfile:
                return "Create Profile".localized.uppercased()
            case .createPost:
                return "New Post".localized.uppercased()
            case .temates:
                return "TĒMATES".localized
                case .postLikes, .foodTrekLikes:
                return "SHOUTOUTS".localized
            case .othersTemates:
                return "TĒMATES".localized
            case .comments:
                return "COMMENTS".localized
            case .searchAppUsers, .search:
                return "SEARCH".localized
            case .activity:
                return "ACTIVITY".localized
            case .createGoal:
                return "CREATE GOAL".localized
            case .createChallenge:
                return "CREATE CHALLENGE".localized
            case .addTemates:
                return "ADD TĒMATES"
            case .interest:
                return "INTERESTS"
            case .notification :
                return "NOTIFICATIONS"
            case .tem:
                return "TĒMS"
            case .fitbitLogin:
                return "FITBIT LOGIN"
            case .privacySecurity :
                return "PRIVACY & SECURITY"
            case .all(let type):
                if type != nil {
                    return "ALL".localized
                }
                return "ALL".localized
            case .challenge(let type):
                if type != nil {
                    return type!.value + " Challenges".localized
                }
                return "CHALLENGE".localized
            case .goal(let type):
                if type != nil {
                    return type!.value + " Goals".localized
                }
                return "GOAL".localized
            case .event:
                return "CREATE EVENT".localized
            case .eventInfo:
                return "EVENT INFO".localized
            case .editEvent:
                return "EDIT EVENT".localized
            case .newsFeeds :
                return ""
            case .reports:
                return "REPORTS".localized
            case .totalActivities:
                return "TOTAL ACTIVITIES".localized
            case .activityLog:
                return "ACTIVITY LOG".localized
            case .temInfo:
                return "TĒM INFO".localized
            case .selectFriend:
                return "SELECT FRIEND".localized
            case .blockedUser :
                return "BLOCKED USERS"
            case .account :
                return "ACCOUNT"
            case .notificationSetting:
                return "NOTIFICATION SETTINGS"
            case .about :
                return "ABOUT"
            case .aboutUs :
                return "ABOUT US"
            case .faqs :
                return "FAQ's"
            case .contacts:
                return "CONTACTS"
            case .contactUs :
                return "CONTACT US"
            case .disableAccount :
                return "DISABLE ACCOUNT"
            case .editChallenge:
                return "EDIT CHALLENGE"
            case .editGoal:
                return "EDIT GOAL"
            case .chat:
                return "CHAT"
            case .groupActivityChat:
                return ""
            case .apps:
                return "Link Apps"
            case .affiliativeContent:
                return "Affiliative Content"
            case .shippingAddress:
                return "SHIPPING ADDRESS"
            case .checkoutCart:
                return "CHECKOUT CART"
            case .retailNotification:
                return "Order Details"
            case .foodTrek:
                return "FOOD TREK"
            case .weightGoal:
                return "WEIGHT GOAL"
                case .todo:
                    return "TODO"
            default:
                return ""
            }
        }
        var actionTitle: String {
            switch self {
            case .editProfile:
                return "Update".localized
            case .signup:
                return "Sign Up".localized
            default:
                return ""
            }
        }
    }

    //Firebase Analytics constant

    struct EventName {
        static let totalCreatedChallenges:String = "TotalCreatedChallenges"
        static let totalCreatedGoals:String = "TotalCreatedGoals"
        static let totalUserProfile:String = "TotalUserProfile"
        static let userSessionCount:String = "userSessionCount"
        static let joinGoalsCount:String = "JoinGoalsCount"
        static let joinChallengesCount:String = "JoinChallengesCount"
        static let apiName: String = "apiName"
    }
}//Class

extension Constant.ScreenFrom: Equatable {

    static func == (lhs: Constant.ScreenFrom, rhs: Constant.ScreenFrom) -> Bool {
        switch (lhs, rhs) {
        case (.challenge(let type1), .challenge(let type2)):
            return type1 == type2
        case (.goal(let type1), .goal(let type2)):
            return type1 == type2
        case (.all(let type1), .all(let type2)):
            return type1 == type2
        case (.signup, .signup):
            return true
        case (.editProfile, .editProfile):
            return true
        case (.forgotPassword, .forgotPassword):
            return true
        case (.changePassword, .changePassword):
            return true
        case (.termsOfService, .termsOfService):
            return true
        case (.privacyPolicy, .privacyPolicy), (.searchLocation, .searchLocation), (.createProfile, .createProfile), (.createPost, .createPost):
            return true
            case (.temates, .temates), (.postLikes, .postLikes), (.othersTemates, .othersTemates), (.comments, .comments), (.searchAppUsers, .searchAppUsers), (.activity, .activity), (.newsFeeds, .newsFeeds), (.foodTrekLikes, .foodTrekLikes):
            return true
        case (.createChallenge, .createChallenge), (.createGoal, .createGoal), (.addTemates, .addTemates), (.interest, .interest), (.profileRightSideMenu, .profileRightSideMenu):
            return true
        case (.reports, .reports):
            return true
        case (.chat, .chat):
            return true
        case (.groupActivityChat, .groupActivityChat):
            return true
        case (.totalActivitiesFilter, .totalActivitiesFilter):
            return true
        case (.totalActivities, .totalActivities):
            return true
        case (.activityLog, .activityLog), (.temInfo, .temInfo):
            return true
        case (.dashboard, .dashboard), (.createGroupChallenge, .createGroupChallenge), (.createGroupEvent, .createGroupEvent):
            return true
        case (.createGroup, .createGroup), (.editGroup, .editGroup), (.addGroupParticipants, .addGroupParticipants):
            return true
        case (.affiliativeContent, .affiliativeContent):
            return true
        case(.checkoutCart, .checkoutCart):
            return true
        case(.retailNotification, .retailNotification):
            return true
        case(.eventInfo, .eventInfo):
            return true
        case (.event, .event):
            return true
        case (.weightGoal, .weightGoal), (.foodTrek, .foodTrek):
            return true
            case (.notification, .notification), (.todo,.todo):
               return true
        default:
            return false
        }
    }
}
