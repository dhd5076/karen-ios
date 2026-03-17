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
                Section {
                    NavigationLink {

                    } label: {
                        HStack {
                            Image(systemName: "person.fill")
                                .font(.title2)
                                .padding()
                                .background(.gray)
                                .clipShape(Circle())

                            VStack(alignment: .leading) {
                                Text("Dylan Dunn")
                                    .font(.title2)

                                Text("Manage Account")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                NavigationLink {
                    ChatView()
                } label: {
                    Label("Chat", systemImage: "message.fill")
                        .foregroundStyle(.primary)
                }
            }
            .navigationTitle("Karen")
            .searchable(text: $searchText, prompt: "Search")
        }
    }
}

#Preview {
    ContentView()
}
