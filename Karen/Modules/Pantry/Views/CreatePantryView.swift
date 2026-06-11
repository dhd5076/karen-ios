//
//  CreatePantryView.swift
//  Karen
//
//  Created by Dylan Dunn on 6/11/26.
//

import SwiftUI
import KarenShared

struct CreatePantryView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var isCreating = false
    
    let onCreate: (Pantry) async throws -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Pantry") {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                }
            }
            .navigationTitle("New Pantry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isCreating)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await createPantry()
                        }
                    } label: {
                        if isCreating {
                            ProgressView()
                        } else {
                            Text("Create")
                        }
                    }
                    .disabled(trimmedName.isEmpty || isCreating)
                }
            }
        }
    }
    
    private func createPantry() async {
        isCreating = true
        
        do {
            let pantry = Pantry(name: trimmedName)
            try await onCreate(pantry)
            dismiss()
        } catch {
            //TODO: Handle Error
        }
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}


#Preview {
    ContentView()
}
