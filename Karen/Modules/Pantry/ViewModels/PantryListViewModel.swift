//
//  PantryViewModel.swift
//  Karen
//
//  Created by Dylan Dunn on 6/7/26.
//

import Foundation
import Combine
import KarenShared

@MainActor
final class PantryListViewModel: ObservableObject {
    @Published private(set) var pantries: [Pantry] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    
    
    @Published private(set) var overview = PantryOverview(
        proteinGrams: 0,
        carbsGrams: 0,
        fatGrams: 0
    )
    
    private let pantryService = PantryService.shared
    
    public func createPantry(_ pantry: Pantry) async {
        do {
            let createdPantry = try await pantryService.createPantry(pantry: pantry)
            pantries.append(createdPantry)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func load() async {
        isLoading = true
        
        do {
            pantries = try await pantryService.getPantries()
            overview = try await pantryService.getPantryOverview()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    public func updatePantry() async {
        
    }
    
    public func deletePantry(id: UUID) async {
        do {
            try await pantryService.deletePantry(id: id)
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
