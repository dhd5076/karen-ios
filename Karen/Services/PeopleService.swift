//
//  PersonService.swift
//  Karen
//
//  Created by Dylan Dunn on 4/1/26.
//

import Foundation

final class PeopleService {
    private let api: APIService
    
    init(api: APIService) {
        self.api = api
    }
    
    func create(_ person: Person) async throws {
        //TODO: Check if we should create a DTO for this??
        try await api.post("person", body: person)
    }
    
    func get(id: String) async throws -> Person {
        let person: Person =  try await api.get("person/\(id)")
        return person
    }
    
    func searchByName(query: String) async throws -> [Person] {
        
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedQuery.isEmpty else {
            return []
        }
        
        guard let encodedQuery =
            trimmedQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                throw URLError(.badURL)
        }
        
        let people: [Person] = try await api.get("person/search?name=\(encodedQuery)")
        return people
    }
}
