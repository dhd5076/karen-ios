//
//  PantryListView.swift
//  Karen
//
//  Created by Dylan Dunn on 6/7/26.
//

import SwiftUI
import KarenShared

struct PantryListView: View {
    @StateObject private var pantryViewModel = PantryViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if pantryViewModel.isLoading {
                    ProgressView("Loading Pantries...")
                } else if pantryViewModel.pantries.isEmpty {
                    ContentUnavailableView(
                        "No Pantries",
                        image: "shippingbox",
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
    }
}

#Preview {
    PantryListView()
}
