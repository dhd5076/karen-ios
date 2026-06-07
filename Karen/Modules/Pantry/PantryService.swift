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
    
    init(apiService: APIClient = .shared) {
        self.apiService = apiService
    }
    
    func getPantries() async throws -> [Pantry] {
        let pantries: [Pantry] = try await apiService.get(Pantry.baseRoute)
        
        return pantries
    }
}
