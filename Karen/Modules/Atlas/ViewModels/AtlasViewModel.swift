//
//  AtlasViewModel.swift
//  Karen
//

import Combine
import Foundation
import KarenKit

@MainActor
final class AtlasViewModel: ObservableObject {
    @Published private(set) var entities: [AtlasEntity] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let atlasService = KarenClientProvider.shared.atlas

    var entityTypes: [EntityType] {
        Array(Set(entities.map(\.type))).sorted {
            $0.rawValue.localizedCaseInsensitiveCompare($1.rawValue) == .orderedAscending
        }
    }

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            entities = try await atlasService.getEntities().sorted(by: entitySort)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func createEntity(type: String, displayName: String) async -> AtlasEntity? {
        errorMessage = nil

        do {
            let entity = try await atlasService.createEntity(
                CreateAtlasEntityRequest(
                    type: EntityType(rawValue: type),
                    displayName: displayName
                )
            )
            upsert(entity)
            return entity
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func upsert(_ entity: AtlasEntity) {
        if let index = entities.firstIndex(where: { $0.id == entity.id }) {
            entities[index] = entity
        } else {
            entities.append(entity)
        }

        entities.sort(by: entitySort)
    }

    private func entitySort(_ left: AtlasEntity, _ right: AtlasEntity) -> Bool {
        left.displayName.localizedCaseInsensitiveCompare(right.displayName) == .orderedAscending
    }
}
