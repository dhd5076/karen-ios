//
//  LocationService.swift
//  Karen
//
//  Created by Dylan Dunn on 3/17/26.
//

import Foundation
import CoreLocation
import Combine

final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let apiClient: APIClient
    private let manager = CLLocationManager()

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
        super.init()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 10.0
        
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        print("Latitude: \(location.coordinate.latitude)")
        print("Longitude: \(location.coordinate.longitude)")
        
        logLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, timestamp: location.timestamp)
    }
    
    func logLocation(latitude: Double, longitude: Double, timestamp: Date) {
        let payload = Location(
            type: "device",
            latitude: latitude,
            longitude: longitude,
            recordedAt: timestamp
        )
        
        Task {
            try? await apiClient.post("location", body: payload)
        }
    }
}
