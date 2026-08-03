//
//  AtlasAttributeFormView.swift
//  Karen
//

import SwiftUI

struct AtlasAttributeFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var key: String
    @State private var value: String
    @State private var valueType: String
    @State private var isSaving = false
    @State private var errorMessage: String?

    let isEditing: Bool
    let onSave: (String, String, String) async -> Bool

    init(
        key: String = "",
        value: String = "",
        valueType: String = "string",
        isEditing: Bool = false,
        onSave: @escaping (String, String, String) async -> Bool
    ) {
        self.isEditing = isEditing
        self.onSave = onSave
        _key = State(initialValue: key)
        _value = State(initialValue: value)
        _valueType = State(initialValue: valueType)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Attribute") {
                    TextField("Key", text: $key)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .disabled(isEditing)

                    TextField("Value Type", text: $valueType)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    attributeValueEditor
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Attribute" : "Add Attribute")
            .navigationBarTitleDisplayMode(.inline)
            .disabled(isSaving)
            .overlay {
                if isSaving {
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
                        Task { await save() }
                    }
                    .disabled(isSaving)
                }
            }
        }
    }

    @ViewBuilder
    private var attributeValueEditor: some View {
        switch valueType.lowercased() {
        case "bool", "boolean":
            Toggle("Value", isOn: booleanValue)
        default:
            TextField("Value", text: $value)
                .keyboardType(valueKeyboardType)
        }
    }

    private var booleanValue: Binding<Bool> {
        Binding {
            value.lowercased() == "true"
        } set: { newValue in
            value = newValue ? "true" : "false"
        }
    }

    private var valueKeyboardType: UIKeyboardType {
        switch valueType.lowercased() {
        case "int", "integer":
            return .numberPad
        case "double", "decimal", "number":
            return .decimalPad
        default:
            return .default
        }
    }

    private func save() async {
        let cleanedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedType = valueType.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedKey.isEmpty else {
            errorMessage = "Attribute key is required."
            return
        }
        guard !cleanedType.isEmpty else {
            errorMessage = "Value type is required."
            return
        }

        isSaving = true
        errorMessage = nil
        if await onSave(cleanedKey, value, cleanedType) {
            dismiss()
        } else {
            errorMessage = "Unable to save the attribute."
        }
        isSaving = false
    }
}
