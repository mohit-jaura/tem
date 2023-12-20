//
//  AppSettings.swift
//  TemApp
//
//  Created by debut_mac on 09/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import UIKit

enum EndPoint {
    case ProductSearch( category:String? ,str:String?,_ page:Int)
    case GetStreamInfo(affID:String?)
    case GetAllStreamers
    case PayStreamFees(affID:String?,amount:Double?)
    case AddCart(id:String,isAddedNew:Bool,variantID:String)
    case AddWishList(_ id:String,isWishlist:Bool)
    case CheckCart
    case DeleteCart(id:String)
    case GetCategories
    case ProductDetails(_ id:String)
    case PaymentApi
    case GetDayEvent(_ startDate:String,_ endDate:String)
    case EventsActsGet(_ eventID:String)
    case SkipActivity( eventID:String?, activity:String?)
    case StrEventAct( type:Int?, id:Int?, eventID:String?, eventActId: String?)
    case StreamToken(_ channelName:String)
    case CompEventAct
    case ProgramDetails(_ id:String?)
    case GetCalendarEvents(_ startDate:String,_ endDate:String)
    var url :String {
        switch self {
        case .GetCalendarEvents(_,_):
            return "events/listByMonth"
        case .ProgramDetails(let id):
            return "program/\(id ?? "")"
        case .GetAllStreamers:
            return "streaming/getLiveStreamers"
        case .PayStreamFees(_,_):
            return "streaming/payToAccessLive"
        case .GetStreamInfo(affID: let affID):
            return "streaming/live_channel?affiliate_id=\(affID ?? "")"
        case .StreamToken(_ ):
            return "streaming"
        case .SkipActivity(eventID: _, activity: _):
            return "events/skipactivity"
        case .StrEventAct:
            return "users/activity/startEventActivity"
        case .CompEventAct:
            return "/users/activity/completeEventActivity"
        case .EventsActsGet(_):
            return "events/activitylist"
        case .GetDayEvent(_,_):
            return "events/weekbylist" //"events/datebylist"
        case .PaymentApi:
            return "retail/checkout"
        case .ProductDetails(let id):
            return "retail/product/\(id)"
        case .GetCategories:
            return "retail/categorylist"
        case .DeleteCart(id:let id):
            return "retail/removecart?cart_id=\(id)"
        case .CheckCart:
            return "retail/get_cart_data"
        case .AddWishList(_, _):
            return "retail/wishlist"
        case .AddCart(_):
            return "retail/addcart"
        case .ProductSearch(let category, let str,let page):
            return "retail/product?filterBy=\(category ?? "")&searchBy=\(str ?? "")&skip=\(page)"
        }
    }
    var params:Parameters {
        switch self {
        case .GetCalendarEvents(let startDate, let endDate):
            return ["startDate":startDate,"endDate":endDate]
        case .PayStreamFees(affID: let affId, amount:let amt):
            return ["amount":amt ?? 0,"affiliateId":affId ?? ""]
        case .StreamToken(let channelName):
            return [:]
        case .StrEventAct(type:let type, id: let id, eventID: let eventId, eventActId: let eventActId):
            return [ "activityTarget": "",
                     "activityType": type ?? 0,
                     "activityId": id ?? 0,
                     "isScheduled": 0,
                     "event_id":eventId ?? "",
                     "eventactivityid":eventActId ?? ""]
        case .EventsActsGet(let eventID):
            return ["eventId":eventID]
        case .SkipActivity(eventID: let eventID, activity: let activityID):
            return ["event_id":eventID ?? "" ,"eventactivityid":activityID ?? ""]
        case .GetDayEvent(let startDate, let endDate):
            return ["startDate":startDate,"endDate":endDate]
        case .AddWishList(let id, isWishlist: let isWishlist):
            return ["id":id,"type":isWishlist]
            
        case .AddCart(id:let id, isAddedNew:let isAddedNew, variantID: let variantID):
            return ["type":isAddedNew ? 1 : 0,"product_id":id,"variant_id": variantID]
        default :
            return [:]
            
        }
    }
}


struct StoryBoards {
    static var Shop = UIStoryboard(name: "Shopping", bundle: nil)
    static var ManageCards = UIStoryboard(name: "Managecards", bundle: nil)
    static var Calendar = UIStoryboard(name: "Calendar", bundle: nil)
    static var Activity = UIStoryboard(name: "Activity", bundle: nil)
    static var Chat = UIStoryboard(name: "Chat", bundle: nil)
    
    static var Stream = UIStoryboard(name: "LiveStreaming", bundle: nil)
    
}

enum VCname :String {
    case ActivityAddOnListVC
    case ProductsVC
    case CalendarVC
    case VideoChatViewController
    case PopUpStreamVC
    case StreamAudienceVC
    case ResumeStopController
    case OrderListVC
    case EventsActAddOnsVC
    case ProductListingViewController
    case CartManagementViewController
    case RetailSettingsViewController
    case PopVariantsVC
    case EventDayVC
    case CreateActivityAdOnsVC
    case AddTimePickerVC
    case LiveSessionChatVC
    var title:String {
        switch self {
        case .CalendarVC: return "CalendarVC"
        case .PopUpStreamVC:return "PopUpStreamVC"
        case .VideoChatViewController:
            return "VideoChatViewController"
        case .LiveSessionChatVC:
            return "LiveSessionChatVC"
        case .StreamAudienceVC:
            return "StreamAudienceVC"
        case .ResumeStopController:
            return "ResumeStopController"
        case .EventsActAddOnsVC:
            return "EventsActAddOnsVC"
        case .AddTimePickerVC:
            return "AddTimePickerVC"
        case .CreateActivityAdOnsVC:
            return "CreateActivityAdOnsVC"
        case .ActivityAddOnListVC:
            return "ActivityAddOnListVC"
        case .EventDayVC:
            return "EventDayVC"
        case .PopVariantsVC:
            return "PopVariantsVC"
        case .CartManagementViewController:
            return "CartManagementViewController"
        case .ProductListingViewController:return "ProductListingViewController"
        case .OrderListVC:return "OrderListVC"
        case .ProductsVC:return "ProductsVC"
        case .RetailSettingsViewController: return "RetailSettingsViewController"
            
        }
    }
}
func loadVC(_ name:VCname) -> UIViewController? {
    
    let shopSB = StoryBoards.Shop
    let calendarSB = StoryBoards.Calendar
    let activitySB = StoryBoards.Activity
    let chatSB = StoryBoards.Chat
    let streamSB = StoryBoards.Stream
    
    switch name {
    case .CalendarVC:
        return calendarSB.instantiateViewController(withIdentifier: name.rawValue) as! CalendarVC
    case .PopUpStreamVC:return PopUpStreamVC()
    case .VideoChatViewController:
        return streamSB.instantiateViewController(withIdentifier: name.rawValue) as! VideoChatViewController
    case .LiveSessionChatVC:
        return chatSB.instantiateViewController(withIdentifier: name.rawValue) as! LiveSessionChatVC
    case .StreamAudienceVC:
        return StreamAudienceVC()
    case .ResumeStopController:
        return activitySB.instantiateViewController(withIdentifier: name.rawValue) as! ResumeStopController
    case .EventsActAddOnsVC:
        return activitySB.instantiateViewController(withIdentifier: name.rawValue) as! EventsActAddOnsVC
    case .AddTimePickerVC:
        return AddTimePickerVC()
    case .CreateActivityAdOnsVC:
        return activitySB.instantiateViewController(withIdentifier: name.rawValue) as! CreateActivityAdOnsVC
    case .ActivityAddOnListVC:
        return activitySB.instantiateViewController(withIdentifier: name.rawValue) as! ActivityAddOnListVC
    case .EventDayVC:
        return calendarSB.instantiateViewController(withIdentifier: name.rawValue) as! EventDayVC
    case .PopVariantsVC:
        return PopVariantsVC()
    case .CartManagementViewController:
        return shopSB.instantiateViewController(withIdentifier: name.rawValue) as! CartManagementViewController
    case .ProductListingViewController:
        return shopSB.instantiateViewController(withIdentifier: name.rawValue) as! ProductListingViewController
    case .OrderListVC:
        return shopSB.instantiateViewController(withIdentifier: name.rawValue) as! OrderListVC
        
    case .ProductsVC:
        return shopSB.instantiateViewController(withIdentifier: name.rawValue) as! ProductsVC
        
    case .RetailSettingsViewController:
        return StoryBoards.ManageCards.instantiateViewController(withIdentifier: name.rawValue) as! RetailSettingsViewController
        
    }
}
