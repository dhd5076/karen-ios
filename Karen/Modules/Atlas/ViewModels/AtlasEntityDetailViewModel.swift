//
//  AtlasEntityDetailViewModel.swift
//  Karen
//

import Combine
import Foundation
import KarenKit

@MainActor
final class AtlasEntityDetailViewModel: ObservableObject {
    @Published private(set) var entity: AtlasEntity?
    @Published private(set) var attributes: [AtlasAttribute] = []
    @Published private(set) var relationships: [AtlasRelationship] = []
    @Published private(set) var relatedEntities: [UUID: AtlasEntity] = [:]
    @Published private(set) var isLoading = false
    @Published private(set) var isSaving = false
    @Published private(set) var errorMessage: String?

    let entityId: UUID
    private let atlasService = KarenClientProvider.shared.atlas

    init(entityId: UUID) {
        self.entityId = entityId
    }

    var activeRelationships: [AtlasRelationship] {
        relationships.filter { $0.validUntil == nil }
    }

    var historicalRelationships: [AtlasRelationship] {
        relationships.filter { $0.validUntil != nil }
    }

    var availableRelatedEntities: [AtlasEntity] {
        relatedEntities.values
            .filter { $0.id != entityId }
            .sorted {
                $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
            }
    }

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            async let loadedEntity = atlasService.getEntity(id: entityId)
            async let loadedAttributes = atlasService.getAttributes(entityId: entityId)
            async let loadedRelationships = atlasService.getRelationships(
                entityId: entityId,
                includeEnded: true
            )
            async let loadedEntities = atlasService.getEntities()

            let (entity, attributes, relationships, entities) = try await (
                loadedEntity,
                loadedAttributes,
                loadedRelationships,
                loadedEntities
            )

            self.entity = entity
            self.attributes = attributes.sorted {
                $0.key.rawValue.localizedCaseInsensitiveCompare($1.key.rawValue) == .orderedAscending
            }
            self.relationships = relationships.sorted(by: relationshipSort)
            self.relatedEntities = Dictionary(uniqueKeysWithValues: entities.map { ($0.id, $0) })
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func updateDisplayName(_ displayName: String) async -> AtlasEntity? {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            let updated = try await atlasService.updateEntity(
                id: entityId,
                request: UpdateAtlasEntityRequest(displayName: displayName)
            )
            entity = updated
            relatedEntities[updated.id] = updated
            return updated
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func setAttribute(key: String, value: String, valueType: String) async -> Bool {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            let attributeKey = AttributeKey(rawValue: key)
            let attribute = try await atlasService.setAttribute(
                entityId: entityId,
                key: attributeKey,
                request: SetAtlasAttributeRequest(value: value, valueType: valueType)
            )

            if let index = attributes.firstIndex(where: { $0.key == attributeKey }) {
                attributes[index] = attribute
            } else {
                attributes.append(attribute)
            }
            attributes.sort {
                $0.key.rawValue.localizedCaseInsensitiveCompare($1.key.rawValue) == .orderedAscending
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func createRelationship(
        subject: UUID,
        type: String,
        object: UUID,
        validFrom: Date?
    ) async -> Bool {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            let relationship = try await atlasService.createRelationship(
                CreateAtlasRelationshipRequest(
                    subject: subject,
                    type: RelationshipType(rawValue: type),
                    object: object,
                    validFrom: validFrom
                )
            )
            relationships.append(relationship)
            relationships.sort(by: relationshipSort)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func endRelationship(_ relationship: AtlasRelationship) async -> Bool {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            let ended = try await atlasService.endRelationship(id: relationship.id)
            if let index = relationships.firstIndex(where: { $0.id == ended.id }) {
                relationships[index] = ended
            }
            relationships.sort(by: relationshipSort)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func entity(withId id: UUID) -> AtlasEntity? {
        if entity?.id == id {
            return entity
        }
        return relatedEntities[id]
    }

    private func relationshipSort(
        _ left: AtlasRelationship,
        _ right: AtlasRelationship
    ) -> Bool {
        if (left.validUntil == nil) != (right.validUntil == nil) {
            return left.validUntil == nil
        }
        return left.type.rawValue.localizedCaseInsensitiveCompare(right.type.rawValue) == .orderedAscending
    }
}
