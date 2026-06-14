//
//  CreatePantryProductView.swift
//  Karen
//
//  Created by Dylan Dunn on 6/13/26.
//

import SwiftUI
import KarenShared

struct CreatePantryProductView: View {
    @Environment(\.dismiss) private var dismiss
    
    let onCreate: (PantryProduct) async -> Void
    
    @State private var name = ""
    @State private var unit = ""
    @State private var proteinPerUnit = 0.0
    @State private var carbsPerUnit = 0.0
    @State private var fatPerUnit = 0.0
    @State private var shelfLife = 0
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Product") {
                    TextField("Name", text: $name)
                    TextField("Unit", text: $unit)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                
                Section("Nutrition Information") {
                    LabeledContent("Protein") {
                        HStack {
                            TextField("0", value: $proteinPerUnit, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                            
                            Text("g")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    LabeledContent("Carbs") {
                        HStack {
                            TextField("0", value: $carbsPerUnit, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                            Text("g")
                                .foregroundStyle(.secondary)
                        }
                    }
                    LabeledContent("Fat") {
                        HStack {
                            TextField("0", value: $fatPerUnit, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                            Text("g")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Section("Storage") {
                    LabeledContent("Shelf Life") {
                        HStack {
                            TextField("0", value: $shelfLife, format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                            Text("days")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Create Product")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            let product = PantryProduct(
                                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                                unit: unit.trimmingCharacters(in: .whitespacesAndNewlines),
                                proteinPerUnit: proteinPerUnit,
                                carbsPerUnit: carbsPerUnit,
                                fatPerUnit: fatPerUnit,
                                shelfLife: shelfLife
                            )
                            
                            await onCreate(product)
                            dismiss()
                        }
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
    
    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !unit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty //TODO: perhaps make a helper function for trimming/whitespace
    }
}

#Preview {
    CreatePantryProductView { product in
        print(product)
    }
}
