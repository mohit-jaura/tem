//
//  DIWeblayerTemTvAPI.swift
//  TemApp
//
//  Created by Shiwani Sharma on 18/01/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//

import Foundation
import UIKit

//posts/episodedlist/61dd5700b87c9e12c8977b0d

class DIWeblayerTemTvAPI: DIWebLayer{
    
    func getSeriesData(success: @escaping (_ response: [TvSeries]) -> (), failure: @escaping (_ error: DIError) -> ()) {
        let url = "posts/allserieslist"
        self.call(method: .get, function: url, parameters: nil, success: { (response) in
            if let data = response["data"] as? [Parameters] {
                //get data from object
                self.decodeFrom(data: data, success: { (groups) in
                    success(groups)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    
    func getEpisodesData(seriesId: String, success: @escaping (_ response: [Episodes]) -> (), failure: @escaping (_ error: DIError) -> ()) {
        let url = "posts/episodedlist/?id=\(seriesId)"
        self.call(method: .get, function: url, parameters: nil, success: { (response) in
            if let data = response["data"] as? [Parameters] {
                //get data from object
                self.decodeFrom(data: data, success: { (groups) in
                    success(groups)
                }, failure: { (error) in
                    failure(error)
                })
            }
        }) { (error) in
            failure(error)
        }
    }
}
