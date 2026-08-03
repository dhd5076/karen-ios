//
//  PersonView.swift
//  Karen
//
//  Created by Dylan Dunn on 4/8/26.
//
import SwiftUI
import KarenKit

struct PersonView: View {
    @StateObject private var viewModel: PersonDetailViewModel
    @State private var showingEditPerson = false

    private let onPersonUpdated: (Person) -> Void

    init(
        personId: UUID,
        onPersonUpdated: @escaping (Person) -> Void = { _ in }
    ) {
        _viewModel = StateObject(
            wrappedValue: PersonDetailViewModel(personId: personId)
        )
        self.onPersonUpdated = onPersonUpdated
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.person == nil {
                ProgressView("Loading Person...")
            } else if let person = viewModel.person {
                Form {
                    if let errorMessage = viewModel.errorMessage {
                        Section {
                            Text(errorMessage)
                                .foregroundStyle(.red)
                        }
                    }

                    Section("Name") {
                        LabeledContent("First", value: person.firstName)
                        if let middleName = person.middleName {
                            LabeledContent("Middle", value: middleName)
                        }
                        if let lastName = person.lastName {
                            LabeledContent("Last", value: lastName)
                        }
                    }
                }
                .refreshable {
                    await viewModel.load()
                }
            } else {
                ContentUnavailableView {
                    Label("Unable to Load Person", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(viewModel.errorMessage ?? "The person could not be loaded.")
                } actions: {
                    Button("Try Again") {
                        Task { await viewModel.load() }
                    }
                }
            }
        }
        .navigationTitle(viewModel.person?.displayName ?? "Person")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if viewModel.person != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingEditPerson = true
                    } label: {
                        Label("Edit Person", systemImage: "pencil")
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditPerson) {
            if let person = viewModel.person {
                NavigationStack {
                    PersonFormView(person: person) { updated in
                        viewModel.apply(updated)
                        onPersonUpdated(updated)
                    }
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}
