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
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(viewModel.messages) { message in
                            MessageView(message: message)
                                .id(message.id)
                        }
                    }
                    .onChange(of: viewModel.messages.count, initial: false) {
                        if let last = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 0)
                    
                }
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) {
                TextField("Ask Anything", text: $inputText, axis: .vertical)
                    .lineLimit(1...5)
                    .padding(.leading, 14)
                    .padding(.vertical, 10)
                    .padding(.trailing, 52)
                    .frame(minHeight: 44, alignment: .center)
                    .overlay(alignment: .bottomTrailing) {
                        if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Button {
                                let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                                guard !text.isEmpty else { return }

                                viewModel.sendMessage(content: text)
                                inputText = ""
                            } label: {
                                Image(systemName: "arrow.up")
                                    .foregroundStyle(.white)
                            }
                            .buttonStyle(.glassProminent)
                            .padding(6)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .glassEffect(.regular, in: .rect(cornerRadius: 18))
                    .animation(.easeInOut(duration: 0.15), value: inputText)
                    .padding()
            }
        }
    }
}

#Preview {
    ChatView()
}
