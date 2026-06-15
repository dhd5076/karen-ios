//
//  TaskService.swift
//  Karen
//
//  Created by Dylan Dunn on 6/15/26.
//

import Foundation
import KarenShared

final class TaskService {
    private let apiClient: APIClient
    private let path = KTask.baseRoute
    
    static let shared = TaskService()
    
    private init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func getTasks() async throws -> [KTask] {
        try await apiClient.get(path)
    }

    func createTask(_ task: KTask) async throws -> KTask {
        try await apiClient.post(path, body: task)
    }

    func updateTask(_ task: KTask) async throws -> KTask {
        guard let id = task.id else {
            throw URLError(.badURL)
        }

        return try await apiClient.put(path + "/\(id.uuidString)", body: task)
    }

    func deleteTask(id: UUID) async throws {
        try await apiClient.delete(path + "/\(id.uuidString)")
    }

    func toggleComplete(id: UUID) async throws {
        try await apiClient.post(
            path + "/\(id.uuidString)/toggle-complete",
            body: EmptyRequest()
        )
    }
}

private struct EmptyRequest: Encodable {}
