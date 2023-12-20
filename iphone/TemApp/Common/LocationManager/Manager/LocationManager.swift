//
//  LocationManager.swift
//  Omakase
//
//  Created by Harpreet on 03/10/17.
//  Copyright © 2017 Capovela LLC. All rights reserved.
//

import Foundation
import CoreLocation
import GooglePlaces

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
  
    let locationManager = CLLocationManager()
    
    /// This is the clouser that will return the current Address through google login in
    var success: (_ addrees: Address,_ timeStamp:Date) -> Void = { _,_  in }
    
    /// This clouser will return the error
    var failure: (_ error: DIError) -> () = { _ in }
    
    
    // MARK: - Permission Checks
    private var isEnabled: Bool {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse: return true
        default: return false
        }
    }
    
    private var notDetermined: Bool {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined: return true
        default: return false
        }
    }
    
    func start() -> Void {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if isEnabled {
            locationManager.startUpdatingLocation()
        } else if notDetermined {
            request()
        } else {
            failure(DIError.locationPermissionDenied())
        }
    }
    
    func request() -> Void {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func setUpGeofenceForTracking(_ location :CLLocationCoordinate2D) {
        let geofenceRegionCenter = CLLocationCoordinate2DMake(location.latitude, location.longitude) 
        let geofenceRegion = CLCircularRegion(center: geofenceRegionCenter, radius: 10, identifier: "PlayaGrande") 
        geofenceRegion.notifyOnExit = true 
        geofenceRegion.notifyOnEntry = true 
        self.locationManager.startMonitoring(for: geofenceRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Welcome to Playa Grande! If the waves are good, you can try surfing!")
        guard let _ = manager.location else {return}
        //Good place to schedule a local notification
        print(region)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Bye! Hope you had a great day at the beach!")
        //Good place to schedule a local notification
    }
    
    // MARK: Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation: CLLocation = manager.location {
            getAddressFromLocation(location: currentLocation,timeStamp:(locations.last?.timestamp)!)
        } else {
            self.failure(DIError.locationPermissionDenied())
        }
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        failure(DIError.unKnowError())
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            // If status has not yet been determied, ask for authorization
            request()
        case .authorizedWhenInUse:
            // If authorized when in use
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.startUpdatingLocation()
        case .authorizedAlways:
            // If always authorized
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.startUpdatingLocation()
        case .restricted: failure(DIError.locationPermissionDenied())
            // If restricted by e.g. parental controls. User can't enable Location Services
        case .denied:
            failure(DIError.locationPermissionDenied())
            // If user denied your app access to Location Services, but can grant access from Settings.app
        @unknown default:
            break
        }
    }
    
    private func getAddressFromLocation(location: CLLocation,timeStamp:Date) {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            if error != nil {
                self.success(Address(location: location), timeStamp)
                return
            }
            if let placemark = placemarks?.first {
                self.success(Address(placemark: placemark),timeStamp)
            } else {
                self.success(Address(location: location), timeStamp)
            }
        })
        
    }
    
}

