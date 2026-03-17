//
//  ChatView.swift
//  Karen
//
//  Created by Dylan Dunn on 3/3/26.
//

import SwiftUI

struct ChatView: View {
    @State private var inputText = ""
    @StateObject private var viewModel = ChatViewModel()

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(viewModel.messages) { message in
                        MessageView(message: message)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 0)
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) {
                HStack(alignment: .bottom, spacing: 8) {
                    TextField("Ask Anything", text: $inputText, axis: .vertical)
                        .lineLimit(1...5)
                        .padding()
                        .glassEffect(.regular, in: .rect(cornerRadius: 18))
                    Button {
                        viewModel.sendMessage(content: inputText)
                        inputText = ""
                    } label: {
                        Image(systemName: "arrow.up")
                            .foregroundStyle(.foreground)
                            .bold()
                    }
                    .padding()
                    .glassEffect(.regular, in: .circle)
                }
                .padding()
            }
        }
    }
}

#Preview {
    ChatView()
}
