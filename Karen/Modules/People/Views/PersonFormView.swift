//
//  PersonFormView.swift
//  Karen
//

import KarenKit
import SwiftUI

struct PersonFormView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: PersonFormViewModel

    private let onSaved: (Person) -> Void

    init(
        person: Person? = nil,
        onSaved: @escaping (Person) -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: PersonFormViewModel(person: person)
        )
        self.onSaved = onSaved
    }

    var body: some View {
        Form {
            Section("Name") {
                TextField("First Name", text: $viewModel.firstName)
                    .textInputAutocapitalization(.words)
                TextField("Middle Name", text: $viewModel.middleName)
                    .textInputAutocapitalization(.words)
                TextField("Last Name", text: $viewModel.lastName)
                    .textInputAutocapitalization(.words)
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(viewModel.isEditing ? "Edit Person" : "Add Person")
        .navigationBarTitleDisplayMode(.inline)
        .disabled(viewModel.isSaving)
        .overlay {
            if viewModel.isSaving {
                ProgressView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        guard let person = await viewModel.save() else { return }
                        onSaved(person)
                        dismiss()
                    }
                }
                .disabled(viewModel.isSaving)
            }
        }
    }
}
