//
//  AtlasView.swift
//  Karen
//

import KarenKit
import SwiftUI

struct AtlasView: View {
    @StateObject private var viewModel = AtlasViewModel()
    @State private var searchText = ""
    @State private var selectedType: EntityType?
    @State private var showingCreateEntity = false

    private var filteredEntities: [AtlasEntity] {
        viewModel.entities.filter { entity in
            let matchesType = selectedType == nil || entity.type == selectedType
            let matchesSearch = searchText.isEmpty ||
                entity.displayName.localizedCaseInsensitiveContains(searchText) ||
                entity.type.rawValue.localizedCaseInsensitiveContains(searchText)
            return matchesType && matchesSearch
        }
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.entities.isEmpty {
                ProgressView("Loading Atlas...")
            } else if let errorMessage = viewModel.errorMessage, viewModel.entities.isEmpty {
                ContentUnavailableView {
                    Label("Unable to Load Atlas", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("Try Again") {
                        Task { await viewModel.load() }
                    }
                }
            } else if viewModel.entities.isEmpty {
                ContentUnavailableView(
                    "No Entities",
                    systemImage: AtlasModule.icon,
                    description: Text("Create an entity to begin building the world model")
                )
            } else {
                entityList
            }
        }
        .navigationTitle(AtlasModule.displayName)
        .searchable(text: $searchText, prompt: "Search entities")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Menu {
                    Button("All Types") {
                        selectedType = nil
                    }

                    ForEach(viewModel.entityTypes, id: \.self) { type in
                        Button(atlasDisplayName(type.rawValue)) {
                            selectedType = type
                        }
                    }
                } label: {
                    Image(systemName: selectedType == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                }
                .accessibilityLabel("Filter Entity Type")

                Button {
                    showingCreateEntity = true
                } label: {
                    Label("Add Entity", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingCreateEntity) {
            NavigationStack {
                AtlasEntityFormView(
                    title: "Add Entity",
                    suggestedTypes: viewModel.entityTypes.map(\.rawValue)
                ) { type, displayName in
                    await viewModel.createEntity(type: type, displayName: displayName) != nil
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }

    private var entityList: some View {
        List {
            if let selectedType {
                Section {
                    LabeledContent("Filtered by", value: atlasDisplayName(selectedType.rawValue))
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            if filteredEntities.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                ForEach(filteredEntities) { entity in
                    NavigationLink {
                        AtlasEntityDetailView(entityId: entity.id) { updated in
                            viewModel.upsert(updated)
                        }
                    } label: {
                        AtlasEntityRow(entity: entity)
                    }
                }
            }
        }
        .refreshable {
            await viewModel.load()
        }
    }
}

struct AtlasEntityRow: View {
    let entity: AtlasEntity

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 3) {
                Text(entity.displayName)
                    .font(.headline)
                Text(atlasDisplayName(entity.type.rawValue))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: atlasIcon(for: entity.type))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

func atlasDisplayName(_ identifier: String) -> String {
    identifier
        .replacingOccurrences(of: "_", with: " ")
        .replacingOccurrences(of: "-", with: " ")
        .split(separator: " ")
        .map { $0.prefix(1).uppercased() + $0.dropFirst() }
        .joined(separator: " ")
}

func atlasIcon(for type: EntityType) -> String {
    switch type {
    case .vehicle:
        return VehicleModule.icon
    case .vehicleMake, .vehicleModel:
        return "building.2"
    case .licensePlate:
        return "rectangle.and.text.magnifyingglass"
    case .product:
        return "shippingbox"
    default:
        return AtlasModule.icon
    }
}
