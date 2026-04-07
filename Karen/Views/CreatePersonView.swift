//
//  CreatePersonView.swift
//  Karen
//
//  Created by Dylan Dunn on 4/7/26.
//

import SwiftUI

struct CreatePersonView: View {
    @ObservedObject var peopleViewModel: PeopleViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var firstName = ""
    @State private var middleName = ""
    @State private var lastName = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("First Name", text: $firstName)
                        .textInputAutocapitalization(.words)
                    TextField("Middle Name", text: $middleName)
                        .textInputAutocapitalization(.words)
                    TextField("Last Name", text: $lastName)
                        .textInputAutocapitalization(.words)
                }
            }
            .navigationTitle("New Person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        Task {
                            //TODO: Implement Saving Person
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    CreatePersonView(
        peopleViewModel: PeopleViewModel(
            peopleService: PeopleService(
                api: APIService()
            )
        )
    )
}
