//
//  HomeView.swift
//  Karen
//
//  Created by Dylan Dunn on 6/22/26.
//

import SwiftUI
import KarenShared

struct HomeView: View {
    var body: some View {
        List {
            NavigationLink {
                LightListView()
            } label: {
                Label("Lights", systemImage: Light.icon)
            }
        }
        .navigationTitle(HomeModule.displayName)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
