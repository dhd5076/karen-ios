//
//  LightListView.swift
//  Karen
//
//  Created by Dylan Dunn on 6/22/26.
//

import SwiftUI
import KarenShared

struct LightListView: View {
    
    @StateObject private var viewModel: LightListViewModel
    
    //TODO: This is probably wrong, something else is wrong even though this fixes protection level issues
    init() {
        _viewModel = StateObject(wrappedValue: LightListViewModel())
    }
    
    init(viewModel: @autoclosure @escaping () -> LightListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }
    
    var body: some View {
        NavigationStack {
            List {
                if viewModel.errorMessage != nil {
                    Text(viewModel.errorMessage!)
                }
                ForEach(viewModel.lights, id: \.id) { light in
                    Text(light.name)
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}
#Preview {
    LightListView()
}
