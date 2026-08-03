//
//  PeopleViewModel.swift
//  Karen
//
//  Created by Dylan Dunn on 4/5/26.
//

import Combine
import Foundation
import KarenKit

@MainActor
final class PeopleViewModel: ObservableObject {
    @Published var searchText = ""
    @Published private(set) var people: [Person] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let peopleService = KarenClientProvider.shared.people

    var filteredPeople: [Person] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return people }

        return people.filter { person in
            person.displayName.localizedCaseInsensitiveContains(query) ||
                person.firstName.localizedCaseInsensitiveContains(query) ||
                (person.middleName?.localizedCaseInsensitiveContains(query) ?? false) ||
                (person.lastName?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            people = try await peopleService.getAll().sorted(by: personSort)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func upsert(_ person: Person) {
        if let index = people.firstIndex(where: { $0.id == person.id }) {
            people[index] = person
        } else {
            people.append(person)
        }

        people.sort(by: personSort)
    }

    private func personSort(_ left: Person, _ right: Person) -> Bool {
        left.displayName.localizedCaseInsensitiveCompare(right.displayName) == .orderedAscending
    }
}
