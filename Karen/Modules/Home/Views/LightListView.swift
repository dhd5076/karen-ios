//
//  LightListView.swift
//  Karen
//
//  Created by Dylan Dunn on 6/22/26.
//

import SwiftUI
import KarenShared

struct LightListView: View {
    
    @StateObject private var viewModel = LightListViewModel()
    
    var body: some View {
        List {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
            
            ForEach(viewModel.lights, id: \.id) { light in
                lightRow(light)
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView("Loading Lights...")
            }
        }
        .navigationTitle("Lights")
        .refreshable {
            await viewModel.load()
        }
        .task {
            await viewModel.load()
        }
    }
    
    private func lightRow(_ light: Light) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(light.name)
                    .font(.headline)
                
                if let brightness = light.brightness {
                    Text("Brightness \(brightness, specifier: "%.0f")%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Toggle(
                "Power",
                isOn: Binding(
                    get: { light.isOn },
                    set: { isOn in
                        Task {
                            await viewModel.setPower(id: light.id, isOn: isOn)
                        }
                    }
                )
            )
            .labelsHidden()
        }
    }
}

#Preview {
    NavigationStack {
        LightListView()
    }
}
