//
//  LightListViewModel.swift
//  Karen
//
//  Created by Dylan Dunn on 6/22/26.
//

import Foundation
import Combine
import KarenShared

@MainActor
final class LightListViewModel: ObservableObject {
    @Published private(set) var lights: [Light] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil
    
    private let lightService = LightService.shared
    
    func load() async {
        isLoading = true
        errorMessage = nil
        
        do {
            lights = try await lightService.getLights() //TODO: Rename getLights? maybe to getAll?
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func toggle() {
            //TODO: Implement here maybe???
    }
    
    func turnOn(id: String) async {
        do {
            try await lightService.turnOn(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func turnOff(id: String) async {
        do {
            try await lightService.turnOff(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
