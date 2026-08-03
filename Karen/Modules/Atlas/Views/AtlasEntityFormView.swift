//
//  AtlasEntityFormView.swift
//  Karen
//

import SwiftUI

struct AtlasEntityFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var type: String
    @State private var displayName: String
    @State private var isSaving = false
    @State private var errorMessage: String?

    let title: String
    let suggestedTypes: [String]
    let allowsTypeEditing: Bool
    let onSave: (String, String) async -> Bool

    init(
        title: String,
        type: String = "",
        displayName: String = "",
        suggestedTypes: [String] = [],
        allowsTypeEditing: Bool = true,
        onSave: @escaping (String, String) async -> Bool
    ) {
        self.title = title
        self.suggestedTypes = suggestedTypes
        self.allowsTypeEditing = allowsTypeEditing
        self.onSave = onSave
        _type = State(initialValue: type)
        _displayName = State(initialValue: displayName)
    }

    var body: some View {
        Form {
            Section("Identity") {
                TextField("Display Name", text: $displayName)

                TextField("Entity Type", text: $type)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .disabled(!allowsTypeEditing)

                if allowsTypeEditing && !suggestedTypes.isEmpty {
                    Menu("Choose Existing Type") {
                        ForEach(suggestedTypes, id: \.self) { suggestion in
                            Button(atlasDisplayName(suggestion)) {
                                type = suggestion
                            }
                        }
                    }
                }
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .disabled(isSaving)
        .overlay {
            if isSaving {
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
                    Task { await save() }
                }
                .disabled(isSaving)
            }
        }
    }

    private func save() async {
        let cleanedType = type.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedType.isEmpty else {
            errorMessage = "Entity type is required."
            return
        }
        guard !cleanedName.isEmpty else {
            errorMessage = "Display name is required."
            return
        }

        isSaving = true
        errorMessage = nil
        if await onSave(cleanedType, cleanedName) {
            dismiss()
        } else {
            errorMessage = "Unable to save the entity."
        }
        isSaving = false
    }
}
