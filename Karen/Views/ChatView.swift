//
//  ChatView.swift
//  Karen
//
//  Created by Dylan Dunn on 3/3/26.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var inputContent: String = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(viewModel.messages) { message in
                    MessageView(message: message);
                }
            }
            
            TextField("Ask Anything", text: $inputContent, axis: .vertical)
                .lineLimit(1...5)
                .focused($isInputFocused)
                .padding()
                .glassEffect(.regular, in: .rect(cornerRadius: 12))
                .overlay(alignment: .trailing) {
                    Button {
                        isInputFocused = false
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.largeTitle)
                    }
                    .glassEffect()
                    .tint(.white)
                    .padding()
                }
                .padding()
        }
        .background(.black)
    }
}

#Preview {
    ChatView()
}
