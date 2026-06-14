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
        path = PantryModule.path(Pantry.baseRoute) //TODO: Revisit this pattern later
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
    
    func deletePantry(id: UUID) async throws {
        try await apiService.delete(path + "/\(id.uuidString)")
    }
    
    private var productsPath: String {
        PantryModule.path(PantryProduct.baseRoute) //TODO: revisit this later and figure out if this is the pattern I want to keep
    }

    func getProducts() async throws -> [PantryProduct] {
        try await apiService.get(productsPath)
    }

    func createProduct(_ product: PantryProduct) async throws -> PantryProduct {
        try await apiService.post(productsPath, body: product)
    }

    func deleteProduct(id: UUID) async throws {
        try await apiService.delete(productsPath + "/\(id.uuidString)")
    }
    
    func addBatchToPantry(pantryId: UUID, request: AddBatchToPantryRequest) async throws -> PantryBatch {
        let createdPantryBatch: PantryBatch = try await apiService.post(path + "/\(pantryId.uuidString)/add", body: request)
        return createdPantryBatch
    }
    
    func getBatchesForPantry(pantryId: UUID) async throws -> [PantryBatch] {
        try await apiService.get(path + "/\(pantryId.uuidString)/batches")
    }

    func deleteBatch(id: UUID) async throws {
        try await apiService.delete(PantryModule.path(PantryBatch.baseRoute) + "/\(id.uuidString)")
    }

    func consumeBatch(id: UUID, request: ConsumePantryBatchRequest) async throws -> PantryBatch {
        try await apiService.post(
            PantryModule.path(PantryBatch.baseRoute) + "/\(id.uuidString)/consume",
            body: request
        )
    }
}
