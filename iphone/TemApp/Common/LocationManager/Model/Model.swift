//
//  Address.swift
//
//  Created by Aj Mehra on 18/06/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import Foundation
import CoreLocation
import GooglePlaces

class Address: NSObject, NSCoding, Codable {
    
    var city: String?
    var state: String?
    var country: String?
    var pinCode: String?
    var lat: Double?
    var lng: Double?
    var formatted: String?
    var place_id:String?
    var name:String?
    var location:[Double]?
    var gymType: GymLocationType?
    var hasGymType: CustomBool?
    
    enum CodingKeys: String, CodingKey {
        case city
        case state
        case country
        case formatted = "address"
        case lat
        case lng
        case name
        case location
        case place_id
        case gymType = "type"
        case hasGymType = "gym_type_mandatory"
    }
    
    var json: JSON {
        var json = JSON()
        if let city = self.city {
            json[JSONMappingKeys.city] = city
        }
        if let state = self.state {
            json[JSONMappingKeys.state] = state
        }
        if let country = self.country {
            json[JSONMappingKeys.country] = country
        }
        if let pincode = self.pinCode {
            json[JSONMappingKeys.pincode] = pincode
        }
        if let lat = self.lat {
            json[JSONMappingKeys.lat] = lat
        }
        if let long = self.lng {
            json[JSONMappingKeys.lng] = long
        }
        if let placeId = self.place_id {
            json[JSONMappingKeys.placeId] = placeId
        }
        if let name = self.name {
            json[JSONMappingKeys.name] = name
        }
        if let location = self.location {
            json[JSONMappingKeys.location] = location
        }
        return json
    }
    
    private struct JSONMappingKeys {
        static let city = "city"
        static let state = "state"
        static let country = "country"
        static let pincode = "pincode"
        static let lat = "lat"
        static let lng = "lng"
        static let placeId = "place_id"
        static let name = "name"
        static let location = "location"
    }
    
    init (gymLocationObj: Parameters) {
        if let geom = gymLocationObj["geometry"] as? Parameters {
            if let locatotionObj = geom["location"] as? Parameters {
                self.lat = locatotionObj["lat"] as? Double
                self.lng = locatotionObj["lng"] as? Double
            }
        }else{
            self.lat = gymLocationObj["lat"] as? Double
            self.lng = gymLocationObj["lng"] as? Double
        }
        self.formatted = gymLocationObj["formatted_address"] as? String ?? (gymLocationObj["address"] as? String ?? "")
        self.place_id = gymLocationObj["place_id"] as? String ?? ""
        self.name = gymLocationObj["name"] as? String ?? ""
    }
    
    init(placemark: CLPlacemark) {
        city = placemark.locality
        state = placemark.administrativeArea
        country = placemark.country
        pinCode = placemark.addressDictionary?["ZIP"] as? String
        lat = placemark.location?.coordinate.latitude
        lng = placemark.location?.coordinate.longitude
        if let addrList = placemark.addressDictionary?["FormattedAddressLines"] as? [String] {
            formatted = addrList.joined(separator: ", ")
        }
    }
    
    init(gmsPlace: GMSPlace) {
        lat = gmsPlace.coordinate.latitude
        lng = gmsPlace.coordinate.longitude
        city = gmsPlace.name
        formatted = gmsPlace.formattedAddress
        place_id = gmsPlace.placeID
        
        if formatted != nil{
            let formattedArray = formatted?.components(separatedBy: ",")
            let count =  formattedArray!.count
            if (count > 1){
                let state = formattedArray![count - 2]
                if(state != city){ // check is 2nd last value from array is not city
                    self.state = state
                }
            }
            country = formattedArray?.last
        }
    }
    
    init(location:CLLocation) {
        lat = location.coordinate.latitude
        lng = location.coordinate.longitude
        formatted = "Current Location"
    }
    
    convenience init(json:JSON) {
        self.init()
        country = json[JSONMappingKeys.country] as? String
        state = json[JSONMappingKeys.state] as? String
        city = json[JSONMappingKeys.city] as? String
        name = json[JSONMappingKeys.name] as? String
        place_id = json[JSONMappingKeys.placeId] as? String
        if let locatotionObj = json[JSONMappingKeys.location] as? [Double] {
            if locatotionObj.count >= 2 {
            self.lng = locatotionObj[0]
            self.lat = locatotionObj[1]
            }
        }
        formatted = self.formatAddress()
    }
    
    
    
    func formatAddress() -> String? {
        if let city = self.city, let country = self.country , city != "" , country != "" {
            return city + ", " + country
        }else if let city = self.city ,city != "" {
            if let country = self.country , country != "" {
                return city + ", " + country
            }else {
                return city
            }
        }else if let country = self.country , country != "" {
            return country
        }
        return ""
    }
    
    override init() {
    }
    
    // MARK: NSCoding
    // Custom encoding and decoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(city, forKey: CodingKeys.city.rawValue)
        aCoder.encode(lat, forKey: CodingKeys.lat.rawValue)
        aCoder.encode(formatted, forKey: CodingKeys.formatted.rawValue)
        aCoder.encode(lng, forKey: CodingKeys.lng.rawValue)
        aCoder.encode(place_id, forKey: CodingKeys.place_id.rawValue)
        aCoder.encode(state, forKey: CodingKeys.state.rawValue)
        aCoder.encode(name, forKey: CodingKeys.name.rawValue)
        aCoder.encode(location, forKey: CodingKeys.location.rawValue)
        aCoder.encode(gymType?.rawValue, forKey: CodingKeys.gymType.rawValue)
        aCoder.encode(hasGymType?.rawValue, forKey: CodingKeys.hasGymType.rawValue)
    }
    required init?(coder aDecoder: NSCoder) {
        city = aDecoder.decodeObject(forKey: CodingKeys.city.rawValue) as? String
        lat = aDecoder.decodeObject(forKey: CodingKeys.lat.rawValue) as? Double
        lng = aDecoder.decodeObject(forKey: CodingKeys.lng.rawValue) as? Double
        formatted = aDecoder.decodeObject(forKey: CodingKeys.formatted.rawValue) as? String
        place_id = aDecoder.decodeObject(forKey: CodingKeys.place_id.rawValue) as? String
        state = aDecoder.decodeObject(forKey: CodingKeys.state.rawValue) as? String
        name = aDecoder.decodeObject(forKey: CodingKeys.name.rawValue) as? String
        location = aDecoder.decodeObject(forKey: CodingKeys.location.rawValue) as? [Double]
        self.gymType = GymLocationType(rawValue: aDecoder.decodeObject(forKey: CodingKeys.gymType.rawValue) as? Int ?? 0)
        hasGymType = CustomBool(rawValue: aDecoder.decodeObject(forKey: CodingKeys.hasGymType.rawValue) as? Int ?? 0)
    }
}
