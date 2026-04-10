//
//  PeopleViewMode.swift
//  Karen
//
//  Created by Dylan Dunn on 4/5/26.
//

import Foundation
import Combine

@MainActor
final class PeopleViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var people: [Person] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let peopleService: PeopleService
    
    init(peopleService: PeopleService) {
        self.peopleService = peopleService
        
        Task {
            await getAllPeople()
        }
    }
    
    func update(_ person: Person) async {
        do {
            try await peopleService.update(person)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func create(_ person: Person) async {
        do {
            try await peopleService.create(person)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func searchByName() async {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            await getAllPeople()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            people = try await peopleService.searchByName(query: trimmed)
        } catch {
            people = []
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func getAllPeople() async {
        isLoading = true
        errorMessage = nil
        do {
            people = try await peopleService.getAll()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
