//
//  AddToPantryViewModel.swift
//  Karen
//
//  Created by Dylan Dunn on 6/13/26.
//

import Foundation
import Combine
import KarenShared

@MainActor
final class AddToPantryViewModel: ObservableObject {
    let pantryId: UUID
    
    @Published private(set) var products: [PantryProduct] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    private let pantryService = PantryService.shared
    
    @Published var productId: UUID?
    @Published var quantity = 1.0
    @Published var source = ""
    @Published var acquiredAt = Date()
    @Published var note = ""
    
    init(pantryId: UUID) {
        self.pantryId = pantryId
    }
    
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            products = try await pantryService.getProducts()
            
            if productId == nil {
                productId = products.first?.id
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func addToPantry() async -> Bool {
        guard let productId else {
            errorMessage = "Select a product"
            return false
        }
        
        guard quantity > 0 else {
            errorMessage = "Quantity must be greater than zero"
            return false
        }
        
        let trimmedSource = source.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedSource.isEmpty else {
            errorMessage = "Enter a source"
            return false
        }
        
        let request = AddBatchToPantryRequest(
            product: productId,
            quantity: quantity,
            source: source,
            acquiredAt: acquiredAt,
            note: note
        )
        
        do {
            _ = try await pantryService.addBatchToPantry(pantryId: pantryId, request: request)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
