//
//  ChatViewModel.swift
//  Karen
//
//  Created by Dylan Dunn on 3/3/26.
//

import SwiftUI
import Combine
import Foundation

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    
    init() {
        //TODO:Implement initializer for ChatViewModel,fetch message from api to populate array with recent messages
    }
    
    func sendMessage(content: String) {
        //TODO: implement API Service call
        let newMessage = Message(id: UUID(),
                                 conversationID: UUID(),
                                 content: content,
                                 role: .user,
                                 timestamp: Date.now)
        messages.append(newMessage)
        //TODO: Remove this after testing
        let testReply = Message(id: UUID(),
                                conversationID: UUID(),
                                content: newMessage.content,
                                role: .assistant,
                                timestamp: Date.now)
        messages.append(testReply)
    }
}
