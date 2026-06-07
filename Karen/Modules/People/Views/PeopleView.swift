//
//  PersonView.swift
//  Karen
//
//  Created by Dylan Dunn on 4/1/26.
//

import SwiftUI
import Foundation

struct PeopleView : View {
    @StateObject private var peopleViewModel: PeopleViewModel
    @State private var showingCreatePerson = false
    
    init(peopleService: PeopleService) {
        _peopleViewModel = StateObject(
            wrappedValue: PeopleViewModel(peopleService: peopleService)
        )
    }
    
    var body: some View {
        NavigationStack {
            List(peopleViewModel.people, id: \.id) { person in
                NavigationLink {
                    PersonView(person: person)
                } label: {
                    Text(person.firstname + " " + person.lastname)
                }
                Text(person.firstname + " " + person.lastname)
            }
            .navigationTitle("People")
            .searchable(text: $peopleViewModel.searchText, prompt: "Search People")
            .onSubmit(of: .search) {
                Task {
                    await peopleViewModel.searchByName()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingCreatePerson = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }.sheet(isPresented: $showingCreatePerson) {
                CreatePersonView(peopleViewModel: peopleViewModel)
            }
        }
    }
}

#Preview {
    PeopleView(
        peopleService: PeopleService(api: APIService())
    )
}
