//
//  AppMessages.swift
//
//
//  Created by Aj Mehra on 14/10/16.
//  Copyright © 2016 Capovela LLC. All rights reserved.
//

import Foundation
struct AppMessages {
    
    struct AppSpecific {
        static let appName = "The TĒM App".localized//"tēm".localized
    }
    struct Cart {
        static let noCartItem = "No item added in the cart yet."
        
    }
    struct Generic {
        static let loading = "Loading..."
        static let loadingCollections = "Loading Collections..."
    }
    struct Store {
        static let noCollections = "There are no collections added in the store yet!".localized
        static let failedToLoadCollections = "Failed to load collections from the store.".localized
        static let noProducts = "There are no products added in the store.".localized
        static let failedToLoadProducts = "There was some error in loading products. Please try again.".localized
        static let failedToLoadOrders = "There was some error in loading orders. Please try again after sometime.".localized
        static let noOrderHistory = "You donot have any orders.".localized
    }
    struct userAttibute{
        static let emptyOtp:String = "emptyOtp".localized
        static let emptyDOB:String = "emptyDOB".localized
        static let emptyGender:String = "emptyGender".localized
        static let emptyLocation:String = "emptyLocation".localized
        static let emailNotFound = "emailNotFound".localized
    }
    struct APIResponse {
        static let requestTimeOut = "requestTimeOut".localized
        static let internalServerError = "internalServerError".localized
        static let sessionExpired = "sessionExpired".localized
        static let clientError = "clientError".localized
        static let planExpired = "Plan Expired".localized
    }
    
    struct Unkown {
        static let title:String = "".localized
        static let message:String = "Sorry, something went wrong. We're working on getting this fixed as soon as we can.".localized
        static let camera:String = "Besttyme app is not authorized to use camera.".localized
        static let gallery : String = "Besttyme app is not authorized to use gallery images.".localized
    }
    struct AppUpdate{
        static let newUpdate = "New Update is available for application kindly update it.".localized
        static let updateAvailableTitle = "New update available!"
        
        static let update = "Update".localized
        static let cancel = "Cancel".localized
        static let url = "https://itunes.apple.com/app/id1464115798?mt=8"
    }
    
    struct camera {
        static let enablePermission = "Can't access contact, Please go to Settings -> MyApp to enable contact permission".localized
        static let fetchError:String = "Fetch contact error".localized
        static let defaultuserName:String = "No name".localized
        static let photoPermissionTitle:String = "photoPermission".localized
        static let photoPermissionMessage:String = "Allow TĒM to access your photos ".localized
        static let didNotSelectPhoto:String  = "Please select your photo first.".localized
    }
    
    struct SignUp {
        static let firstName = "First Name".localized
        static let lastName = "Last Name".localized
        static let email = "E-Mail".localized
        static let phoneNumber = "Phone Number".localized
        static let addressLine1 = "Address Line 1".localized
        static let addressLine2 = "Address Line 2".localized
        static let createPassword = "Create Password".localized
        static let enterFirstName = "Please enter first name.".localized
        static let enterLastName = "Please enter last name.".localized
        static let enterEmail = "Enter e-mail".localized
        static let enterValidEmail = "Enter valid e-mail".localized
        static let enterPhoneNumber = "Please enter phone number.".localized
        static let invalidPhoneNumber = "Please enter phone number between 8 to 15 digits".localized
        static let enterAddressLine1 = "Enter your address".localized
        static let enterPassword = "Enter password".localized
        static let invalidPasswordFormat = "Please enter password between 8 to 16 characters. Your password should include atleast one uppercase, number and special character.".localized
        static let selectConfirmationOption = "Choose how you would like to receive verification.".localized
        static let termsAndPolicies = "By Signing up I agree to the Terms & Policies of Bottle Driver".localized
        static let invalidDateOfBirth = "Age can be between 10-100 years."
    }
    
    struct Login {
        static let emailOrPhone = "E-Mail or Phone Number".localized
        static let password = "Password".localized
        static let currentPassword = "Current Password".localized
        static let newPassword = "New Password".localized
        static let confirmPassword = "Confirm Password".localized
        static let confirmNewPassword = "Confirm New Password".localized
        static let enterEmailOrPhoneNumber = "Please enter email or phone number.".localized
        static let logout = "Are you sure to logout?".localized
    }
    
    struct OTP {
        static let enterOTP = "Enter your verification code".localized
        static let invalidOTP = "You have entered an incorrect verification code.".localized
        static let timer = "TIMER".localized
        static let sec = "s".localized
    }
    
    struct Location {
        static let title = "Tem".localized
        static let off = "off".localized
        static let empty :String =  "please enter your location".localized
    }
    
    
    struct DOB {
        static let empty = "Please select your date of birth.".localized
    }
    
    
    struct ResetPassword {
        static let enterNewAndConfirmPassword = "Enter and confirm new password".localized
        static let passwordsDonotMatch = "The passwords you have entered do not match".localized
        static let enterCurrentPassword = "Enter current password".localized
        static let confirmPassword = "Confirm new password".localized
        static let enterNewPassword = "Please enter new password.".localized
    }
    
    
    struct AlertTitles {
        static let setting:String = "Setting".localized
        static let error:String = "Error".localized
        static let Ok:String = "OK".localized
        static let Cancel:String = "Cancel".localized
        static let Yes:String = "Yes".localized
        static let No:String = "No".localized
        static let Alert:String = "Alert".localized
        static let logoutMessage:String = "logoutMessage".localized
        static let pleaseWait:String = "pleaseWait".localized
        static let chooseGender:String = "chooseGender".localized
        static let genderMessage:String = "genderMessage".localized
        static let actionSheet:String = "actionSheet".localized
        static let noInternet:String = "noInternet".localized
        static let cannotLogoutWhilePostUploading = "You can't log out while you're uploading something. Please try again once the upload has finished."
        static let done = "Done".localized
    }
    
    struct UserName {
        static let empty:String = "emptyUsername".localized
        static let invalid:String = "validUsernameRange".localized
        static let emptyFirstname:String = "emptyFirstname".localized
        static let maxLengthFirstname:String = "maxLengthFirstname".localized
        static let maxLengthLastname:String = "maxLengthLastname".localized
        static let termsAndCondition:String = "Please accept terms and condition."
        static let enterEmailOrPhone: String = "Please enter email or phone number.".localized
        static let userNameAlreadyExists = "This username already exists."
        
    }
    struct PhoneNumber {
        static let empty:String = "emptyPhoneNumber".localized
        static let invalid:String = "invalidPhoneNumber".localized
        static let newmpty:String = "emptyNewPhoneNumber".localized
        static let newinvalid:String = "invalidNewPhoneNumber".localized
        static let emptyMerchantMobileNo = "emptyMerchantPhoneNumber".localized
        static let invalidMerchantMobileNo = "invalidMerchantPhoneNumber".localized
    }
    struct Password {
        static let emptyLoginPassword = "Please enter password.".localized
        static let emptyPassword:String = "emptyPassword".localized
        static let invalidPassword:String = "invalidPassword".localized
        static let newEmpty:String = "newEmptyPassword".localized
        static let currentPasswordEmpty:String = "emptyCurrentPassword".localized
        static let emptyConfirmPassword = "emptyConfirmPassword".localized
        static let invalidCurrentPassword:String = "validCurrentPasswordRange".localized
        static let invalidNewPassword:String = "validNewPasswordRange".localized
        static let confirmNew:String = "confirmNewPassword".localized
        static let emptyConfirm:String = "emptyConfirm".localized
        static let newConfirmMismatch = "newConfirmMismatch".localized
        static let uppercaseCharacter:String = "uppercaseCharacter".localized
        static let lowercaseCharacter:String = "lowercaseCharacter".localized
        static let number:String = "number".localized
        static let specialCharacter:String = "specialCharacter".localized
        
    }
    struct Email {
        static let emptyEmail:String = "emptyEmail".localized
        static let emptyEmailOrPhoneNo:String = "emptyEmailOrPhone".localized
        static let invalidEmail:String = "invalidEmail".localized
        static let emptyNewEmail:String = "emptyNewEmail".localized
        static let loginEmptyEmail = "Please enter the email associated with your account.".localized
        static let loginInValidEmail = "Please enter valid email.".localized
    }
    struct Image {
        static let invalid = "invalidImage".localized
    }
    struct Voucher {
        static let empty = "emptyVoucherCode".localized
        static let invalid = "invalidVoucherCode".localized
    }
    
    struct Pin {
        static let empty = "emptyPin".localized
        static let invalid = "invalidPin".localized
    }
    
    struct ContactUS {
        struct Title {
            static let empty = "emptyContactUSTitle".localized
        }
        struct Query {
            static let empty = "emptyContactUSQuery".localized
        }
    }
    struct QRCode {
        static let noSupport = "QRNotSupportted".localized
    }
    struct Item {
        static let descMissing = "emptyItemDesc".localized
    }
    struct Purchase {
        static let emptyTotalAmount = "emptyTotalPayableAmount".localized
        static let invalidVoucherAmount = "validTotalPayableAmountRange".localized
        static let emptyRefNo = "emptyTellerReferenceNumber".localized
    }
    struct VerficationPin {
        static let empty = "emptyOTP".localized
        static let invalid = "invalidOTP".localized
        static let expire = "OTPExpired".localized
    }
    struct ScreenTitles {
        static let login = "login".localized
        static let forgotPassword = "forgotPassword".localized
        static let userProfile = "userProfile".localized
        static let editProfile = "editProfile".localized
    }
    
    struct ButtonTitle {
        static let update = "UPDATE".localized
        static let logout = "LOGOUT".localized
    }
    
    struct ErrorAlerts {
        static let unknownError = "unknownError".localized
        static let invalidUrl = "invalidUrl".localized
        static let dataNotFound = "dataNotFound".localized
        static let invalidJson = "invalidJson".localized
        static let missingKeys = "missingKeys".localized
        static let invalidData = "invalidData".localized
        static let responseError = "responseError".localized
        static let dictNotFound = "dictNotFound".localized
    }
    
    struct Post {
        static let publishOffline = "offlinePublish".localized
        static let publishOnline = "Your post has been created successfully".localized
        static let spotEdited = "spotEdited".localized
        static let invalidHashtagsCount = "Caption cannot contain more than 30 hashtags.".localized
        static let errorFetchingNewsFeeds = "Error in fetching news feeds".localized
        static let likeByTemate = "of your tēmates liked this.".localized
        static let commentByTemate = "of your tēmates commented on this.".localized
        
    }
    
    struct ProfileMessages {
        static let deleteStoryTitle = "Delete Story"
        static let deleteStoryMessage = "This will remove story permanantly. Are you sure ?"
        static let addStory = "Add Story"
        static let addFriend = "Add friend"
        static let friendRequestSent = "Friend request sent successfully"
        static let sendRequestHint = "This will send a friend request to user"
        static let deleteRequest = "Delete Request"
        static let deleteRequestHint = "This will cancel the sent friend request."
        static let cancelRequest = "Cancel Request"
        static let removefriend = "Remove Friend"
        static let removeFriendHint = "This will remove the user from your friend list. Are your sure?"
        static let unfriend = "Remove Friend"
        static let requestSent = "Request Sent"
        static let friendRequestCancelled = "Friend request cancelled"
        static let friendRemoved = "User removed from the friends list successfully."
        static let respond = "Respond"
        static let respondRequest = "Respond Friend Request"
        static let respondRequestHint = "This user wants to be your friend. Please select your response below"
        static let accept = "Accept Request"
        static let reject = "Reject Request"
        static let friends = "Connected"
        static let warning = "Warning"
        static let deleteProfile = "This user account has been deleted."
        static let noNotificationFound = "No new notifications received yet!"
        static let logout = "Logout"
        static let logoutMessage = "Are you sure you want to logout?"
        static let cancelFriendRequest = "Sent request cancelled successfully"
        static let accountabilityMission = "Please enter your accountability mission."
        static let selectGymClub = "Please select gym club"
        static let enterGymClubValue = "Please enter gym location"
        static let accountabilityPlaceholder = "Type your accountability mission here. This is your “why.” Why are you chosing to own your health and wellness journey?"
        
    }
    
    struct CommanMessages {
        static let yes = "Yes"
        static let cancel = "Cancel"
        static let edit = "Edit"
        static let done = "Done"
        static let success = "Success"
        static let ok = "Ok"
        static let warning = "Warning"
    }
    
    struct UserProfileMessage {
        static let noStoriesFound = "No stories added yet"
        static let noCheckinFound = "No checkins yet"
        static let privateProfile = "This profile is private"
    }
    
    struct NetworkMessages {
        static let buttonRetry = "Retry"
        static let noFbFriends = "No suggestions yet"
        static let retryErrorMessage = "No suggestions yet"
        static let fbButtonTitle = "LOGIN WIH FACEBOOK"
        static let noFriendsYet = "No tēmates yet"
        static let noTemsYet = "No tēms yet"
        static let inviteFriends = "tēm offers great to connect with near by friends. Download it from App Store"
        static let removeFriend = "Are you sure you want to disconnect from this tēmate"
        static let noSearchFound = "Oops! We couldn't find any people with this name"
        static let noRecordToDisplay = "No records to display"
        static let delete = "Delete"
        static let noFriendYet = "No tēmates yet"
        static let friendListTitle = "Friends list"
        static let disconnect = "Disconnect".localized
        static let noSuggestions = "No suggestions yet"
        static let noFriendsListing = "The user has no tēmates yet."
        
        static let maximumShortcutsAdded = "You must remove a tile in order to add this tile to the honeycomb home screen.".localized
        static let addToHomeScreen = "Are you sure you want to add to honeycomb home screen?".localized
        static let removeFromHomeScreen = "Are you sure you want to remove from honeycomb home screen?".localized
        static let deleteNotifcation = "Are you sure to delete this notification?"
        
    }
    struct Comments {
        static let noComments = "No comments added yet.Be first by posting your comment".localized
        static let enterComment = "Please enter comment".localized
    }
    
    struct GroupActivityMessages {
        static let emptyName = "Please enter name".localized
        static let emptyStartDate = "Please enter start date".localized
        static let emptyDuration = "Please enter duration".localized
        static let selectChallengeMetrics = "Please select atleast one metric for challenge".localized
        static let emptyActivityType = "Please select activity type".localized
        static let emptyTemates = "Please select atleast one tēmate".localized
        static let emptyTem = "Please select a Tēm for challenge".localized
        static let emptyTem1 = "Please select Tēm1".localized
        static let emptyTem2 = "Please select Tēm2".localized
        static let differentTems = "Please select Tēm2 different from Tēm1".localized
        static let selectGoalMetric = "Please select one metric for goal".localized
        static let joinTitle = "Join".localized
        static let joined = "Joined".localized
        
        static let noOpenChallengesorgoal = "You do not have any open challenges or goals".localized
        static let noPastChallengesorgoal = "You do not have any past challenges or goals".localized
        static let noFutureChallengesorgoal = "You do not have any future challenges or goals".localized
        
        static let noOpenChallenges = "You do not have any open challenges".localized
        static let noPastChallenges = "You do not have any past challenges".localized
        static let noFutureChallenges = "You do not have any upcoming challenges".localized
        
        static let noOpenGoals = "You do not have any open goals".localized
        static let noPastGoals = "You do not have any past goals".localized
        static let noFutureGoals = "You do not have any upcoming goals".localized
        static let leader = "Leader".localized
        
        static let goalAchieved = "Goal Achieved"
        static let goalIncomplete = "Goal Incomplete"
        static let goalInProgress = "Goal In Progress"
        
        static let sureToStopActivity = "Are you sure you want to stop the current activity?".localized
        
        static let removeActivity = "Are you sure you want to delete the activity?"
        static let editExternalActivity = "Selected activity is imported from external application. Do you want to edit it?"
        static let activityNotFound = "This category does not contain any activity. Please select another category"
        static let runningActivity = "You already have an activity in running state.To create new one you have to complete the current activity by Home -> Add/Track Activity"
        static let watchActivityInProgress = "You have an activity in running state.To logout you have to complete/stop the current activity.".localized
    }
    
    struct Report {
        static let noActivitiesFound = "Oops! You don't have any activity for the filter selected."
    }
    
    struct TematesAction {
        static let accept = "Accept".localized
        static let remind = "Remind".localized
        static let add = "Add".localized
        static let sent = "Sent".localized
        static let remove = "Remove".localized
    }
    
    struct DashboardActions {
        static let calendar = "CALENDAR".localized
        static let activity = "ACTIVITY".localized
        static let challenges = "CHALLENGES".localized
        static let tems = "SOCIAL".localized
        static let goals_challenge = "GOALS & CHALLENGES".localized
        static let profile = "PROFILE & \nTĒMATES".localized
        static let post = "POST".localized
        static let leaderboard = "LEADERBOARD".localized
        static let creategoal = "Create Goal".localized
        static let createChallenge = "Create Challenge".localized
        static let hais = "HAIS".localized
    }
    
    struct Metric {
        static let emptyValue = "metricEmptyValue".localized
    }
    
    struct Event{
        static let delete = "Are you sure you want to delete the event?".localized
        static let unableToStart = "You can not start this event"
    }
    
    struct GlobalSearch {
        static let noAll = "No tēmates, posts, tēms, goals or challenges found\nEnter text in search field or change your entered text to find some".localized
        static let noTems = "No public tēms found\nEnter text in search field or change your entered text to find tems.".localized
        static let noTemates = "No tēmates found\nEnter text in search field or change your entered text to see friends".localized
        static let noPosts = "No posts found\nEnter text in search field or change your entered text to find posts created by your friends".localized
        static let noGoals = "No goals found\nEnter text in search field or change your entered text to find some".localized
        static let noChallenge = "No challenges found\nEnter text in search field or change your entered text to find some".localized
        static let noEvents = "No calendar events found\nEnter text in search field or change your entered text to find some".localized
    }
    
    struct Chat {
        static let unfriendCannotChat = "You can’t send messages to this user as you are not tēmates.".localized
        static let blockedCannotChat = "You can’t send messages to this conversation.".localized
        static let cannotChatInThisRoom = "You can’t send messages to this conversation.".localized
        static let enterGroupName = "Please enter the name of your tem.".localized
        static let selectTematesForTem = "Please add atleast one temate to create your tem.".localized
        static let selectGroupVisibility = "Please select group visibility.".localized
        static let makeGroupAdmin = "Make group admin".localized
        static let adminExitGroup = "You are currently the admin of this chat group. Exiting the chat group will disable it for other members as well. Please assign someone else as the admin so other users can continue using this group.".localized
        static let memberExitGroup = "Are you sure you want to exit this group?".localized
        static let memberJoinGroup = "Are you sure you want to join this group?".localized
        static let cannotMessageInGroup = "You can't send messages to this group because you're no longer a participant.".localized
        static let cannotMessageInChallenge = "You can't send messages to this group because you are not the part of this challenge."
        static let cannotMessageInGoal = "You can't send messages to this group because you are not the part of this goal."
        static let readAll = "Read All".localized
        static let clearAll = "Clear All".localized
        static let cannotMessageInLiveChat = "Can't send the message right now, Please try again after some time."
        
    }
    
    struct ContactUs {
        static let emptySubject = "emptyContactSubject".localized
        static let emptyMessage = "emptyContactDesc".localized
    }
    
    struct ChangePassword {
        static let newPasswordBlank = "newPasswordBlank".localized
        static let currentPasswordBlank = "currentPasswordBlank".localized
        static let confirmPasswordBlank = "confirmPasswordBlank".localized
        static let passwordDoesnotMatch = "passwordDoesnotMatch".localized
        
    }
    
    struct Leaderboard {
        static let removeMember = "Are you sure you want to remove this tēmate from leaderboard?".localized
    }
    
    struct HAIS {
        static let enterSystolicBloodPressure = "Please enter valid value of systolic blood pressure.".localized
        static let enterDiastolicBloodPressure = "Please enter valid value of diastolic blood pressure.".localized
        static let enterNutritionTrackingPercent = "Please enter nutrition tracking percentage."
    }
    
    struct Fundraising {
        static let title = "Fundraising".localized
        static let fundraisingFinished = "Fundraising has already been finished".localized
    }
    
    struct PopOver {
        static let accountabilityIndex = """
        Your Accountability Index is a numerical representation of how you perform against what you commit to and the industry standard recommendations on healthy behaviors. In order to increase your Accountability Index you need to schedule events on your calendar and then follow through and complete them. You can also create and achieve goals. Lastly, in your day-to-day routine we calculate your activities against the recommendations (for example, the CDC recommends an adult completes 60 mintues of activity per week).

        During an internal study we found that adults believe that they hold themsleves roughly 90% accountable to their health and wellness. However, upon futher review the number was closer to 30%. We believe that having a clear understanding of how you invest in your total health will help you set realistic goals and help you control your progress.
        """
    }
    struct ContentMarket{
        static let noPlan = "No plans added yet"
        static let purchasePlan = "You can not access this content, please subscribe any one plan from subscription screen"
    }
    
    struct RateDay{
        static let RatingMsg = "Rate your day"
        static let selectRating = "Please select at least one rating"
        static let ratingAdded = "Rating added successfully !"
        static let ratingUpdated = "Rating updated successfully !"
    }
}
