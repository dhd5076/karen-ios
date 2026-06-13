//
//  ViewPantryView.swift
//  Karen
//
//  Created by Dylan Dunn on 6/12/26.
// TODO: Implement editing view
import KarenShared
import Foundation
import SwiftUI

struct PantryView: View {
    
    @StateObject private var pantryViewModel: PantryViewModel
    
    init(pantryID: UUID) {
        _pantryViewModel = StateObject(
            wrappedValue: PantryViewModel(pantryID: pantryID)
        )
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if pantryViewModel.isLoading {
                ProgressView()
            } else if let pantry = pantryViewModel.pantry {
                Text(pantry.name)
                    .font(.title)
            } else if let errorMessage = pantryViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red) //TODO: Make a reusable ErrorView: View
            }
        }
        .padding()
        .task {
            await pantryViewModel.loadPantry()
        }
    }
}


#Preview {
    ContentView()
}
