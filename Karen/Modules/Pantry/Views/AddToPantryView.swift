//
//  AddToPantryView.swift
//  Karen
//
//  Created by Dylan Dunn on 6/13/26.
//

import SwiftUI
import KarenShared

struct AddToPantryView: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: AddToPantryViewModel
    
    let onAdded: () async -> Void
    
    init(pantryId: UUID, onAdded: @escaping () async -> Void) {
        _viewModel = StateObject(
            wrappedValue: AddToPantryViewModel(pantryId: pantryId)
        )
        self.onAdded = onAdded
    }
    
    var body: some View {
        NavigationStack {
            Form {
                if viewModel.isLoading {
                    ProgressView("Loading Products...")
                } else {
                    Section("Product") {
                        Picker("Product", selection: $viewModel.productId) {
                            ForEach(viewModel.products, id: \.id) { product in
                                if let productId = product.id {
                                    Text(product.name)
                                        .tag(productId as UUID?)
                                }
                            }
                        }
                    }
                }
                
                Section("Batch") {
                    LabeledContent("Quantity") {
                        TextField("0", value: $viewModel.quantity, format: .number) //TODO: Abstract or create reusable form elements like this??
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    TextField("Source", text: $viewModel.source)
                    
                    DatePicker(
                        "Acquired",
                        selection: $viewModel.acquiredAt,
                        displayedComponents: .date
                    )
                }
                
                Section("Note") {
                    TextField("Optional", text: $viewModel.note, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Add Item")
            .task {
                await viewModel.loadProducts()
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
                            let didSave = await viewModel.addToPantry()
                            
                            if didSave {
                                await onAdded()
                                dismiss()
                            }
                        }
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
    
    private var canSave: Bool {
        viewModel.productId != nil &&
        viewModel.quantity > 0 &&
        !viewModel.source.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
