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
    
    private let pantryService: PantryService
    
    public init(pantryService: PantryService) {
        self.pantryService = pantryService
    }
    
    func loadPantries() async throws {
        isLoading = true
        
        do {
            pantries = try await pantryService.getPantries()
        } catch {
            
        }
        
        isLoading = false
    }
}
