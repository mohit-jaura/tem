////
////  TravelDistanceManager.swift
////  TemApp
////
////  Created by shubham singla on 02/07/20.
////
//
//import UIKit
//import CoreLocation
//
//class TravelDistanceManager: NSObject {
//    
//    static let shared = TravelDistanceManager()
//    let locationManager = CLLocationManager()
//    var startLocation: CLLocation!
//    var lastLocation: CLLocation!
//    var startDate: Date!
//    var distance = Measurement(value: 0, unit: UnitLength.meters)
////    var didFindLocation = false
//    private var locationList: [CLLocation] = []
//    
//
//    func initalize(){
//        if CLLocationManager.locationServicesEnabled() {
//            distance = Measurement(value: 0, unit: UnitLength.meters)
////            didFindLocation = false
//            locationManager.requestAlwaysAuthorization()
//            locationManager.allowsBackgroundLocationUpdates = true
//            locationManager.pausesLocationUpdatesAutomatically = false
//            if #available(iOS 11.0, *) {
//                locationManager.showsBackgroundLocationIndicator = true
//            } else {
//                // Fallback on earlier versions
//            }
//            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
//            locationManager.distanceFilter = 1
//            locationManager.activityType = .fitness
//        }
//    }
//    
//    func start(){
//        locationManager.delegate = self
//                locationManager.startMonitoringSignificantLocationChanges()
//        locationManager.allowsBackgroundLocationUpdates = true
//        locationManager.pausesLocationUpdatesAutomatically = false
//        if #available(iOS 11.0, *) {
//            locationManager.showsBackgroundLocationIndicator = true
//        } else {
//            // Fallback on earlier versions
//        }
//            self.locationManager.startUpdatingLocation()
//        
//    }
//    
//    func stop(){
//       
//        locationManager.stopUpdatingLocation()
//        locationManager.stopMonitoringSignificantLocationChanges()
//    }
//    
////    func restartUpdatingLocation(){
////        initalize()
////        start()
////    }
//}
//
//extension TravelDistanceManager:CLLocationManagerDelegate{
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        if (error as? CLError)?.code == .denied {
//            manager.stopUpdatingLocation()
//            manager.stopMonitoringSignificantLocationChanges()
//        }
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("distance---->\(manager.location)")
//        DispatchQueue.main.async {
//                            print("UIApplication.shared.backgroundTimeRemaining",UIApplication.shared.backgroundTimeRemaining)
//
//                          }
//        for newLocation in locations {
//            let howRecent = newLocation.timestamp.timeIntervalSinceNow
//            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
//            if let lastLocation = locationList.last {
//                let delta = newLocation.distance(from: lastLocation)
//                distance = distance + Measurement(value: delta, unit: UnitLength.meters)
//               
//            }
//            locationList.append(newLocation)
//        }
////        DispatchQueue.main.async {
////            if !self.didFindLocation {
////                if let location = manager.location {
////                    self.setUpGeofenceForJob(location.coordinate)
////                    self.locationManager.stopUpdatingLocation()
////                    self.didFindLocation = true
////                }
////            }
////        }
//    }
//    
////    func setUpGeofenceForJob(_ location :CLLocationCoordinate2D) {
////        print("Geofence location----->",location)
////        let geofenceRegionCenter = CLLocationCoordinate2DMake(location.latitude, location.longitude);
////        let geofenceRegion = CLCircularRegion(center: geofenceRegionCenter, radius: 10, identifier: "PlayaGrande");
////        geofenceRegion.notifyOnExit = true
////        geofenceRegion.notifyOnEntry = true
////        self.locationManager.startMonitoring(for: geofenceRegion)
////    }
//    
////    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
////        alertUserOnArrival(region: region)
////    }
////
////    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
////        alertUserOnLeaving(region: region)
////        didFindLocation = false
////    }
//    
////    func alertUserOnLeaving(region:CLRegion){
////        let content = UNMutableNotificationContent()
////        content.title = "Hello"
////        content.body = "You forgot to checkout"
////        content.sound = UNNotificationSound.default
////        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
////        let request = UNNotificationRequest.init(identifier: "FiveSecond", content: content, trigger: trigger)
////        // Schedule the notification.
////        let center = UNUserNotificationCenter.current()
////        center.add(request)
////
////    }
////
////    func alertUserOnArrival(region:CLRegion){
////        let content = UNMutableNotificationContent()
////        content.title = "Hello"
////        content.body = "Welcome Please checkin"
////        content.sound = UNNotificationSound.default
////        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
////        let request = UNNotificationRequest.init(identifier: "FiveSecond", content: content, trigger: trigger)
////        // Schedule the notification.
////        let center = UNUserNotificationCenter.current()
////        center.add(request)
////    }
//}
//
