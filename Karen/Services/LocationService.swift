//
//  LocationService.swift
//  Karen
//
//  Created by Dylan Dunn on 3/17/26.
//

import Foundation
import CoreLocation
import Combine

@MainActor
final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var latestLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 0
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        print("Latitude: \(location.coordinate.latitude)")
        print("Longitude: \(location.coordinate.longitude)")
    }
}
