//
//  PantryListView.swift
//  Karen
//
//  Created by Dylan Dunn on 6/7/26.
//

import SwiftUI
import KarenShared

struct PantryView: View {
    @StateObject private var pantryViewModel = PantryViewModel()
    @State private var showingCreatePantry = false
    
    var body: some View {
        NavigationStack {
            Group {
                if pantryViewModel.isLoading {
                    ProgressView("Loading Pantries...")
                } else if pantryViewModel.pantries.isEmpty {
                    ContentUnavailableView(
                        "No Pantries",
                        systemImage: "shippingbox",
                        description: Text("Create a pantry to get started")
                    )
                } else {
                    List(pantryViewModel.pantries, id: \.id) { pantry in
                        Text(pantry.name)
                    }
                    
                    .refreshable {
                        await pantryViewModel.loadPantries()
                    }
                }
            }
        }
        .navigationTitle("Pantries")
        .task {
            await pantryViewModel.loadPantries()
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
        await pantryViewModel.createPantry(pantry)
    }
}

#Preview {
        ContentView()
}
