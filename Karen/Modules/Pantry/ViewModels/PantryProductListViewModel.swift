//
//  PantryProductListViewModel.swift
//  Karen
//
//  Created by Dylan Dunn on 6/13/26.
//

import Foundation
import Combine
import KarenShared

@MainActor
final class PantryProductListViewModel: ObservableObject {
    @Published private(set) var products: [PantryProduct] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    
    
    @Published var searchText = "" //TODO: we may eventually defer to backend for this
    
    private let pantryService = PantryService.shared
    
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            products = try await pantryService.getProducts()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func createProduct(_ product: PantryProduct) async {
        do {
            let _ = try await pantryService.createProduct(product)
            await loadProducts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteProduct(id: UUID) async {
        do {
            try await pantryService.deleteProduct(id: id)
            await loadProducts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    var filteredProducts: [PantryProduct] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            return products
        }
        
        return products.filter {
            $0.name.localizedCaseInsensitiveContains(trimmed)
        }
    }
}
