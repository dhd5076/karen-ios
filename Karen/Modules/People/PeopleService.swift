//
//  PersonService.swift
//  Karen
//
//  Created by Dylan Dunn on 4/1/26.
//

import Foundation

final class PeopleService {
    private let apiClient = APIClient.shared
    
    static let shared = PeopleService()
    
    
    func update(_ person: Person) async throws -> Person {
        
        guard let id = person.id else {
            throw URLError(.badURL) //TODO: Probably should use a different error type, works for now
        }
        
        //TODO: UUID has type UUID?, should probably reconcile this despite the check above
        return try await apiClient.put("people/\(id)", body: person)
    }
    
    func create(_ person: Person) async throws -> Person {
        //TODO: Check if we should create a DTO for this??
        return try await apiClient.post("people", body: person)
    }
    
    func getAll() async throws -> [Person] {
        let person: [Person] = try await apiClient.get("/people")
        return person
    }
    
    func get(id: String) async throws -> Person {
        let person: Person =  try await apiClient.get("people/\(id)")
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
        
        let people: [Person] = try await apiClient.get("people/search?name=\(encodedQuery)")
        return people
    }
    
    /* func delete(id: String) async throws -> Person {
        //TODO Fix try await apiClient.delete("/people/\(id)")
    } */
}
