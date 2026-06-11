//
//  PantryService.swift
//  Karen
//
//  Created by Dylan Dunn on 6/7/26.
//

import Foundation
import KarenShared

final class PantryService {
    private let apiService: APIClient
    private let path: String
    
    static let shared = PantryService()
    
    private init(apiService: APIClient = .shared) {
        self.apiService = apiService
        path = PantryModule.path(Pantry.baseRoute)
        print(path)
    }
    
    func createPantry(pantry: Pantry) async throws -> Pantry {
        let createdPantry: Pantry = try await apiService.post(path, body: pantry)
        
        return createdPantry
    }
    
    func getPantries() async throws -> [Pantry] {
        let pantries: [Pantry] = try await apiService.get(path)
        
        return pantries
    }
    
    func getPantryById(id: UUID) async throws -> Pantry {
        let pantry: Pantry = try await apiService.get(path + "/\(id.uuidString)")
        
        return pantry
    }
    
    func updatePantry(pantry: Pantry) async throws -> Pantry {
        let updatedPantry: Pantry = try await apiService.put(path, body: pantry)
        
        return updatedPantry
        
    }
}
