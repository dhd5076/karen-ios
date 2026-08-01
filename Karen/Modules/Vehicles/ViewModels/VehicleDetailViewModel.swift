//
//  VehicleDetailViewModel.swift
//  Karen
//
//  Created by Codex on 7/24/26.
//

import Combine
import Foundation
import KarenKit
import KarenShared

@MainActor
final class VehicleDetailViewModel: ObservableObject {
    @Published private(set) var vehicle: Vehicle?
    @Published private(set) var plateHistory: [VehicleLicensePlateAssignment] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    let vehicleId: UUID

    private let vehicleService = KarenClientProvider.shared.vehicles

    init(vehicleId: UUID) {
        self.vehicleId = vehicleId
    }

    var activePlates: [VehicleLicensePlateAssignment] {
        plateHistory.filter { $0.validUntil == nil }
    }

    var historicalPlates: [VehicleLicensePlateAssignment] {
        plateHistory
            .filter { $0.validUntil != nil }
            .sorted { ($0.validUntil ?? .distantPast) > ($1.validUntil ?? .distantPast) }
    }

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            async let loadedVehicle = vehicleService.get(id: vehicleId)
            async let loadedPlates = vehicleService.getLicensePlateHistory(vehicleId: vehicleId)
            vehicle = try await loadedVehicle
            plateHistory = try await loadedPlates
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func apply(_ vehicle: Vehicle) {
        self.vehicle = vehicle
    }

    func addLicensePlate(_ request: LicensePlateRequest) async -> String? {
        do {
            _ = try await vehicleService.createAndAssignLicensePlate(
                vehicleId: vehicleId,
                request: request
            )
            plateHistory = try await vehicleService.getLicensePlateHistory(vehicleId: vehicleId)
            return nil
        } catch {
            errorMessage = error.localizedDescription
            return error.localizedDescription
        }
    }

    func unassign(_ assignment: VehicleLicensePlateAssignment) async {
        do {
            _ = try await vehicleService.unassignLicensePlate(
                vehicleId: vehicleId,
                licensePlateId: assignment.licensePlate.id,
                effectiveAt: Date()
            )
            plateHistory = try await vehicleService.getLicensePlateHistory(vehicleId: vehicleId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
