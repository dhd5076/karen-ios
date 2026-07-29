//
//  VehicleFormView.swift
//  Karen
//
//  Created by Codex on 7/24/26.
//

import KarenShared
import SwiftUI

struct VehicleFormView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: VehicleFormViewModel
    @State private var showingAddMake = false
    @State private var showingAddModel = false

    private let onSaved: (VehicleResponse) -> Void

    init(
        vehicle: VehicleResponse? = nil,
        onSaved: @escaping (VehicleResponse) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: VehicleFormViewModel(vehicle: vehicle))
        self.onSaved = onSaved
    }

    var body: some View {
        Form {
            Section("Vehicle") {
                TextField("Display Name", text: $viewModel.displayName)

                Picker("Type", selection: $viewModel.vehicleType) {
                    ForEach(viewModel.vehicleTypeOptions, id: \.self) { type in
                        Text(type.capitalized).tag(type)
                    }
                }

                TextField("Model Year", text: $viewModel.modelYear)
                    .keyboardType(.numberPad)
            }

            Section("Make and Model") {
                Picker("Make", selection: $viewModel.makeId) {
                    Text("Not specified").tag(nil as UUID?)
                    ForEach(viewModel.makes, id: \.id) { make in
                        Text(make.displayName).tag(make.id as UUID?)
                    }
                }

                Button {
                    showingAddMake = true
                } label: {
                    Label("Add Make", systemImage: "plus")
                }

                Picker("Model", selection: $viewModel.modelId) {
                    Text("Not specified").tag(nil as UUID?)
                    ForEach(viewModel.models, id: \.id) { model in
                        Text(model.displayName).tag(model.id as UUID?)
                    }
                }
                .disabled(viewModel.makeId == nil)

                Button {
                    showingAddModel = true
                } label: {
                    Label("Add Model", systemImage: "plus")
                }
                .disabled(viewModel.makeId == nil)
            }

            Section("Details") {
                TextField("Trim", text: $viewModel.trim)
                TextField("Color", text: $viewModel.color)
                TextField("VIN", text: $viewModel.vin)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(viewModel.isEditing ? "Edit Vehicle" : "Add Vehicle")
        .navigationBarTitleDisplayMode(.inline)
        .disabled(viewModel.isSaving)
        .overlay {
            if viewModel.isLoadingCatalog || viewModel.isSaving {
                ProgressView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        guard let vehicle = await viewModel.save() else { return }
                        onSaved(vehicle)
                        dismiss()
                    }
                }
                .disabled(viewModel.isSaving)
            }
        }
        .task {
            await viewModel.loadCatalog()
        }
        .onChange(of: viewModel.makeId) { oldValue, newValue in
            guard oldValue != newValue else { return }
            Task {
                await viewModel.makeSelectionChanged(to: newValue)
            }
        }
        .sheet(isPresented: $showingAddMake) {
            VehicleCatalogNameView(title: "Add Make", fieldLabel: "Make Name") { name in
                await viewModel.createMake(displayName: name)
            }
        }
        .sheet(isPresented: $showingAddModel) {
            VehicleCatalogNameView(title: "Add Model", fieldLabel: "Model Name") { name in
                await viewModel.createModel(displayName: name)
            }
        }
    }
}

private struct VehicleCatalogNameView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    let title: String
    let fieldLabel: String
    let onSave: (String) async -> Bool

    var body: some View {
        NavigationStack {
            Form {
                TextField(fieldLabel, text: $name)

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .disabled(isSaving)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !cleanedName.isEmpty else {
                                errorMessage = "\(fieldLabel) is required."
                                return
                            }

                            isSaving = true
                            if await onSave(cleanedName) {
                                dismiss()
                            } else {
                                errorMessage = "Unable to save \(fieldLabel.lowercased())."
                            }
                            isSaving = false
                        }
                    }
                    .disabled(isSaving)
                }
            }
        }
    }
}
