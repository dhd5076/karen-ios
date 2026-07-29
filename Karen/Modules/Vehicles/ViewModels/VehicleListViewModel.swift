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
    @Published private(set) var vehicles: [VehicleResponse] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let client = KarenClientProvider.shared

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            vehicles = try await client.getVehicles()
                .sorted(by: vehicleSort)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func upsert(_ vehicle: VehicleResponse) {
        if let index = vehicles.firstIndex(where: { $0.id == vehicle.id }) {
            vehicles[index] = vehicle
        } else {
            vehicles.append(vehicle)
        }

        vehicles.sort(by: vehicleSort)
    }

    private func vehicleSort(_ left: VehicleResponse, _ right: VehicleResponse) -> Bool {
        left.displayName.localizedCaseInsensitiveCompare(right.displayName) == .orderedAscending
    }
}
