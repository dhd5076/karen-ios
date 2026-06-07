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
    
    
    func loadPantries() async {
        isLoading = true
        
        do {
            pantries = try await pantryService.getPantries()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
