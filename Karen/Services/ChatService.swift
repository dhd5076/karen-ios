//
//  ChatService.swift
//  Karen
//
//  Created by Dylan Dunn on 3/18/26.
//

import Foundation

final class ChatService {
    private let api: APIService
    
    init(api: APIService) {
        self.api = api
    }
    
    func sendMessage(_ message: Message) async throws {
        
        let sendChatRequest = SendChatRequest(
            conversationID: message.conversationID,
            content: message.content
        )
        
        try await api.post("chat", body: sendChatRequest)
    }
    
    func getConversation(id: String) async throws -> [Message] {
        
        let messages: [Message] = try await api.get("chat/\(id)")
        
        return messages
    }
}
 
