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
    
    func product(for productID: UUID) -> PantryProduct? {
        products.first { $0.id == productID }
    }
    
    public func deleteBatch(id: UUID) async {
        do {
            try await PantryService.shared.deleteBatch(id: id)
            batches.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func consumeBatch(id: UUID, quantity: Double, note: String?) async {
        let request = ConsumePantryBatchRequest(quantity: quantity, note: note)

        do {
            let updatedBatch = try await PantryService.shared.consumeBatch(id: id, request: request)

            if updatedBatch.quantity <= 0 {
                batches.removeAll { $0.id == id }
            } else if let index = batches.firstIndex(where: { $0.id == id }) {
                batches[index] = updatedBatch
            } else {
                await loadPantry()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

}
