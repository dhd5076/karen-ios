//
//  AtlasEntityDetailView.swift
//  Karen
//

import KarenKit
import SwiftUI

struct AtlasEntityDetailView: View {
    @StateObject private var viewModel: AtlasEntityDetailViewModel
    @State private var showingEditEntity = false
    @State private var showingAddAttribute = false
    @State private var showingAddRelationship = false
    @State private var showingEditAttribute = false
    @State private var attributeToEdit: AtlasAttribute?
    @State private var relationshipToEnd: AtlasRelationship?
    @State private var showingEndConfirmation = false

    private let onEntityUpdated: (AtlasEntity) -> Void

    init(
        entityId: UUID,
        onEntityUpdated: @escaping (AtlasEntity) -> Void = { _ in }
    ) {
        _viewModel = StateObject(
            wrappedValue: AtlasEntityDetailViewModel(entityId: entityId)
        )
        self.onEntityUpdated = onEntityUpdated
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.entity == nil {
                ProgressView("Loading Entity...")
            } else if let entity = viewModel.entity {
                entityList(entity)
            } else {
                ContentUnavailableView {
                    Label("Unable to Load Entity", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(viewModel.errorMessage ?? "The entity could not be loaded.")
                } actions: {
                    Button("Try Again") {
                        Task { await viewModel.load() }
                    }
                }
            }
        }
        .navigationTitle(viewModel.entity?.displayName ?? "Entity")
        .toolbar {
            if viewModel.entity != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showingEditEntity = true
                        } label: {
                            Label("Edit Entity", systemImage: "pencil")
                        }

                        Button {
                            showingAddAttribute = true
                        } label: {
                            Label("Add Attribute", systemImage: "text.badge.plus")
                        }

                        Button {
                            showingAddRelationship = true
                        } label: {
                            Label("Add Relationship", systemImage: "link.badge.plus")
                        }
                        .disabled(viewModel.availableRelatedEntities.isEmpty)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("Entity Actions")
                }
            }
        }
        .sheet(isPresented: $showingEditEntity) {
            if let entity = viewModel.entity {
                NavigationStack {
                    AtlasEntityFormView(
                        title: "Edit Entity",
                        type: entity.type.rawValue,
                        displayName: entity.displayName,
                        allowsTypeEditing: false
                    ) { _, displayName in
                        guard let updated = await viewModel.updateDisplayName(displayName) else {
                            return false
                        }
                        onEntityUpdated(updated)
                        return true
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddAttribute) {
            AtlasAttributeFormView { key, value, valueType in
                await viewModel.setAttribute(key: key, value: value, valueType: valueType)
            }
        }
        .sheet(isPresented: $showingEditAttribute) {
            if let attribute = attributeToEdit {
                AtlasAttributeFormView(
                    key: attribute.key.rawValue,
                    value: attribute.value,
                    valueType: attribute.valueType,
                    isEditing: true
                ) { key, value, valueType in
                    await viewModel.setAttribute(key: key, value: value, valueType: valueType)
                }
            }
        }
        .sheet(isPresented: $showingAddRelationship) {
            if let entity = viewModel.entity {
                AtlasRelationshipFormView(
                    currentEntity: entity,
                    entities: viewModel.availableRelatedEntities
                ) { subject, type, object, validFrom in
                    await viewModel.createRelationship(
                        subject: subject,
                        type: type,
                        object: object,
                        validFrom: validFrom
                    )
                }
            }
        }
        .alert("End Relationship?", isPresented: $showingEndConfirmation) {
            Button("Cancel", role: .cancel) {
                relationshipToEnd = nil
            }
            Button("End Relationship", role: .destructive) {
                guard let relationshipToEnd else { return }
                Task {
                    _ = await viewModel.endRelationship(relationshipToEnd)
                    self.relationshipToEnd = nil
                }
            }
        } message: {
            Text("The relationship will move to history and will not be deleted.")
        }
        .task {
            await viewModel.load()
        }
    }

    private func entityList(_ entity: AtlasEntity) -> some View {
        List {
            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            Section("Identity") {
                LabeledContent("Display Name", value: entity.displayName)
                LabeledContent("Type", value: atlasDisplayName(entity.type.rawValue))
            }

            Section("Attributes") {
                if viewModel.attributes.isEmpty {
                    Text("No attributes")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.attributes, id: \.key) { attribute in
                        Button {
                            attributeToEdit = attribute
                            showingEditAttribute = true
                        } label: {
                            VStack(alignment: .leading, spacing: 3) {
                                LabeledContent(
                                    atlasDisplayName(attribute.key.rawValue),
                                    value: attribute.value
                                )
                                Text(atlasDisplayName(attribute.valueType))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            relationshipSection(
                title: "Relationships",
                relationships: viewModel.activeRelationships,
                canEnd: true
            )

            if !viewModel.historicalRelationships.isEmpty {
                relationshipSection(
                    title: "Relationship History",
                    relationships: viewModel.historicalRelationships,
                    canEnd: false
                )
            }

            Section("Technical Details") {
                LabeledContent("Entity ID", value: entity.id.uuidString)
                    .textSelection(.enabled)
            }
        }
        .refreshable {
            await viewModel.load()
        }
        .disabled(viewModel.isSaving)
    }

    @ViewBuilder
    private func relationshipSection(
        title: String,
        relationships: [AtlasRelationship],
        canEnd: Bool
    ) -> some View {
        Section(title) {
            if relationships.isEmpty {
                Text("No relationships")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(relationships) { relationship in
                    if let relatedEntity = relatedEntity(for: relationship) {
                        NavigationLink {
                            AtlasEntityDetailView(entityId: relatedEntity.id)
                        } label: {
                            relationshipLabel(relationship, relatedEntity: relatedEntity)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            if canEnd {
                                Button("End", role: .destructive) {
                                    relationshipToEnd = relationship
                                    showingEndConfirmation = true
                                }
                            }
                        }
                    } else {
                        relationshipLabel(relationship, relatedEntity: nil)
                    }
                }
            }
        }
    }

    private func relationshipLabel(
        _ relationship: AtlasRelationship,
        relatedEntity: AtlasEntity?
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(relatedEntity?.displayName ?? "Unknown Entity")
                .font(.headline)

            Text(relationshipDescription(relationship))
                .font(.caption)
                .foregroundStyle(.secondary)

            if let validUntil = relationship.validUntil {
                Text("Ended \(validUntil.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if let validFrom = relationship.validFrom {
                Text("Since \(validFrom.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private func relatedEntity(for relationship: AtlasRelationship) -> AtlasEntity? {
        let relatedId = relationship.subject == viewModel.entityId
            ? relationship.object
            : relationship.subject
        return viewModel.entity(withId: relatedId)
    }

    private func relationshipDescription(_ relationship: AtlasRelationship) -> String {
        let subject = viewModel.entity(withId: relationship.subject)?.displayName ?? "Unknown Entity"
        let object = viewModel.entity(withId: relationship.object)?.displayName ?? "Unknown Entity"
        return "\(subject) -> \(atlasDisplayName(relationship.type.rawValue)) -> \(object)"
    }
}
