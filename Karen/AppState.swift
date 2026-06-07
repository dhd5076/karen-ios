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
    let chatService: ChatService
    let peopleService: PeopleService
    let pantryService: PantryService
    
    init() {
        self.chatService = ChatService()
        self.locationService = LocationService()
        self.peopleService = PeopleService()
        self.pantryService = PantryService()
    }
}
