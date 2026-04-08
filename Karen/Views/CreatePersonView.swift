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
                            let person = Person(
                                firstname: firstName,
                                middlename: middleName,
                                lastname: lastName
                            )
                            await peopleViewModel.create(person) //Should probably throw
                            //TODO: Don't dimiss on error, show error
                            dismiss()
                            //TODO: Use returned Person model to update our own list instead of hitting db again
                            await peopleViewModel.getAllPeople()
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
