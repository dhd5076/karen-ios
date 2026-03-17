//
//  AppState.swift
//  Karen
//
//  Created by Dylan Dunn on 3/17/26.
//

import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    let locationService: LocationService
    let apiService: APIService
    
    init() {
        self.apiService = APIService()
        self.locationService = LocationService(api: self.apiService)
    }
}
