//
//  VehicleListViewModel.swift
//  Karen
//
//  Created by Codex on 7/24/26.
//

import Combine
import Foundation
import KarenClient
import KarenShared

@MainActor
final class VehicleListViewModel: ObservableObject {
    @Published private(set) var vehicles: [Vehicle] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let vehicleService = KarenClientProvider.shared.vehicles

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            vehicles = try await vehicleService.getAll()
                .sorted(by: vehicleSort)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func upsert(_ vehicle: Vehicle) {
        if let index = vehicles.firstIndex(where: { $0.id == vehicle.id }) {
            vehicles[index] = vehicle
        } else {
            vehicles.append(vehicle)
        }

        vehicles.sort(by: vehicleSort)
    }

    private func vehicleSort(_ left: Vehicle, _ right: Vehicle) -> Bool {
        left.displayName.localizedCaseInsensitiveCompare(right.displayName) == .orderedAscending
    }
}
