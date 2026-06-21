//
//  PantryListView.swift
//  Karen
//
//  Created by Dylan Dunn on 6/7/26.
//

import SwiftUI
import KarenShared

struct PantryListView: View {
    @StateObject private var viewModel = PantryListViewModel()
    @State private var showingCreatePantry = false
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading Pantries...")
                } else if viewModel.pantries.isEmpty {
                    ContentUnavailableView(
                        "No Pantries",
                        systemImage: Pantry.icon,
                        description: Text("Create a pantry to get started")
                    )
                } else {
                    List {
                        
                        PantrySummaryView(overview: viewModel.overview)
                        Section() {
                            ForEach(viewModel.pantries, id: \.id) { pantry in
                                NavigationLink {
                                    PantryView(pantryID: pantry.id!) //TODO: This is a forced unwrap, double check
                                } label: {
                                    Text(pantry.name)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        Task {
                                            if let pantryId = pantry.id {
                                                await viewModel.deletePantry(id: pantryId)
                                            }
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        } header: {
                            HStack {
                                Text("Pantries")
                                Spacer()
                                Text("\(viewModel.pantries.count)")
                            }
                        }
                    }
                    .refreshable {
                        await viewModel.load()
                    }
                }
            }
        }
        .navigationTitle("Pantries")
        .task {
            await viewModel.load()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showingCreatePantry = true
                    } label: {
                        Label("Create Pantry", systemImage: "plus")
                    }
                    
                    NavigationLink {
                        PantryProductListView()
                    } label: {
                        Label("Manage Products", systemImage: "tag")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingCreatePantry) {
            CreatePantryView(onCreate: createPantry)
        }
    }
    
    private func createPantry(pantry: Pantry) async{
        await viewModel.createPantry(pantry)
    }
}

#Preview {
        ContentView()
}
