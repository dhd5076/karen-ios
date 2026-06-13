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
final class PantryViewModel: ObservableObject {
    @Published private(set) var pantries: [Pantry] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let pantryService = PantryService.shared
    
    public func createPantry(_ pantry: Pantry) async {
        do {
            let createdPantry = try await pantryService.createPantry(pantry: pantry)
            pantries.append(createdPantry)
        } catch {
            print(error.localizedDescription)
            errorMessage = error.localizedDescription
        }
    }
    
    func loadPantries() async {
        isLoading = true
        
        do {
            pantries = try await pantryService.getPantries()
        } catch {
            print(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    public func updatePantry() async {
        
    }
    
    public func deletePantry() async {
        
    }
}
