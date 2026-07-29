//
//  VehicleService.swift
//  Karen
//
//  Created by Codex on 7/24/26.
//

import Foundation
import KarenShared

final class VehicleService {
    static let shared = VehicleService()

    private let apiClient = APIClient.shared
    private let path = VehicleModule.route

    private init() {}

    func getVehicles() async throws -> [VehicleResponse] {
        try await apiClient.get(path)
    }

    func getVehicle(id: UUID) async throws -> VehicleResponse {
        try await apiClient.get("\(path)/\(id)")
    }

    func createVehicle(_ request: VehicleRequest) async throws -> VehicleResponse {
        try await apiClient.post(path, body: request)
    }

    func updateVehicle(id: UUID, request: VehicleRequest) async throws -> VehicleResponse {
        try await apiClient.put("\(path)/\(id)", body: request)
    }

    func getMakes() async throws -> [VehicleMakeResponse] {
        try await apiClient.get("\(path)/makes")
    }

    func createMake(displayName: String) async throws -> VehicleMakeResponse {
        try await apiClient.post(
            "\(path)/makes",
            body: VehicleNameRequest(displayName: displayName)
        )
    }

    func getModels(makeId: UUID) async throws -> [VehicleModelResponse] {
        try await apiClient.get("\(path)/makes/\(makeId)/models")
    }

    func createModel(makeId: UUID, displayName: String) async throws -> VehicleModelResponse {
        try await apiClient.post(
            "\(path)/makes/\(makeId)/models",
            body: VehicleNameRequest(displayName: displayName)
        )
    }

    func getLicensePlateHistory(vehicleId: UUID) async throws -> [VehicleLicensePlateResponse] {
        try await apiClient.get("\(path)/\(vehicleId)/license-plates")
    }

    func createAndAssignLicensePlate(
        vehicleId: UUID,
        request: LicensePlateRequest
    ) async throws -> VehicleLicensePlateResponse {
        try await apiClient.post(
            "\(path)/\(vehicleId)/license-plates",
            body: request
        )
    }

    func assignLicensePlate(
        vehicleId: UUID,
        licensePlateId: UUID,
        effectiveAt: Date? = nil
    ) async throws -> VehicleLicensePlateResponse {
        try await apiClient.post(
            "\(path)/\(vehicleId)/license-plates/\(licensePlateId)/assign",
            body: LicensePlateRelationshipRequest(effectiveAt: effectiveAt)
        )
    }

    func unassignLicensePlate(
        vehicleId: UUID,
        licensePlateId: UUID,
        effectiveAt: Date? = nil
    ) async throws -> VehicleLicensePlateResponse {
        try await apiClient.post(
            "\(path)/\(vehicleId)/license-plates/\(licensePlateId)/unassign",
            body: LicensePlateRelationshipRequest(effectiveAt: effectiveAt)
        )
    }
}
