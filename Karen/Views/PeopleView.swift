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
    
    init(peopleService: PeopleService) {
        _peopleViewModel = StateObject(
            wrappedValue: PeopleViewModel(peopleService: peopleService)
        )
    }
    
    var body: some View {
        NavigationStack {
            List(peopleViewModel.people, id: \.id) { person in
                Text(person.firstname + " " + person.lastname)
            }
            .navigationTitle("People")
            .searchable(text: $peopleViewModel.searchText, prompt: "Search People")
            .onSubmit(of: .search) {
                Task {
                    await peopleViewModel.searchByName()
                }
            }
        }
    }
}

#Preview {
    PeopleView(
        peopleService: PeopleService(api: APIService())
    )
}
