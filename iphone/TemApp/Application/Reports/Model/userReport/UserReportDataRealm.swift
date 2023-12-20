//
//    UserReportDataRealm.swift
//    Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation
import RealmSwift




class UserReportDataRealm: Object {
    
    @Persisted var graph: List<UserReportGraphRealm>
    @Persisted var totalActivityReport: TotalActivityReport!
    @Persisted var otherGraph: List<UserReportGraphRealm>
    override init() {
        super.init()
    }
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    class func fromDictionary(dictionary: [String:Any]) -> UserReportDataRealm    {
        let this = UserReportDataRealm()

        if let graphArray = dictionary["graph"] as? [[String:Any]]{
            var graphItems = List<UserReportGraphRealm>()
            for dic in graphArray{
                let value = UserReportGraphRealm.fromDictionary(dictionary: dic)
                graphItems.append(value)
            }
            this.graph = graphItems
        }

        if let graphArray = dictionary["otherGraph"] as? [[String:Any]]{
            var graphItems = List<UserReportGraphRealm>()
            for dic in graphArray{
                let value = UserReportGraphRealm.fromDictionary(dictionary: dic)
                graphItems.append(value)
            }
            this.otherGraph = graphItems
        }

        if let totalActivityReportData = dictionary["totalActivityReport"] as? [String:Any]{
            this.totalActivityReport = TotalActivityReport.fromDictionary(dictionary: totalActivityReportData)
        }
        return this
    }

    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()

        if graph != nil{
            var dictionaryElements = [[String:Any]]()
            for i in 0 ..< graph.count {
                if let graphElement = graph[i] as? UserReportGraphRealm{
                    dictionaryElements.append(graphElement.toDictionary())
                }
            }
            dictionary["graph"] = dictionaryElements
        }
        if otherGraph != nil{
            var dictionaryElements = [[String:Any]]()
            for i in 0 ..< otherGraph.count {
                if let graphElement = otherGraph[i] as? UserReportGraphRealm{
                    dictionaryElements.append(graphElement.toDictionary())
                }
            }
            dictionary["otherGraph"] = dictionaryElements
        }

        if totalActivityReport != nil{
            dictionary["totalActivityReport"] = totalActivityReport.toDictionary()
        }
        return dictionary
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
    {
        if let data = aDecoder.decodeObject(forKey: "graph") as? List<UserReportGraphRealm> {
            graph = data
        }
        if let data = aDecoder.decodeObject(forKey: "otherGraph") as? List<UserReportGraphRealm> {
            otherGraph = data
        }
         totalActivityReport = aDecoder.decodeObject(forKey: "totalActivityReport") as? TotalActivityReport

    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    func encode(with aCoder: NSCoder)
    {
        if graph != nil{
            aCoder.encode(graph, forKey: "graph")
        }
        if otherGraph != nil{
            aCoder.encode(otherGraph, forKey: "otherGraph")
        }
        if totalActivityReport != nil{
            aCoder.encode(totalActivityReport, forKey: "totalActivityReport")
        }
    }

}
