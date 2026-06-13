//
//  ContentView.swift
//  Karen
//
//  Created by Dylan Dunn on 3/1/26.
//

import SwiftUI
import KarenShared


struct ContentView: View {
    
    private let iconColor: HierarchicalShapeStyle = .primary
    
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
                    //TODO: Pass ChatService
                    ChatView()
                } label: {
                    Label("Chat", systemImage: "message.fill")
                        .foregroundStyle(iconColor)
                }
                NavigationLink {
                    PeopleView()
                } label: {
                    Label("People", systemImage: "person.fill")
                        .foregroundStyle(iconColor)
                }
                NavigationLink {
                    PantryListView()
                } label: {
                    Label(PantryModule.displayName, systemImage: PantryModule.icon)
                        .foregroundStyle(iconColor)
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
