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
    let apiService: APIService
    let locationService: LocationService
    let chatService: ChatService
    let peopleService: PeopleService
    
    init() {
        self.apiService = APIService()
        self.chatService = ChatService(api: self.apiService)
        self.locationService = LocationService(api: self.apiService)
        self.peopleService = PeopleService(api: self.apiService)
    }
}
