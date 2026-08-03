//
//  AtlasRelationshipFormView.swift
//  Karen
//

import KarenKit
import SwiftUI

struct AtlasRelationshipFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var relationshipType = ""
    @State private var relatedEntityId: UUID?
    @State private var currentEntityIsSubject = true
    @State private var hasValidFrom = false
    @State private var validFrom = Date()
    @State private var isSaving = false
    @State private var errorMessage: String?

    let currentEntity: AtlasEntity
    let entities: [AtlasEntity]
    let onSave: (UUID, String, UUID, Date?) async -> Bool

    var body: some View {
        NavigationStack {
            Form {
                Section("Relationship") {
                    TextField("Relationship Type", text: $relationshipType)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    NavigationLink {
                        AtlasEntityPickerView(
                            entities: entities,
                            selection: $relatedEntityId
                        )
                    } label: {
                        LabeledContent(
                            "Related Entity",
                            value: selectedEntity?.displayName ?? "Select"
                        )
                    }

                    Picker("Direction", selection: $currentEntityIsSubject) {
                        Text("From " + currentEntity.displayName).tag(true)
                        Text("To " + currentEntity.displayName).tag(false)
                    }
                }

                Section("Effective Date") {
                    Toggle("Specify Start Date", isOn: $hasValidFrom)
                    if hasValidFrom {
                        DatePicker("Starts", selection: $validFrom)
                    }
                }

                if let previewText {
                    Section("Preview") {
                        Text(previewText)
                    }
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Add Relationship")
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
    }

    private var selectedEntity: AtlasEntity? {
        guard let relatedEntityId else { return nil }
        return entities.first { $0.id == relatedEntityId }
    }

    private var previewText: String? {
        guard let selectedEntity else { return nil }
        let type = atlasDisplayName(relationshipType)
        guard !type.isEmpty else { return nil }

        if currentEntityIsSubject {
            return "\(currentEntity.displayName) -> \(type) -> \(selectedEntity.displayName)"
        }
        return "\(selectedEntity.displayName) -> \(type) -> \(currentEntity.displayName)"
    }

    private func save() async {
        let cleanedType = relationshipType.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedType.isEmpty else {
            errorMessage = "Relationship type is required."
            return
        }
        guard let relatedEntityId else {
            errorMessage = "Select a related entity."
            return
        }

        let subject = currentEntityIsSubject ? currentEntity.id : relatedEntityId
        let object = currentEntityIsSubject ? relatedEntityId : currentEntity.id

        isSaving = true
        errorMessage = nil
        if await onSave(subject, cleanedType, object, hasValidFrom ? validFrom : nil) {
            dismiss()
        } else {
            errorMessage = "Unable to create the relationship."
        }
        isSaving = false
    }
}

private struct AtlasEntityPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    let entities: [AtlasEntity]
    @Binding var selection: UUID?

    private var filteredEntities: [AtlasEntity] {
        guard !searchText.isEmpty else { return entities }
        return entities.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText) ||
                $0.type.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List(filteredEntities) { entity in
            Button {
                selection = entity.id
                dismiss()
            } label: {
                HStack {
                    AtlasEntityRow(entity: entity)
                    Spacer()
                    if selection == entity.id {
                        Image(systemName: "checkmark")
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .navigationTitle("Related Entity")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search entities")
        .overlay {
            if filteredEntities.isEmpty {
                ContentUnavailableView.search(text: searchText)
            }
        }
    }
}
