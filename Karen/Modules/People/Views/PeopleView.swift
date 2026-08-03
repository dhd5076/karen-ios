//
//  PersonView.swift
//  Karen
//
//  Created by Dylan Dunn on 4/1/26.
//

import Foundation
import KarenKit
import SwiftUI

struct PeopleView: View {
    @StateObject private var viewModel = PeopleViewModel()
    @State private var showingCreatePerson = false

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.people.isEmpty {
                ProgressView("Loading People...")
            } else if let errorMessage = viewModel.errorMessage, viewModel.people.isEmpty {
                ContentUnavailableView {
                    Label("Unable to Load People", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("Try Again") {
                        Task { await viewModel.load() }
                    }
                }
            } else if viewModel.people.isEmpty {
                ContentUnavailableView(
                    "No People",
                    systemImage: PeopleModule.icon,
                    description: Text("Add a person to get started")
                )
            } else {
                List {
                    if let errorMessage = viewModel.errorMessage {
                        Section {
                            Text(errorMessage)
                                .foregroundStyle(.red)
                        }
                    }

                    if viewModel.filteredPeople.isEmpty {
                        ContentUnavailableView.search(text: viewModel.searchText)
                    } else {
                        ForEach(viewModel.filteredPeople) { person in
                            NavigationLink {
                                PersonView(personId: person.id) { updated in
                                    viewModel.upsert(updated)
                                }
                            } label: {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(person.displayName)
                                        .font(.headline)
                                    Text("Person")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                .refreshable {
                    await viewModel.load()
                }
            }
        }
        .navigationTitle(PeopleModule.displayName)
        .searchable(text: $viewModel.searchText, prompt: "Search People")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingCreatePerson = true
                } label: {
                    Label("Add Person", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingCreatePerson) {
            NavigationStack {
                PersonFormView { person in
                    viewModel.upsert(person)
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

#Preview {
    PeopleView()
}
