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
    
    func update(_ person: Person) async throws {
        
        guard let id = person.id else { //TODO: Check that this is proper
            throw URLError(.badURL)
        }
        
        //TODO: UUID has type UUID?, should probably reconcile this despite the check above
        try await api.put("people/\(person.id!)", body: person)
    }
    
    func create(_ person: Person) async throws {
        //TODO: Check if we should create a DTO for this??
        try await api.post("people", body: person)
    }
    
    func getAll() async throws -> [Person] {
        let person: [Person] = try await api.get("/people")
        return person
    }
    
    func get(id: String) async throws -> Person {
        let person: Person =  try await api.get("people/\(id)")
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
        
        let people: [Person] = try await api.get("people/search?name=\(encodedQuery)")
        return people
    }
    
    func delete(id: String) async throws {
        try await api.delete("/people/\(id)")
    }
}
