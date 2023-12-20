//
//  DIWebLayerEvent.swift
//  TemApp
//
//  Created by dhiraj on 16/07/19.
//  Copyright © 2019 Capovela LLC. All rights reserved.
//

import Foundation
class DIWebLayerEvent: DIWebLayer {
    
    var deletionMsg: StringCompletion?

    func getCalendarEvents(endPoint:String,params:Parameters?,parent:DIBaseController? = nil,  isLoader:Bool = true, completion: @escaping CompletionDataApi){
        if isLoader { parent?.showLoader() }

        self.webManager.post(method: .post, function: endPoint, parameters: params) { data in
            // Parse Data Here & convert it into modal
            DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }

             //Check Error Once
            do {
                let modal   = try JSONDecoder().decode(CalendarEventsModal.self, from: data)
                //Look for data is there or not
                let isDataFound = modal.data?.count ?? 0 != 0

                //Look for backend status 1 or 0

                let isSuccess = modal.status == 1

                let response:ResponseData = isSuccess ?  (isDataFound ?  .Success(modal.data,modal.message) : .NoDataFound ) :   .Failure(modal.message)
                AnalyticsManager.logEventWith(event: Constant.EventName.apiName,parameter: ["isDataFound": isDataFound,
                                                                                            "responseMsg": modal.message ?? ""])
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
    func getEventList(parameter:Parameters, success: @escaping (_ eventList:[EventDetail]?) -> Void, failure: @escaping (_ error: DIError?) -> Void ) {
        call(method: .post, function: Constant.SubDomain.event+"/"+Constant.SubDomain.listByDate, parameters: parameter, success: { [weak self] (response) in
            DispatchQueue.main.async {
                if let params = response["data"] as? [Parameters] {
                    self?.decodeFrom(data: params, success: { (eventList) in
                        success(eventList)
                    }, failure: { (error) in
                        failure(error)
                    })
                }
                else {
                    failure(DIError.unKnowError())
                }
            }
        }) { (error) in
            failure(error)
        }
    }
    func getDayEvent(parameter:Parameters,endPoint:String,parent:DIBaseController? = nil,  isLoader:Bool = true, completion: @escaping CompletionDataApi){
        startLoading(isLoader,parent)
        
        self.webManager.post(method: .post, function: endPoint, parameters: parameter) {[weak self] data in
            // Parse Data Here & convert it into modal
            self?.hideLoading(isLoader,parent)
            
            //Check Error Once
            do {
                let allData = try JSONDecoder().decode(DayEventModal.self, from: data)
                
                let isDataFound = allData.data?.count ?? 0 != 0
                
                //Look for backend status 1 or 0
                
                let isSuccess = allData.status == 1
                
                let response:ResponseData = isSuccess ?  (isDataFound ?  .Success(allData.data,allData.message) : .NoDataFound ) :   .Failure(allData.message)
                
                completion(response)
            }
            
            catch let error {
                debugPrint(error)
                completion(.Failure(DIError.invalidData().message))
            }
        }
    failure: { error in
        self.hideLoading(isLoader,parent)
        completion(.Failure(error.message))
    }
    }

    func programDetails(endPoint:String,parent:DIBaseController? = nil,  isLoader:Bool = true, completion: @escaping CompletionDataApi){
        startLoading(isLoader,parent)

        self.webManager.post(method: .get, function: endPoint, parameters: nil) {[weak self] data in
            // Parse Data Here & convert it into modal
            self?.hideLoading(isLoader,parent)

             //Check Error Once
            do {
                let allData = try JSONDecoder().decode(ProgramAllDataModal.self, from: data)

                let isDataFound = allData.data?.programs?.count ?? 0 != 0

                        //Look for backend status 1 or 0

                let isSuccess = allData.status == 1

                let response:ResponseData = isSuccess ?  (isDataFound ?  .Success(allData.data,allData.message) : .NoDataFound ) :   .Failure(allData.message)

                        completion(response)
                        }

            catch let error {
                debugPrint(error)
                completion(.Failure(DIError.invalidData().message))
            }
            }
         failure: { error in
             self.hideLoading(isLoader,parent)
             completion(.Failure(error.message))
        }
    }

    func createEvent(parameter:Parameters, success: @escaping (_ detail:EventDetail?) -> Void, failure: @escaping (_ error: DIError?) -> Void ) {
        call(method: .post, function: Constant.SubDomain.event, parameters: parameter, success: { (response) in
            if let data = response["data"] as? Parameters{
                self.decodeFrom(data: data, success: { (eventDetail) in
                    success(eventDetail)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }

    func updateEvent(parameter:Parameters, success: @escaping (_ detail:EventDetail?) -> Void, failure: @escaping (_ error: DIError?) -> Void) {
        call(method:.post,function: Constant.SubDomain.event+"/"+Constant.SubDomain.update, parameters: parameter, success: { (response) in
            if let data = response["data"] as? Parameters{
                self.decodeFrom(data: data, success: { (eventDetail) in
                    success(eventDetail)
                }, failure: { (error) in
                    failure(error)
                })
            }else if (response["data"] as? String) == nil {
               success(nil)
            } else {
                 failure(DIError.invalidJSON())
            }
        }) { (error) in
            failure(error)
        }
    }

    func getEventDetail(parameter:Parameters?,id:String, success: @escaping (_ detail:EventDetail?) -> Void, failure: @escaping (_ error: DIError?) -> Void ) {
        call(method:.get,function: Constant.SubDomain.event+"/"+id, parameters: parameter, success: { (response) in
            if let data = response["data"] as? Parameters{
                self.decodeFrom(data: data, success: { (eventDetail) in
                    success(eventDetail)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    

    
    func getEventsActivities(endPoint:String,parent:DIBaseController? = nil,  isLoader:Bool = true,  params:Parameters? = nil, completion: @escaping CompletionWithData){
        
        if isLoader { parent?.showLoader() }

        self.webManager.post(method: .post, function: endPoint, parameters: params) { data in
            // Parse Data Here & convert it into modal
            DispatchQueue.main.async {  if isLoader { parent?.hideLoader()} }

             //Check Error Once
            do {
                let modal   = try JSONDecoder().decode(EventActivitiesDataModal.self, from: data)
                
                let isDataFound:ResponseIn =  modal.data?.count ?? 0 > 0 ? .DataFound : .NoDataFound

                if modal.status == 1 {
                    completion(isDataFound,modal.data,Constant.ErrorMsg.noDataFound)

                } else {
                    completion(isDataFound,modal.data,modal.message)
                }
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
    func getMemberList(parameter:Parameters?,id:String, success: @escaping (_ memberList:[Members]?) -> Void, failure: @escaping (_ error: DIError?) -> Void ) {
        call(method: .post, function: Constant.SubDomain.event+"/"+id+"/"+Constant.SubDomain.members, parameters: parameter, success: { (response) in
            if let data = response["data"] as? [Parameters] {
                do {
                    //get data from object
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                    let memberList = try JSONDecoder().decode([Members].self, from: jsonData)
                    success(memberList)
                } catch (let error) {
                    DILog.print(items: error.localizedDescription)
                    failure(DIError.init(error: error))
                }
            }else{

            }
        }) { (error) in
            failure(error)
        }
    }

    func deleteEvent(parameter:Parameters?,id:String, success: @escaping (_ message:String?) -> Void, failure: @escaping (_ error: DIError?) -> Void ) {
        call(method:.delete,function: Constant.SubDomain.event+"/"+id, parameters: parameter, success: { (response) in
            if let message = response["message"] as? String {
              success(message)
            }
        }) { (error) in
            failure(error)
        }
    }

    func joinEvent(parameter:Parameters?,success: @escaping (_ data: String?) -> Void, failure: @escaping (_ error: DIError?) -> Void ) {
        call(method: .post, function: Constant.SubDomain.event+"/"+Constant.SubDomain.join, parameters: parameter, success: { (response) in
            success(response["data"] as? String)
        }) { (error) in
            failure(error)
        }
    }
    
    func removeEvent(eventId:String,success: @escaping (_ data: String?) -> Void, failure: @escaping (_ error: DIError?) -> Void ) {
        var params:Parameters = ["eventid":eventId]
        self.call(method: .post, function: Constant.SubDomain.removeEvent, parameters: params, success: { (response) in
            success(response["data"] as? String)
        }) { (error) in
            failure(error)
        }
    }

    func startProgramEvent(parameter:Parameters?,success: @escaping (_ data: String?) -> Void, failure: @escaping (_ error: DIError?) -> Void ) {
    call(method: .post, function: Constant.SubDomain.startProgramEvent, parameters: parameter, success: { (response) in
        success(response["data"] as? String)
    }) { (error) in
        failure(error)
    }
}

    /// this api call will return if an event exists for a date time
    func checkIfEventExistsForADate(params: Parameters, success: @escaping(_ exists: Bool) -> Void, failure: @escaping(_ error: DIError?) -> Void) {
        let endpoint = Constant.SubDomain.event + "/eventCount"
        call(method: .post, function: endpoint, parameters: params, success: { (response) in
            if let data = response["data"] as? Int,
                data > 0 {
                //events exists
                success(true)
            } else {
                success(false)
            }
        }) { (error) in
            failure(error)
        }
    }

    func getweeklyDays(success: @escaping (_ eventList: [WeekDays]) -> Void, failure: @escaping (_ error: DIError?) -> Void ) {
        call(method: .post, function: Constant.SubDomain.event+"/"+Constant.SubDomain.getWeeklyDays, parameters: nil, success: { (response) in
           
            if let params = response["data"] as? [Parameters] {
                self.decodeFrom(data: params, success: { (eventList) in
                    success(eventList)
                }, failure: { (error) in
                    failure(error)
                })
            } else {
                failure(DIError.unKnowError())
            }

        }) { (error) in
            failure(error)
        }
    }

    func deleteRound(roundId: String, eventId: String, completion: @escaping (_ message:String?) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        let params: [String: Any] = ["event_id": eventId,"round_id": roundId]
        self.call(method: .post, function: Constant.SubDomain.deleteRound, parameters: params, success: { (response) in
            if let message = response["message"] as? String {
              completion(message)
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func deleteTask(roundId: String, eventId: String,taskID: String, completion: @escaping (_ message:String?) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        let params: [String: Any] = ["eventid": eventId,"round_id": roundId, "task_id": taskID]
        self.call(method: .post, function: Constant.SubDomain.deleteTask, parameters: params, success: { (response) in
            
            if let message = response["message"] as? String {
              completion(message)
            }
        }) { (error) in
            failure(error)
        }
    }
//events/event-payment
    func getPaymentLink(affiliateId: String, eventId: String,amount: Int, completion: @escaping (_ message:String?) -> Void, failure: @escaping (_ error: DIError) -> Void) {
        let params: [String: Any] = ["eventId": eventId,"affiliateId": affiliateId, "amount": amount]
        self.call(method: .post, function: Constant.SubDomain.getPaymentLink, parameters: params, success: { (response) in
            
            if let message = response["url"] as? String {
              completion(message)
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func getEventChecklist(eventId:String, completion: @escaping (_ checklist:[Checklist]) -> Void, failure: @escaping (_ error: DIError) -> Void){
        let subDomain = Constant.SubDomain.getEventChecklist + eventId
        self.call(method: .get, function: subDomain, parameters: nil) { response in
            print(response)
            if let data = response["data"] as? [Parameters] {
                self.decodeFrom(data: data, success: { (checklist) in
                    completion(checklist)
                }, failure: { (error) in
                    failure(error)
                })
            } else {
                failure(DIError.unKnowError())
            }
        } failure: { error in
            print(error)
        }
    }
    
    
    func updateTaskCheck(parameters:Parameters,completion: @escaping(_ error: DIError?) -> Void){
        let subDomain = Constant.SubDomain.updateTaskCheck
        self.call(method: .post, function: subDomain, parameters: parameters) { response in
            print(response)
            completion(nil)
        } failure: { error in
            completion(error)
        }

    }
    
}
struct DayEventModal:Decodable{
    let message : String?
    let status : Int?
    let data : [EventsDataByDate]?

    enum CodingKeys: String, CodingKey {

            case message = "message"
            case status = "status"
            case data = "data"
    }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            message = try values.decodeIfPresent(String.self, forKey: .message)
            status = try values.decodeIfPresent(Int.self, forKey: .status)
            data = try values.decodeIfPresent([EventsDataByDate].self, forKey: .data)
        }

    }
struct EventsDataByDate : Decodable {
    let date : String?
    let compareDate:String?
    let eventdata : [EventDetail]?

    enum CodingKeys: String, CodingKey {

        case date = "date"
        case eventdata = "eventdata"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        date = try values.decodeIfPresent(String.self, forKey: .date)
        eventdata = try values.decodeIfPresent([EventDetail].self, forKey: .eventdata)
        compareDate = date
    }

}


struct WeekDays: Decodable{
    var date: String?
  //  var value: NSNumber?
    
    enum CodingKeys: String, CodingKey {
        case date =  "startDate"
     //   case value
    }
}
