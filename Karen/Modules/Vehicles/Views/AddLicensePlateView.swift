//
//  AddLicensePlateView.swift
//  Karen
//
//  Created by Codex on 7/24/26.
//

import Foundation
import KarenShared
import SwiftUI

struct AddLicensePlateView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var displayNumber = ""
    @State private var jurisdictionCode = ""
    @State private var countryCode = "US"
    @State private var specifiesEffectiveDate = false
    @State private var effectiveDate = Date()
    @State private var isSaving = false
    @State private var errorMessage: String?

    let onSave: (LicensePlateRequest) async -> String?

    var body: some View {
        NavigationStack {
            Form {
                Section("License Plate") {
                    TextField("Plate Number", text: $displayNumber)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()

                    TextField("State or Province", text: $jurisdictionCode)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()

                    TextField("Country Code", text: $countryCode)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                }

                Section("Assignment") {
                    Toggle("Specify Effective Date", isOn: $specifiesEffectiveDate)
                    if specifiesEffectiveDate {
                        DatePicker(
                            "Effective Date",
                            selection: $effectiveDate,
                            displayedComponents: .date
                        )
                    }
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Add License Plate")
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
                            await save()
                        }
                    }
                    .disabled(isSaving)
                }
            }
        }
    }

    private func save() async {
        let number = displayNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        let jurisdiction = jurisdictionCode.trimmingCharacters(in: .whitespacesAndNewlines)
        let country = countryCode.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !number.isEmpty, !jurisdiction.isEmpty, !country.isEmpty else {
            errorMessage = "Plate number, jurisdiction, and country are required."
            return
        }

        isSaving = true
        let request = LicensePlateRequest(
            displayNumber: number,
            jurisdictionCode: jurisdiction.uppercased(),
            countryCode: country.uppercased(),
            validFrom: specifiesEffectiveDate ? effectiveDate : nil
        )

        if let saveError = await onSave(request) {
            errorMessage = saveError
        } else {
            dismiss()
        }
        isSaving = false
    }
}
