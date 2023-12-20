//
//  AddressManager.swift
//  TemApp
//
//  Created by Mohit Soni on 16/06/22.
//  Copyright © 2022 Capovela LLC. All rights reserved.
//
import Contacts
import CoreLocation
import Foundation
import GooglePlaces
import MapKit

struct OrderLocation{
    var id:String?
    var name:String?
    var street:String?
    var apartment:String?
    var city:String?
    var state:String?
    var country:String?
    var pinCode:String?
    var lat:Double?
    var long:Double?
    var formattedAdress:String?
    
    func newAddressParameters() -> Parameters{
        let dict:Parameters = [
            "Apartment": apartment ?? "",
            "name" : name ?? "",
            "Street": street ?? "",
            "State": state ?? "",
            "City": city ?? "",
            "Country": country ?? "",
            "Pin_code" : pinCode ?? "",
            "lat" : lat ?? 0,
            "long" : long ?? 0
        ]
        return dict
    }
    
    func updateAddressParameters() -> Parameters{
        let dict:Parameters = [
            "addressid": id ?? "",
            "name" : name ?? "",
            "Apartment": apartment ?? "",
            "Street": street ?? "",
            "State": state ?? "",
            "City": city ?? "",
            "Country": country ?? "",
            "Pin_code" : pinCode ?? "",
            "lat" : lat ?? 0,
            "long" : long ?? 0
        ]
        return dict
    }
}

struct SavedAddresses:Codable{
    var id:String?
    var name:String?
    var apartment:String?
    var city:String?
    var country:String?
    var pinCode:String?
    var state:String?
    var street:String?
    var lat:Double?
    var long:Double?
    
    var formattedAdress:String?{
        let formattedAddress = "\(apartment?.firstCapitalized ?? ""), \(street?.firstCapitalized ?? ""), \(city?.firstCapitalized ?? ""), \(state?.firstCapitalized ?? ""), \(pinCode ?? ""), \(country?.firstCapitalized ?? "")"
        return formattedAddress
    } // used to format the address to display as full address
    
    enum CodingKeys:String,CodingKey{
        case id = "_id"
        case apartment = "Apartment"
        case city = "City"
        case country = "Country"
        case pinCode = "Pin_code"
        case state = "State"
        case street = "Street"
        case lat = "lat"
        case long = "long"
        case name = "name"
    }
}

class AddressManager{
    
    var locationSaved:OrderLocation = OrderLocation()
    lazy var addressWebLayer:DIWebLayerOrderAddressAPI = DIWebLayerOrderAddressAPI()
    
    func updateLocationOnMap(to coordinate: CLLocationCoordinate2D,mapView:MKMapView) {
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let viewRegion = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(viewRegion, animated: true)
    }
    
    func setOrderLocation(placeMark:CLPlacemark){
        self.locationSaved.city = placeMark.locality
        self.locationSaved.street = placeMark.name
        self.locationSaved.apartment = placeMark.thoroughfare
        self.locationSaved.state = placeMark.administrativeArea
        self.locationSaved.country = placeMark.country
        self.locationSaved.pinCode = placeMark.postalCode
        if self.locationSaved.formattedAdress == nil{
            let formattedAddress = "\(placeMark.name ?? ""), \(placeMark.locality ?? ""), \(placeMark.administrativeArea ?? ""), \(placeMark.postalCode ?? ""), \(placeMark.country ?? "")"
            self.locationSaved.formattedAdress = formattedAddress
        }
        if self.locationSaved.long == nil{
            self.locationSaved.long = placeMark.location?.coordinate.longitude
            self.locationSaved.lat = placeMark.location?.coordinate.latitude
        }
    }
    
    func addPlacemarkTextField(_ userLocation:CLLocation,mapView:MKMapView? = nil,completion:@escaping(_ address:OrderLocation) -> Void){
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            if (error != nil){
                print("error in reverseGeocode")
                return
            }
            let placemarks = placemarks! as [CLPlacemark]
            if placemarks.count>0{
                let placemark = placemarks[0]
                if let location = placemark.location,let map = mapView{
                    self.updateLocationOnMap(to: location.coordinate,mapView: map)
                }
                self.setOrderLocation(placeMark: placemark)
            }
            completion(self.locationSaved)
        }
    }
    
    func getAllAddresses(success:@escaping(_ addresses:[SavedAddresses]) ->  Void,failure:@escaping(_ error:DIError) ->  Void){
        addressWebLayer.getAllAddresses { addresses in
            success(addresses)
        } failure: { error in
            failure(error)
        }
    }
    
    func addNewAddress(address:OrderLocation,completion:@escaping(_ message:String) -> Void){
        addressWebLayer.addNewAddress(parameters: address.newAddressParameters()) { message in
            completion(message)
        }
    }
    
    func updateAddress(address:OrderLocation,completion:@escaping(_ message:String) -> Void){
        addressWebLayer.updateAddress(parameters: address.updateAddressParameters()) { message in
            completion(message)
        }
    }
}
