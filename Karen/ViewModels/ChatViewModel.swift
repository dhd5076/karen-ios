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
        //TODO:Implement initializer for ChatViewModel,
    }
    
    func sendMessage(content: String) {
        //TODO: implement API Service call
        let newMessage = Message(id: UUID(), content: content, role: .user)
        messages.append(newMessage)
        //TODO: Remove this after testing
        let testReply = Message(id: UUID(), content: newMessage.content, role: .assistant)
        messages.append(testReply)
    }
}
