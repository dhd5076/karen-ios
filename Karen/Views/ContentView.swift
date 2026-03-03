//
//  ContentView.swift
//  Karen
//
//  Created by Dylan Dunn on 3/1/26.
//

import SwiftUI


struct ContentView: View {
    @State private var content = ""
    @FocusState private var isInputFocused: Bool
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    MessageView()
                }
            }
            
            TextField("Ask Anything", text: $content, axis: .vertical)
                .lineLimit(1...5)
                .focused($isInputFocused)
                // Reserve space so the text doesn't run under the send button.
                .padding(.trailing, 44)
                .padding()
                .glassEffect(.regular, in: .rect(cornerRadius: 12))
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        isInputFocused = false
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title)
                    }
                    .glassEffect()
                    .tint(.white)
                    .padding(.bottom, 12)
                    .padding(.trailing, 12)
                }
                .padding()
        }
        .background(.black)
    }
}

#Preview {
    ContentView()
}
