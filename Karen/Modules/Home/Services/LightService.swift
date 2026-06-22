//
//  LightService.swift
//  Karen
//
//  Created by Dylan Dunn on 6/22/26.
//

import Foundation
import KarenShared

final class LightService {
    private let apiService: APIClient
    private let path: String
    
    static let shared = LightService()
    
    private init(apiService: APIClient = .shared) {
        self.apiService = apiService
        path = HomeModule.path(Light.baseRoute)
        
    }
    
    func getLights() async throws -> [Light] {
        let lights: [Light] = try await apiService.get(path)
        
        return lights
    }
    
    func turnOn(id: String) async throws {
        try await apiService.post(path + "/\(id)/turn-on", body: EmptyRequest())
    }
    
    func turnOff(id: String) async throws {
        try await apiService.post(path + "/\(id)/turn-off", body: EmptyRequest())
    }
    
    func toggle(id: String) async throws {
        //TODO: Implement here or on backend
    }
}

private struct EmptyRequest: Encodable {}
