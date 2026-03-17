//
//  KarenApp.swift
//  Karen
//
//  Created by Dylan Dunn on 3/1/26.
//

import SwiftUI

@main
struct KarenApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
