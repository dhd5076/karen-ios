//
//  VehicleFormViewModel.swift
//  Karen
//
//  Created by Codex on 7/24/26.
//

import Combine
import Foundation
import KarenShared

@MainActor
final class VehicleFormViewModel: ObservableObject {
    @Published var displayName: String
    @Published var vehicleType: String
    @Published var modelYear: String
    @Published var makeId: UUID?
    @Published var modelId: UUID?
    @Published var trim: String
    @Published var color: String
    @Published var vin: String

    @Published private(set) var makes: [VehicleMake] = []
    @Published private(set) var models: [VehicleModel] = []
    @Published private(set) var isLoadingCatalog = false
    @Published private(set) var isSaving = false
    @Published private(set) var errorMessage: String?

    let vehicle: Vehicle?
    let commonVehicleTypes = [
        "car", "truck", "suv", "van", "motorcycle", "tractor", "trailer", "other"
    ]

    private let vehicleService = KarenClientProvider.shared.vehicles

    init(vehicle: Vehicle? = nil) {
        self.vehicle = vehicle
        displayName = vehicle?.displayName ?? ""
        vehicleType = vehicle?.vehicleType ?? "car"
        modelYear = vehicle?.modelYear.map(String.init) ?? ""
        makeId = vehicle?.make?.id
        modelId = vehicle?.model?.id
        trim = vehicle?.trim ?? ""
        color = vehicle?.color ?? ""
        vin = vehicle?.vin ?? ""
    }

    var isEditing: Bool {
        vehicle != nil
    }

    var vehicleTypeOptions: [String] {
        var options = commonVehicleTypes
        if !vehicleType.isEmpty && !options.contains(vehicleType) {
            options.append(vehicleType)
        }
        return options
    }

    func loadCatalog() async {
        isLoadingCatalog = true
        errorMessage = nil

        do {
            makes = try await vehicleService.getMakes()
            if let makeId {
                models = try await vehicleService.getModels(makeId: makeId)
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingCatalog = false
    }

    func makeSelectionChanged(to newMakeId: UUID?) async {
        modelId = nil
        models = []
        guard let newMakeId else { return }

        do {
            models = try await vehicleService.getModels(makeId: newMakeId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createMake(displayName: String) async -> Bool {
        do {
            let make = try await vehicleService.createMake(displayName: displayName)
            makes.append(make)
            makes.sort { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
            makeId = make.id
            modelId = nil
            models = []
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func createModel(displayName: String) async -> Bool {
        guard let makeId else {
            errorMessage = "Select a make before adding a model."
            return false
        }

        do {
            let model = try await vehicleService.createModel(
                makeId: makeId,
                displayName: displayName
            )
            models.append(model)
            models.sort { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
            modelId = model.id
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func save() async -> Vehicle? {
        errorMessage = nil

        let cleanName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanType = vehicleType.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanName.isEmpty else {
            errorMessage = "Display name is required."
            return nil
        }

        guard !cleanType.isEmpty else {
            errorMessage = "Vehicle type is required."
            return nil
        }

        let parsedModelYear: Int?
        if modelYear.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            parsedModelYear = nil
        } else if let year = Int(modelYear), (1886...2100).contains(year) {
            parsedModelYear = year
        } else {
            errorMessage = "Enter a valid model year."
            return nil
        }

        let request = VehicleRequest(
            displayName: cleanName,
            vehicleType: cleanType,
            modelYear: parsedModelYear,
            makeId: makeId,
            modelId: modelId,
            trim: optionalValue(trim),
            color: optionalValue(color),
            vin: optionalValue(vin)?.uppercased()
        )

        isSaving = true
        defer { isSaving = false }

        do {
            if let vehicle {
                return try await vehicleService.update(id: vehicle.id, request: request)
            }
            return try await vehicleService.create(request)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    private func optionalValue(_ value: String) -> String? {
        let cleaned = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? nil : cleaned
    }
}
