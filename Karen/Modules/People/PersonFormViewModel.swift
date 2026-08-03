//
//  PersonFormViewModel.swift
//  Karen
//

import Combine
import Foundation
import KarenKit

@MainActor
final class PersonFormViewModel: ObservableObject {
    @Published var firstName: String
    @Published var middleName: String
    @Published var lastName: String
    @Published private(set) var isSaving = false
    @Published private(set) var errorMessage: String?

    let isEditing: Bool
    private let personId: UUID?
    private let peopleService = KarenClientProvider.shared.people

    init(person: Person? = nil) {
        personId = person?.id
        isEditing = person != nil
        firstName = person?.firstName ?? ""
        middleName = person?.middleName ?? ""
        lastName = person?.lastName ?? ""
    }

    func save() async -> Person? {
        let firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !firstName.isEmpty else {
            errorMessage = "First name is required."
            return nil
        }

        let request = PersonRequest(
            firstName: firstName,
            middleName: normalizedOptional(middleName),
            lastName: normalizedOptional(lastName)
        )

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            if let personId {
                return try await peopleService.update(id: personId, request: request)
            }
            return try await peopleService.create(request)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    private func normalizedOptional(_ value: String) -> String? {
        let cleaned = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? nil : cleaned
    }
}
