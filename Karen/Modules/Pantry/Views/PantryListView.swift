//
//  PantryListView.swift
//  Karen
//
//  Created by Dylan Dunn on 6/7/26.
//

import SwiftUI
import KarenShared

struct PantryListView: View {
    @StateObject private var pantryListViewModel = PantryListViewModel()
    @State private var showingCreatePantry = false
    
    var body: some View {
        NavigationStack {
            Group {
                if pantryListViewModel.isLoading {
                    ProgressView("Loading Pantries...")
                } else if pantryListViewModel.pantries.isEmpty {
                    ContentUnavailableView(
                        "No Pantries",
                        systemImage: "shippingbox",
                        description: Text("Create a pantry to get started")
                    )
                } else {
                    List(pantryListViewModel.pantries, id: \.id) { pantry in
                        NavigationLink {
                            ViewPantryView(pantryID: pantry.id!) //TODO: This is a forced unwrap, double check
                        } label: {
                            Text(pantry.name)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                Task {
                                    if let pantryId = pantry.id {
                                        await pantryListViewModel.deletePantry(id: pantryId)
                                    }
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .refreshable {
                        await pantryListViewModel.loadPantries()
                    }
                }
            }
        }
        .navigationTitle("Pantries")
        .task {
            await pantryListViewModel.loadPantries()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingCreatePantry = true
                } label: {
                    Label("Create Pantry", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingCreatePantry) {
            CreatePantryView(onCreate: createPantry)
        }
    }
    
    private func createPantry(pantry: Pantry) async{
        await pantryListViewModel.createPantry(pantry)
    }
}

#Preview {
        ContentView()
}
