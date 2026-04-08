//
//  EditPersonView.swift
//  Karen
//
//  Created by Dylan Dunn on 4/8/26.
//

import SwiftUI

struct EditPersonView: View {
    @ObservedObject var peopleViewModel: PeopleViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var person: Person
    
    init(peopleViewModel: PeopleViewModel, person: Person) {
        self.peopleViewModel = peopleViewModel
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
                            //TODO: Implement person update endpoint
                        }
                    }
                }
            }
        }
    }
}
