//
//  PantryProductListView.swift
//  Karen
//
//  Created by Dylan Dunn on 6/13/26.
//

import SwiftUI
import KarenShared

struct PantryProductListView: View {
    @StateObject private var viewModel = PantryProductListViewModel()
    @State private var showingCreateProduct = false
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading Products")
            } else if viewModel.products.isEmpty {
                ContentUnavailableView(
                    "No Products",
                    systemImage: PantryProduct.icon,
                    description: Text("Create a product to get started")
                )
            } else {
                List(viewModel.filteredProducts, id: \.id) { product in
                    VStack(alignment: .leading) {
                        Text(product.name)
                            .font(.headline)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            Task {
                                if let productId = product.id {
                                    await viewModel.deleteProduct(id: productId)
                                }
                            }
                        } label: {
                            Label("Delete", systemImage: "trash") //TODO: Replace with AppIcon.delete eventually
                        }
                    }
                }
                .refreshable {
                    await viewModel.loadProducts()
                }
            }
        }
        .navigationTitle("Products")
        .task {
            await viewModel.loadProducts()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingCreateProduct = true
                } label: {
                    Label("Create Product", systemImage: "plus") //TODO: Replace with AppIcon.add eventually
                }
            }
        }
        .sheet(isPresented: $showingCreateProduct) {
            CreatePantryProductView(onCreate: createProduct)
        }
        .searchable(text: $viewModel.searchText, prompt: "Search Products")
    }
    
    private func createProduct(_ product: PantryProduct) async {
        await viewModel.createProduct(product)
    }
}

#Preview {
    NavigationStack {
        PantryProductListView()
    }
}

