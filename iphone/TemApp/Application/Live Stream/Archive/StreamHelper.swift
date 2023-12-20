//
//  StreamHelper.swift
//
//  TemApp
//
//  Created by PrabSharan on 31/08/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

enum StreamType:Int {
    case Video = 2
    case Stream = 1
}
//enum WhoIsStreaming {
//    case AdminPublicStream
//    case VideoCall
//    case AffiliatePublicStream
//}
enum WhoIsHosting {
    case Admin(type:StreamType)
    case Affiliate(type:StreamType)
}
public  struct ClosedStreamChannels:Codable {
    let channelID:String
    let affID:String
}

class Stream {
    static let connect = Stream()
    var  isVideoShown: Bool = false
    private var parent:DIBaseController?
    static var affiliateID:String?
    static var isComingFromInActiveApp:Bool = false
    var streamModal:StreamModal?
    var streamHelper:StreamHelper?
    var chatManager:ChatManager?
    let streamIcon = "📺"
    var bannersArr : [FloatingNotificationBanner]?
    var streamersArr : [StreamModal]?

    private init() {
        isVideoShown = false
    }
    func openPop(_ type:StreamPopup,parent:DIBaseController? = nil,_ close:OnlySuccess? = nil) {
        let VC = loadVC(.PopUpStreamVC) as! PopUpStreamVC
        VC.modalTransitionStyle = .crossDissolve
        VC.streamPopup = type
        VC.close  = close
        VC.modalPresentationStyle = .fullScreen
        parent?.present(VC, animated: false, completion: nil)
    }
    func close(parent:DIBaseController?) {
        parent?.dismiss(animated: false)
    }
    // Avoid to re-open again
    func addDetailsToDefaults(_ channelID:String?,_ affID:String?) {
        guard let channelID = channelID,let affID = affID else {return}
        if let data = UserDefaults.getSavedData( streamClosedChannelKey) as? Data {
            if var modalArr =
                try? PropertyListDecoder().decode([ClosedStreamChannels].self, from: data) {
                // Remove older affids
                modalArr.removeAll(where: {$0.affID == affID})
                modalArr.append(ClosedStreamChannels(channelID:channelID  , affID: affID))
                // Saved new array after removing closed Header
                try? UserDefaults.standard.set(PropertyListEncoder().encode(modalArr), forKey: streamClosedChannelKey)
                UserDefaults.standard.synchronize()

            } else {
                // First element to be saved
               let  modalArr = [ClosedStreamChannels(channelID:channelID,  affID: affID)]
                try? UserDefaults.standard.set(PropertyListEncoder().encode(modalArr), forKey: streamClosedChannelKey)
                UserDefaults.standard.synchronize()
            }
        } else {
            // First element to be saved
           let  modalArr = [ClosedStreamChannels(channelID:channelID,  affID: affID)]
            try? UserDefaults.standard.set(PropertyListEncoder().encode(modalArr), forKey: streamClosedChannelKey)
            UserDefaults.standard.synchronize()
        }
    }

    private func didCloseChannel(_ affID:String?,_ channelID:String?) -> Bool {
        guard let affID = affID,let channelID  = channelID else { return false}
        if let data = UserDefaults.getSavedData( streamClosedChannelKey) as? Data {
            if let modalArr = try? PropertyListDecoder().decode([ClosedStreamChannels].self, from: data) {
                if let index = modalArr.firstIndex(where: {$0.affID == affID}) {
                    return modalArr[index].channelID == channelID
                }
            }
        }
        return false
    }
    func filterArrOfChannels(_ streamArr:[StreamModal]?) {
        guard let streamArr = streamArr else {return}
        var tempArr = [StreamModal]()
        for i in 0..<streamArr.count {
            if !didCloseChannel(streamArr[i].affiliate_id, streamArr[i].channel_id) {
                tempArr.append(streamArr[i])
            }
        }
        print(tempArr.count)
        // filter out video calls and admin calls
        self.streamersArr = tempArr.filter({isVideoCall($0) || $0.isAffiliate == 0})
        print(streamersArr?.count)
    }
    func showAllBannersInQueue() {
        resetAllBanners()
        var tempArr = [FloatingNotificationBanner]()
        for i in 0..<(streamersArr?.count ?? 0) {
            if  let banner =  createBanner(streamModal: streamersArr?[i], parent: parent) {
                tempArr.append(banner)
            }
        }
        bannersArr = tempArr
        let queue = NotificationBannerQueue(maxBannersOnScreenSimultaneously: 3)
        print(bannersArr?.count)
        bannersArr?.forEach { banner in
                 banner.show(
                    bannerPosition: .top,
                    queue: queue,
                    cornerRadius: 10,
                    shadowBlurRadius: 15)
          }
    }
    func streamType(_ modal:StreamModal? ) -> WhoIsHosting? {
        guard let modal  = modal else {return nil}
        //Admin & Video Call
        if isVideoCall(modal) && modal.isAffiliate == 0 {
            return .Admin(type: .Video)
        } else if !isVideoCall(modal) && modal.isAffiliate == 0 { // Admin & Public streaming
            return .Admin(type: .Stream)
        } else if !isVideoCall(modal) && modal.isAffiliate == 1 { //Affiliate & Streaming
            return .Affiliate(type: .Stream)
        } else if isVideoCall(modal) && modal.isAffiliate == 1 { // Affiliate & Public streaming
            return .Affiliate(type: .Video)
        }
        return nil
    }
    func showHeader(modal:StreamModal?,parent:DIBaseController? = nil) {
        // need to check whether we have already closed channel or not
        // if false than need to open header according to view
        if  !didCloseChannel(modal?.affiliate_id, modal?.channel_id) {
            guard let modal = modal else {return}
            resetAllBanners()
            streamersArr = [modal]
            showAllBannersInQueue()
        }
    }

    func createBanner(streamModal:StreamModal? = nil,msg:String? = nil,name:String? = nil, parent:DIBaseController? = nil) -> FloatingNotificationBanner? {
        if let liveStreamStatusBarView = Bundle.main.loadNibNamed(LiveStreamStatusBarView.identifier, owner:.none)?.first as? LiveStreamStatusBarView {
            if msg != nil {
                liveStreamStatusBarView.label.text = msg
            } else {
                if let whoIsLive = streamType(streamModal) {
                    switch whoIsLive {
                    case .Admin(let type):
                        switch type {
                        case .Video:
                            liveStreamStatusBarView.label.text = "The TĒM App wants to stream \(streamIcon) with you"
                        case .Stream:
                            liveStreamStatusBarView.label.text = "The TĒM App is Live \(streamIcon)"
                        }
                    case .Affiliate(let type):
                        switch type {
                        case .Video:
                            liveStreamStatusBarView.label.text = "\(name ?? "Affiliate") wants to stream \(streamIcon) with you"
                        case .Stream:
                            liveStreamStatusBarView.label.text = "\(name ?? "Affiliate") is Live \(streamIcon). Join to see what they’re talking about"
                        }
                    }
                    let banner = FloatingNotificationBanner(customView: liveStreamStatusBarView,streamModal: streamModal)
                    banner.transparency = 0.80
                    banner.autoDismiss = false
                    liveStreamStatusBarView.streamModal = streamModal
                    liveStreamStatusBarView.closeTapped = { (streamModal) in
                        print("Banner closed Tapped")
                        // Get removed index to avoid re-appear again
                        // Need to add closed channel info to user default
                        if let removedIndex =   self.streamersArr?.firstIndex(where: {$0.channel_id == streamModal?.channel_id}) {

                            self.bannersArr?[removedIndex].dismiss()
                            self.streamersArr?.remove(at: removedIndex)
                            self.addDetailsToDefaults(streamModal?.channel_id, streamModal?.affiliate_id)
                        }
                    }
                    banner.onTapWithData = { (streamModal) in
                        // Need to hit an Api
                    //    self.toServer(affId,true,parent)
                        print("Banner Notification Tapped")
                        if let removedIndex =   self.streamersArr?.firstIndex(where: {$0.channel_id == streamModal?.channel_id}) {

                            self.bannersArr?[removedIndex].dismiss()
                            self.streamersArr?.remove(at: removedIndex)
                            self.addDetailsToDefaults(streamModal?.channel_id, streamModal?.affiliate_id)
                            self.toServer(streamModal?.affiliate_id, true, nil)
                        }
                    }
                    banner.onSwipeUpWithData = { (streamModal) in
                        if let removedIndex =   self.streamersArr?.firstIndex(where: {$0.channel_id == streamModal?.channel_id}) {

                            self.bannersArr?[removedIndex].dismiss()
                            banner.dismiss()
                            self.streamersArr?.remove(at: removedIndex)
                            self.addDetailsToDefaults(streamModal?.channel_id, streamModal?.affiliate_id)
                        }
                    }
//                    banner.show(queuePosition: .front,
//                   bannerPosition: .top,
//                   cornerRadius: 10,
//                   shadowBlurRadius: 15)
                    return banner
                }
            }
        }
        return nil
    }


    func getAllStreamers(_ isLoader:Bool = false,_ parent:DIBaseController? = nil,_ completion:BoolStreamArr? = nil) {
        if parent == nil {
            self.parent = UIApplication.getTopViewController() as? DIBaseController
        } else {
            self.parent = parent
        }
        DispatchQueue.main.async {

            StreamHelper().getAllStreamers(isLoader: isLoader,parent: parent, callback: { [weak self] status in
                switch status {

                case .Success(let data, _):
                    if let modal = data as? [StreamModal] {
                        if completion == nil {
                            DispatchQueue.main.async {
                                self?.filterArrOfChannels(modal)
                                self?.showAllBannersInQueue()
                            }
                        } else {
                            completion?(true,modal)
                        }
                    }
                case .NoDataFound:
                    if completion == nil {
                        parent?.alertOpt(DIError.noResponse().message)
                    } else {
                        completion?(false,nil)
                    }
                case .Failure(let error):
                    if completion == nil {
                        parent?.alertOpt(error)
                    } else {
                        completion?(false,nil)
                    }
                }
            })
        }
    }

    func toServer(_ affID:String?,_ isLoader:Bool = false,_ parent:DIBaseController? = nil,_ completion:BoolStream? = nil) {
        guard let affID = affID else {
            return
        }
        Stream.connect.isVideoShown = false
        if parent == nil {
            self.parent = UIApplication.getTopViewController() as? DIBaseController
        } else {
            self.parent = parent
        }
        streamHelper = StreamHelper(affID)
        streamHelper?.getConnect(isLoader: isLoader, parent: parent) {[weak self] status in
            switch status {

            case .Success(let data, _):
                if let modal = data as? StreamModal {
                    if completion == nil {
                        if  modal.channel_id != nil && modal.uid != nil, let amt = modal.amount {
                            self?.streamModal = modal
                            self?.streamHelper?.amount = amt
                            if self?.isVideoCall(modal) ?? false {
                                self?.navigate(self?.streamModal)
                            } else {
                                self?.initialiseRecentJoinedCallBacks()
                            }
                        } else {
                            guard let parent = parent else {return }
                            parent.alertOpt("Error connecting to host, try again later after some time.", okayTitle: "Exit", okCall: {
                                parent.dismiss(animated: true)
                            }, parent: parent)
                        }
                    } else {
                        completion?(true,modal)
                    }
                }
            case .NoDataFound:
                if completion == nil {
                    parent?.alertOpt(DIError.noResponse().message)
                } else {
                    completion?(false,nil)
                }
            case .Failure(let error):
                if completion == nil {
                    parent?.alertOpt(error)
                } else {
                    completion?(false,nil)
                }
            }
        }
    }
    func checkIsSubsribed(_ modal: StreamModal?) -> Bool {
        if let isPaid = modal?.is_paid, let isStreamFree = modal?.isStreamFree {

            if (isStreamFree == 0) {
                if let amount = modal?.amount {
                    if amount <= 0 || isPaid == 1 { // Amount is free so user can connect
                        return true
                    } else {
                        // show error message
                        guard let parent = parent else {return false }
                        parent.alertOpt("To join host please pay \(amount) amount", okayTitle: "Pay",cancelTitle: "No", okCall: {
                            self.apiToPayStreamFees()
                            //Navigate to Next Payment page
                        }, parent: parent)
                    }
                }
            } else { // Already Subscibed
                return true
            }
        }
        return false
    }

    // MARK: Set Call Backs and Timers from VC

    func initialiseRecentJoinedCallBacks() {
        chatManager = ChatManager()
        writeRecentTimeToFB()
        connectToJoinedMembers()
    }
    func isVideoCall(_ streamModal:StreamModal?) -> Bool {
        if let isVideoCall = streamModal?.isVideoCall {
            return StreamType(rawValue: isVideoCall) == .Video
        }
        return false
    }
    func resetAllBanners() {
        for i in 0..<(bannersArr?.count ?? 0) {
            bannersArr?[i].dismiss()
        }
//        bannersArr = []
//        streamersArr = []
    }

    func connectToJoinedMembers() {
        chatManager?.queryRecentlyJoinedMembers(streamModal?.chat_room_id ?? "") { [weak self] count in
            guard let self = self else {return }
            DispatchQueue.main.async {
                debugPrint(count)
                if count >= self.streamModal?.joinedUsersLimit ?? 100 {
                    guard let parent = self.parent else {return }
                    parent.alertOpt("Exceed Limit, Sorry you can't connect with host, please try again after sometime.", okayTitle: "Ok", okCall: {
                    })
                } else if !Stream.connect.isVideoShown {
                    self.navigate(self.streamModal)
                }
            }
        }
    }
    func resetJoinedMembers() {
        chatManager?.streamJoinedListener?.remove()
        chatManager?.streamJoinedListener  = nil
        chatManager?.removeRecentlyJoined(streamModal?.chat_room_id ?? "")
        chatManager = nil

    }

    @objc func writeRecentTimeToFB() {
        chatManager?.writeJoinedCount(chatId: streamModal?.chat_room_id ?? "")
    }
    func navigateToPayment(url:String?) {
        guard let url = url else {return}
        let webView:TermsAndConditions = UIStoryboard(storyboard: .main).initVC()
        webView.urlString = url
        webView.paymentFrom = .Stream
        webView.isSuccess = {[weak self](isSuccess) in
            if isSuccess {
                self?.streamModal?.is_paid  = 1
            }
            self?.navigate(self?.streamModal)
        }
        webView.navigationTitle = "Payment"
        parent?.present(webView, animated: true)
    }
    func apiToPayStreamFees() {
        streamHelper?.payfeesApi(isLoader:true, parent: parent) {[weak self] status in
            switch status {
            case .Success(let url, _):
                if let url = url as? String {
                    DispatchQueue.main.async {
                        self?.navigateToPayment(url: url)
                    }
                }
            case .NoDataFound:
                self?.parent?.alertOpt(DIError.noResponse().message)
            case .Failure(let error):
                self?.parent?.alertOpt(error)
            }
        }
    }
    func checkLimitForNumberOfUsers() {

    }
    private func navigate(_ modal: StreamModal?) {
        if checkIsSubsribed(modal) {
            resetJoinedMembers()
            if let isVideoCall = modal?.isVideoCall,let type = StreamType(rawValue: isVideoCall) {
                switch type {
                case .Video: navigateToVideoCall(modal)
                case .Stream: navigateToStream(modal)
                }
            }
        } else {

        }
    }
    func showAlert(_ msg:String,_ parent:DIBaseController? = nil) {
        parent?.alertOpt(msg)
    }
    private func navigateToVideoCall(_ modal:StreamModal?) {
        let selectedVC = loadVC(.VideoChatViewController) as! VideoChatViewController
        selectedVC.modalTransitionStyle = .coverVertical
        selectedVC.streamModal = modal
        selectedVC.modalPresentationStyle = .fullScreen
        parent?.present(selectedVC, animated: true, completion: nil)
    }
    private func navigateToStream(_ modal:StreamModal?) {
        let selectedVC = loadVC(.StreamAudienceVC) as! StreamAudienceVC
        selectedVC.streamModal = modal
        selectedVC.modalTransitionStyle = .coverVertical
        selectedVC.modalPresentationStyle = .fullScreen
        parent?.present(selectedVC, animated: true, completion: nil)
    }
}

class StreamHelper:NSObject {

    static let appId: String = "d27c08dd634d4aabaed71ad4545f8f85"
    static let adminID: String = "61b8522592f43e8a77ee0ded"// live admin id (For Dev server ->" 61b8522592f43e8a77ee0ded")

    static let secForWriteDelay: Double = 180

    var streamModal:StreamModal?
    var affiliateId:String?
    var amount:Double?
    init(_ affiliateId:String) {
        super.init()
        self.affiliateId = affiliateId
    }
    override init() {
        super.init()
        }

    func payfeesApi(isLoader:Bool = false,parent:DIBaseController? = nil, callback: @escaping  CompletionDataResponse) {
        let urlInfo = EndPoint.PayStreamFees(affID:affiliateId, amount: amount)

        if isLoader { parent?.showLoader() }

        DIWebLayer.instance.webManager.post(method: .post, function: urlInfo.url, parameters: urlInfo.params) { data in
            // Parse Data Here & convert it into modal
            DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }

            do {
                let modal   = try JSONDecoder().decode(PaymentStreamModal.self, from: data)
                //Look for data is there or not

                let isSuccess = modal.status == 1

                if isSuccess {
                    callback(.Success(modal.url, "Url"))
                } else {
                    callback(.Failure(DIError.invalidData().message))
                }
            } catch let error {
                debugPrint(error)
                callback(.Failure(DIError.invalidData().message))
            }
        }
    failure: { error in
        DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }

        callback(.Failure(error.message))
    }
    }
    func getAllStreamers(isLoader:Bool = false,parent:DIBaseController? = nil, callback: @escaping  CompletionDataResponse) {
        let urlInfo = EndPoint.GetAllStreamers

        if isLoader { parent?.showLoader() }

        DIWebLayer.instance.webManager.post(method: .get, function: urlInfo.url, parameters: nil) { data in
            // Parse Data Here & convert it into modal
            DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }

            do {
                let modal   = try JSONDecoder().decode(AllStreamArr.self, from: data)
                //Look for data is there or not

                let isSuccess = modal.status == 1

                if isSuccess {
                    callback(.Success(modal.data, "Connected"))
                } else {
                    callback(.Failure(DIError.invalidData().message))
                }
            } catch let error {
                debugPrint(error)
                callback(.Failure(DIError.invalidData().message))
            }
        }
    failure: { error in
        DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }

        callback(.Failure(error.message))
    }
    }

    func getConnect(isLoader:Bool = false,parent:DIBaseController? = nil, callback: @escaping  CompletionDataResponse ) {
        let urlInfo = EndPoint.GetStreamInfo(affID:affiliateId)

        if isLoader { parent?.showLoader() }

        DIWebLayer.instance.webManager.post(method: .get, function: urlInfo.url, parameters: nil) { data in
            // Parse Data Here & convert it into modal
            DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }

            do {
                let modal   = try JSONDecoder().decode(StreamModalInfo.self, from: data)
                //Look for data is there or not

                let isSuccess = modal.status == 1

                if isSuccess {
                    callback(.Success(modal.data, "Connected"))
                } else {
                    callback(.Failure(DIError.invalidData().message))
                }
            } catch let error {
                debugPrint(error)
                callback(.Failure(DIError.invalidData().message))
            }
        }
    failure: { error in
        DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }

        callback(.Failure(error.message))
    }
    }

    func fetchToken(
        channelName: String,isLoader:Bool = false,parent:DIBaseController? = nil,
        callback: @escaping  CompletionResponse
    ) {
        let urlInfo = EndPoint.StreamToken("")

        if isLoader { parent?.showLoader() }
        DIWebLayer.instance.webManager.post(method: .post, function: urlInfo.url, parameters: [:]) { data in
            // Parse Data Here & convert it into modal
            DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }

            do {
                let modal   = try JSONDecoder().decode(DefaultModal.self, from: data)
                //Look for data is there or not

                let isSuccess = modal.status == 1

                let response:ResponseApi = isSuccess ?  .Success(modal.message) : .Failure(modal.message)

                callback(response)
            } catch let error {
                debugPrint(error)
                callback(.Failure(DIError.invalidData().message))
            }
        }
    failure: { error in
        DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }

        callback(.Failure(error.message))
    }
    }
}
struct StreamModalInfo : Codable {
    let message : String?
    let status : Int?
    let data : StreamModal?

    enum CodingKeys: String, CodingKey {

        case message
        case status
        case data
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        data = try values.decodeIfPresent(StreamModal.self, forKey: .data)
    }

}
struct AllStreamArr : Codable {
    let message : String?
    let status : Int?
    let data : [StreamModal]?

    enum CodingKeys: String, CodingKey {

        case message
        case status
        case data
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        data = try values.decodeIfPresent([StreamModal].self, forKey: .data)
    }

}
struct PaymentStreamModal : Codable {
    let message : String?
    let status : Int?
    let url : String?

    enum CodingKeys: String, CodingKey {

        case message
        case status
        case url
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        url = try values.decodeIfPresent(String.self, forKey: .url)
    }

}
public struct StreamModal : Codable {
    let affiliate_id : String?
    let user_id : String?
    let title : String?
    let affiliate_first_name : String?
    let affiliate_last_name : String?
    let chat_room_id : String?
    let is_deleted : Int?
    let uid : Int?
    var isStreamFree:Int?  // 1 is free for some users, default 0
    let highStreamQuality:Int? // 0 for standard(default and 1 for high definition)
    let isAffiliate :Int?
    let affilaiateProfileImage : String?
    let isVideoCall : Int?
    let isAdmin : Int?
    let isActive : Int?
    let _id : String?
    let token : String?
    let channel_id : String?
    let created_at : String?
    let updated_at : String?
    let __v : Int?
    var isSubscribed:Int?
    var amount:Double?
    var is_paid:Int?
    let joinedUsersLimit:Int?
    enum CodingKeys: String, CodingKey {
        case joinedUsersLimit = "joinedUsersLimit"
        case affiliate_id = "affiliate_id"
        case user_id = "user_id"
        case title = "title"
        case isStreamFree
        case highStreamQuality
        case affiliate_first_name = "affiliate_first_name"
        case affiliate_last_name = "affiliate_last_name"
        case chat_room_id = "chat_room_id"
        case is_deleted = "is_deleted"
        case uid = "uid"
        case affilaiateProfileImage = "AffilaiateProfileImage"
        case isVideoCall = "isVideoCall"
        case isActive = "isActive"
        case _id = "_id"
        case token = "token"
        case isAdmin = "isAdmin"
        case channel_id = "channel_id"
        case created_at = "created_at"
        case updated_at = "updated_at"
        case __v = "__v"
        case isAffiliate = "isAffiliate"
        case isSubscribed = "isSubscribed"
        case amount = "amount"
        case is_paid = "is_paid"

    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        isAffiliate = try values.decodeIfPresent(Int.self, forKey: .isAffiliate)

        isStreamFree = try values.decodeIfPresent(Int.self, forKey: .isStreamFree)

        highStreamQuality = try values.decodeIfPresent(Int.self, forKey: .highStreamQuality)

        isAdmin = try values.decodeIfPresent(Int.self, forKey: .isAdmin)
        isSubscribed = try values.decodeIfPresent(Int.self, forKey: .isSubscribed)
        amount = try values.decodeIfPresent(Double.self, forKey: .amount)
        is_paid = try values.decodeIfPresent(Int.self, forKey: .is_paid)
        joinedUsersLimit =  try values.decodeIfPresent(Int.self, forKey: .joinedUsersLimit)
        affiliate_id = try values.decodeIfPresent(String.self, forKey: .affiliate_id)
        user_id = try values.decodeIfPresent(String.self, forKey: .user_id)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        affiliate_first_name = try values.decodeIfPresent(String.self, forKey: .affiliate_first_name)
        affiliate_last_name = try values.decodeIfPresent(String.self, forKey: .affiliate_last_name)
        chat_room_id = try values.decodeIfPresent(String.self, forKey: .chat_room_id)
        is_deleted = try values.decodeIfPresent(Int.self, forKey: .is_deleted)
        uid = try values.decodeIfPresent(Int.self, forKey: .uid)
        affilaiateProfileImage = try values.decodeIfPresent(String.self, forKey: .affilaiateProfileImage)
        isVideoCall = try values.decodeIfPresent(Int.self, forKey: .isVideoCall)
        isActive = try values.decodeIfPresent(Int.self, forKey: .isActive)
        _id = try values.decodeIfPresent(String.self, forKey: ._id)
        token = try values.decodeIfPresent(String.self, forKey: .token)
        channel_id = try values.decodeIfPresent(String.self, forKey: .channel_id)
        created_at = try values.decodeIfPresent(String.self, forKey: .created_at)
        updated_at = try values.decodeIfPresent(String.self, forKey: .updated_at)
        __v = try values.decodeIfPresent(Int.self, forKey: .__v)
    }

}
