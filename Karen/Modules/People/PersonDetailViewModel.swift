//
//  PersonDetailViewModel.swift
//  Karen
//

import Combine
import Foundation
import KarenKit

@MainActor
final class PersonDetailViewModel: ObservableObject {
    @Published private(set) var person: Person?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    let personId: UUID
    private let peopleService = KarenClientProvider.shared.people

    init(personId: UUID) {
        self.personId = personId
    }

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            person = try await peopleService.get(id: personId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func apply(_ person: Person) {
        self.person = person
    }
}
