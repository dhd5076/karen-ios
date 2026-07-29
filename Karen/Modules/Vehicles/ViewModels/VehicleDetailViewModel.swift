//
//  VehicleDetailViewModel.swift
//  Karen
//
//  Created by Codex on 7/24/26.
//

import Combine
import Foundation
import KarenClient
import KarenShared

@MainActor
final class VehicleDetailViewModel: ObservableObject {
    @Published private(set) var vehicle: VehicleResponse?
    @Published private(set) var plateHistory: [VehicleLicensePlateResponse] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    let vehicleId: UUID

    private let client = KarenClientProvider.shared

    init(vehicleId: UUID) {
        self.vehicleId = vehicleId
    }

    var activePlates: [VehicleLicensePlateResponse] {
        plateHistory.filter { $0.validUntil == nil }
    }

    var historicalPlates: [VehicleLicensePlateResponse] {
        plateHistory
            .filter { $0.validUntil != nil }
            .sorted { ($0.validUntil ?? .distantPast) > ($1.validUntil ?? .distantPast) }
    }

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            async let loadedVehicle = client.getVehicle(id: vehicleId)
            async let loadedPlates = client.getLicensePlateHistory(vehicleId: vehicleId)
            vehicle = try await loadedVehicle
            plateHistory = try await loadedPlates
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func apply(_ vehicle: VehicleResponse) {
        self.vehicle = vehicle
    }

    func addLicensePlate(_ request: LicensePlateRequest) async -> String? {
        do {
            _ = try await client.createAndAssignLicensePlate(
                vehicleId: vehicleId,
                request: request
            )
            plateHistory = try await client.getLicensePlateHistory(vehicleId: vehicleId)
            return nil
        } catch {
            errorMessage = error.localizedDescription
            return error.localizedDescription
        }
    }

    func unassign(_ assignment: VehicleLicensePlateResponse) async {
        do {
            _ = try await client.unassignLicensePlate(
                vehicleId: vehicleId,
                licensePlateId: assignment.licensePlate.id,
                effectiveAt: Date()
            )
            plateHistory = try await client.getLicensePlateHistory(vehicleId: vehicleId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
