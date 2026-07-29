//
//  VehicleDetailView.swift
//  Karen
//
//  Created by Codex on 7/24/26.
//

import KarenShared
import SwiftUI

struct VehicleDetailView: View {
    @StateObject private var viewModel: VehicleDetailViewModel
    @State private var showingEditVehicle = false
    @State private var showingAddLicensePlate = false
    @State private var plateToUnassign: VehicleLicensePlateResponse?
    @State private var showingUnassignConfirmation = false

    private let onVehicleUpdated: (VehicleResponse) -> Void

    init(
        vehicleId: UUID,
        onVehicleUpdated: @escaping (VehicleResponse) -> Void = { _ in }
    ) {
        _viewModel = StateObject(wrappedValue: VehicleDetailViewModel(vehicleId: vehicleId))
        self.onVehicleUpdated = onVehicleUpdated
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.vehicle == nil {
                ProgressView("Loading Vehicle...")
            } else if let vehicle = viewModel.vehicle {
                vehicleList(vehicle)
            } else {
                ContentUnavailableView {
                    Label("Unable to Load Vehicle", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(viewModel.errorMessage ?? "The vehicle could not be loaded.")
                } actions: {
                    Button("Try Again") {
                        Task {
                            await viewModel.load()
                        }
                    }
                }
            }
        }
        .navigationTitle(viewModel.vehicle?.displayName ?? "Vehicle")
        .toolbar {
            if let vehicle = viewModel.vehicle {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showingEditVehicle = true
                        } label: {
                            Label("Edit Vehicle", systemImage: "pencil")
                        }

                        Button {
                            showingAddLicensePlate = true
                        } label: {
                            Label("Add License Plate", systemImage: "rectangle.and.pencil.and.ellipsis")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("Vehicle Actions")
                }
            }
        }
        .sheet(isPresented: $showingEditVehicle) {
            if let vehicle = viewModel.vehicle {
                NavigationStack {
                    VehicleFormView(vehicle: vehicle) { updatedVehicle in
                        viewModel.apply(updatedVehicle)
                        onVehicleUpdated(updatedVehicle)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddLicensePlate) {
            AddLicensePlateView { request in
                await viewModel.addLicensePlate(request)
            }
        }
        .alert("Unassign License Plate?", isPresented: $showingUnassignConfirmation) {
            Button("Cancel", role: .cancel) {
                plateToUnassign = nil
            }
            Button("Unassign", role: .destructive) {
                guard let assignment = plateToUnassign else { return }
                Task {
                    await viewModel.unassign(assignment)
                    plateToUnassign = nil
                }
            }
        } message: {
            Text("The plate will remain in this vehicle's registration history.")
        }
        .task {
            await viewModel.load()
        }
    }

    private func vehicleList(_ vehicle: VehicleResponse) -> some View {
        List {
            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            Section("Vehicle") {
                LabeledContent("Name", value: vehicle.displayName)
                LabeledContent("Type", value: vehicle.vehicleType.capitalized)
            }

            if hasSpecifications(vehicle) {
                Section("Specifications") {
                    if let year = vehicle.modelYear {
                        LabeledContent("Model Year", value: String(year))
                    }
                    if let make = vehicle.make {
                        LabeledContent("Make", value: make.displayName)
                    }
                    if let model = vehicle.model {
                        LabeledContent("Model", value: model.displayName)
                    }
                    if let trim = vehicle.trim {
                        LabeledContent("Trim", value: trim)
                    }
                    if let color = vehicle.color {
                        LabeledContent("Color", value: color)
                    }
                }
            }

            if let vin = vehicle.vin {
                Section("Identification") {
                    LabeledContent("VIN", value: vin)
                        .textSelection(.enabled)
                }
            }

            Section("Current License Plate") {
                if viewModel.activePlates.isEmpty {
                    Text("No license plate assigned")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.activePlates, id: \.relationshipId) { assignment in
                        licensePlateRow(assignment, canUnassign: true)
                    }
                }
            }

            if !viewModel.historicalPlates.isEmpty {
                Section("License Plate History") {
                    ForEach(viewModel.historicalPlates, id: \.relationshipId) { assignment in
                        licensePlateRow(assignment, canUnassign: false)
                    }
                }
            }
        }
        .refreshable {
            await viewModel.load()
        }
    }

    private func licensePlateRow(
        _ assignment: VehicleLicensePlateResponse,
        canUnassign: Bool
    ) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(assignment.licensePlate.displayNumber)
                    .font(.headline)

                Text([
                    assignment.licensePlate.jurisdictionCode,
                    assignment.licensePlate.countryCode
                ].joined(separator: ", "))
                .font(.caption)
                .foregroundStyle(.secondary)

                if let validUntil = assignment.validUntil {
                    Text("Ended \(validUntil.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if canUnassign {
                Button(role: .destructive) {
                    plateToUnassign = assignment
                    showingUnassignConfirmation = true
                } label: {
                    Image(systemName: "link.badge.minus")
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("Unassign License Plate")
            }
        }
    }

    private func hasSpecifications(_ vehicle: VehicleResponse) -> Bool {
        vehicle.modelYear != nil ||
            vehicle.make != nil ||
            vehicle.model != nil ||
            vehicle.trim != nil ||
            vehicle.color != nil
    }
}
