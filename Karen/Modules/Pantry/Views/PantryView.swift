//
//  ViewPantryView.swift
//  Karen
//
//  Created by Dylan Dunn on 6/12/26.
// TODO: Implement editing view
import KarenShared
import Foundation
import SwiftUI

struct ViewPantryView: View {
    
    @StateObject private var viewPantryViewModel: ViewPantryViewModel
    
    init(pantryID: UUID) {
        _viewPantryViewModel = StateObject(
            wrappedValue: ViewPantryViewModel(pantryID: pantryID)
        )
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if viewPantryViewModel.isLoading {
                ProgressView()
            } else if let pantry = viewPantryViewModel.pantry {
                Text(pantry.name)
                    .font(.title)
            } else if let errorMessage = viewPantryViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red) //TODO: Make a reusable ErrorView: View
            }
        }
        .padding()
        .task {
            await viewPantryViewModel.loadPantry()
        }
    }
}


#Preview {
    ContentView()
}
