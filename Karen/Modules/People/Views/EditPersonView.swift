//
//  EditPersonView.swift
//  Karen
//
//  Created by Dylan Dunn on 4/8/26.
//

import SwiftUI

struct EditPersonView: View {
    let peopleViewModel = PeopleViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var person: Person
    
    init(person: Person) {
        _person = State(initialValue: person)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("First Name", text: $person.firstname)
                        .textInputAutocapitalization(.words)
                    TextField("Middle Name", text: $person.middlename)
                        .textInputAutocapitalization(.words)
                    TextField("Last Name", text: $person.lastname)
                        .textInputAutocapitalization(.words)
                }
            }
            .navigationTitle("Edit Person")
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
                            await peopleViewModel.update(person)
                        }
                    }
                    .bold()
                }
            }
        }
    }
}

#Preview {
    EditPersonView(
        person: Person(
            firstname: "John",
            middlename: "Doe",
            lastname: "Smith"
        )
    )
}
