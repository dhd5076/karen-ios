//
//  ViewPantryViewModel.swift
//  Karen
//
//  Created by Dylan Dunn on 6/12/26.
//

import Foundation
import Combine
import KarenShared

@MainActor
final class PantryViewModel: ObservableObject {
    let pantryID: UUID
    
    @Published var pantry: Pantry?
    @Published var batches: [PantryBatch] = []
    @Published var products: [PantryProduct] = [] //TODO: This should maybe be done on backend?? Different DTO maybe??
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init(pantryID: UUID) {
        self.pantryID = pantryID
    }
    
    public func loadPantry() async {
        isLoading = true
        errorMessage = nil
        
        do {
            pantry = try await PantryService.shared.getPantryById(id: pantryID)
            batches = try await PantryService.shared.getBatchesForPantry(pantryId: pantryID)
            products = try await PantryService.shared.getProducts()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func productName(for productID: UUID) -> String {
        products.first { $0.id == productID }?.name ?? productID.uuidString
    }
    
    public func deleteBatch(id: UUID) async {
        do {
            try await PantryService.shared.deleteBatch(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

}
