//
//  ContentView.swift
//  Karen
//
//  Created by Dylan Dunn on 3/1/26.
//

import SwiftUI


struct ContentView: View {
    @State private var searchText = ""
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Open Chat") {
                    ChatView()
                }
            }
            .navigationTitle("Conversations")
            .searchable(text: $searchText, prompt: "Search")
        }
    }
}

#Preview {
    ContentView()
}
