//
//  ViewPantryView.swift
//  Karen
//
//  Created by Dylan Dunn on 6/12/26.
// TODO: Implement editing view
import KarenShared
import Foundation
import SwiftUI

struct PantryView: View {
    @StateObject private var viewModel: PantryViewModel
    @State private var showingAddToPantry = false

    init(pantryID: UUID) {
        _viewModel = StateObject(
            wrappedValue: PantryViewModel(pantryID: pantryID)
        )
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let pantry = viewModel.pantry {
                List {
                    Section("Pantry") {
                        Label(pantry.name, systemImage: Pantry.icon)
                    }

                    Section("Inventory") {
                        if viewModel.batches.isEmpty {
                            ContentUnavailableView(
                                "No Items",
                                systemImage: PantryBatch.icon,
                                description: Text("Add an item to this pantry")
                            )
                        } else {
                            ForEach(viewModel.batches, id: \.id) { batch in
                                VStack(alignment: .leading) {
                                    Text(viewModel.productName(for: batch.product))
                                        .font(.headline)
                                    
                                    Text("\(batch.quantity.formatted()) from \(batch.source)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    
                                    Text(batch.acquiredAt.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        Task {
                                            if let batchId = batch.id {
                                                //TODO: This is possibly an issue, we may never want to delete batches 
                                                await viewModel.deleteBatch(id: batchId)
                                            }
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            } else {
                ProgressView("Loading Pantry")
            }
        }
        .navigationTitle(viewModel.pantry?.name ?? "Pantry")
        .task {
            await viewModel.loadPantry()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddToPantry = true
                } label: {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddToPantry) {
            AddToPantryView(
                pantryId: viewModel.pantryID,
                onAdded: {
                    await viewModel.loadPantry()
                }
            )
        }
    }
}

#Preview {
    ContentView()
}
