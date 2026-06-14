//
//  ConsumePantryBatchView.swift
//  Karen
//
//  Created by Dylan Dunn on 6/14/26.
//

import SwiftUI
import KarenShared

struct ConsumePantryBatchView: View {
    @Environment(\.dismiss) private var dismiss

    let batch: PantryBatch
    let product: PantryProduct
    let onConsume: (Double, String?) async -> Void

    @State private var quantity = 1.0
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Item") {
                    LabeledContent("Product", value: product.name)
                    LabeledContent("Available", value: "\(batch.quantity.formatted()) \(product.unit)")
                }

                Section("Consume") {
                    LabeledContent("Quantity") {
                        TextField("0", value: $quantity, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }

                    TextField("Note", text: $note, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("Consume")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)

                            await onConsume(
                                quantity,
                                trimmedNote.isEmpty ? nil : trimmedNote
                            )

                            dismiss()
                        }
                    }
                    .disabled(!canSave)
                }
            }
        }
    }

    private var canSave: Bool {
        quantity > 0 && quantity <= batch.quantity
    }
}

#Preview {
    ConsumePantryBatchView(
        batch: PantryBatch(
            id: UUID(),
            pantry: UUID(),
            product: UUID(),
            quantity: 4,
            source: "Preview",
            acquiredAt: Date()
        ),
        product: PantryProduct(
            id: UUID(),
            name: "Rice",
            unit: "lb",
            proteinPerUnit: 0,
            carbsPerUnit: 0,
            fatPerUnit: 0,
            shelfLife: 365
        ),
        onConsume: { _, _ in }
    )
}
