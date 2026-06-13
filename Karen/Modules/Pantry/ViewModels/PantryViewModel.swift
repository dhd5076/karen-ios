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
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }

}
