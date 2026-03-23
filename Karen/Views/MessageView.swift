//
//  MessageView.swift
//  Karen
//
//  Created by Dylan Dunn on 3/3/26.
//

import SwiftUI
import Foundation

struct MessageView: View {
    let message: Message
    
    private var isUser: Bool {
            message.role == .user
        }
    
    private var bubbleColor: Color {
        isUser ? .blue : .black
    }
    
    var body: some View {
        HStack() {
            if isUser {
                Spacer(minLength: 40)
            }
            Text(message.content)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(bubbleColor)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            if !isUser {
                Spacer(minLength: 40)
            }
            
        }
    }
}
#Preview {
    MessageView(message: Message(id: UUID(),
                                 conversationID: UUID(),
                                 content: "Hello World",
                                 role: .assistant,
                                 timestamp: Date.now))
    MessageView(message: Message(id: UUID(),
                                 conversationID: UUID(),
                                 content: "Hello World",
                                 role: .user,
                                 timestamp: Date.now))
}
