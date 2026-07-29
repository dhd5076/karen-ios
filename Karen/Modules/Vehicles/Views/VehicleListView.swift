//
//  VehicleListView.swift
//  Karen
//
//  Created by Codex on 7/24/26.
//

import KarenShared
import SwiftUI

struct VehicleListView: View {
    @StateObject private var viewModel = VehicleListViewModel()
    @State private var showingCreateVehicle = false

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.vehicles.isEmpty {
                ProgressView("Loading Vehicles...")
            } else if let errorMessage = viewModel.errorMessage, viewModel.vehicles.isEmpty {
                ContentUnavailableView {
                    Label("Unable to Load Vehicles", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("Try Again") {
                        Task {
                            await viewModel.load()
                        }
                    }
                }
            } else if viewModel.vehicles.isEmpty {
                ContentUnavailableView(
                    "No Vehicles",
                    systemImage: VehicleModule.icon,
                    description: Text("Add a vehicle to get started")
                )
            } else {
                List {
                    if let errorMessage = viewModel.errorMessage {
                        Section {
                            Text(errorMessage)
                                .foregroundStyle(.red)
                        }
                    }

                    ForEach(viewModel.vehicles, id: \.id) { vehicle in
                        NavigationLink {
                            VehicleDetailView(vehicleId: vehicle.id) { updatedVehicle in
                                viewModel.upsert(updatedVehicle)
                            }
                        } label: {
                            VehicleRowView(vehicle: vehicle)
                        }
                    }
                }
                .refreshable {
                    await viewModel.load()
                }
            }
        }
        .navigationTitle(VehicleModule.displayName)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingCreateVehicle = true
                } label: {
                    Label("Add Vehicle", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingCreateVehicle) {
            NavigationStack {
                VehicleFormView { vehicle in
                    viewModel.upsert(vehicle)
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

private struct VehicleRowView: View {
    let vehicle: Vehicle

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(vehicle.displayName)
                .font(.headline)

            if !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(vehicle.vehicleType.capitalized)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }

    private var description: String {
        [
            vehicle.modelYear.map(String.init),
            vehicle.make?.displayName,
            vehicle.model?.displayName
        ]
        .compactMap { $0 }
        .joined(separator: " ")
    }
}

#Preview {
    NavigationStack {
        VehicleListView()
    }
}
