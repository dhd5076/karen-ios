//
//  ChatService.swift
//  Karen
//
//  Created by Dylan Dunn on 3/18/26.
//

import Foundation

final class ChatService {
    private let apiClient: APIClient
    
    static let shared = ChatService()
    
    private init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func sendMessage(_ message: Message) async throws -> Message {
        
        let sendChatRequest = SendChatRequest(
            conversationID: message.conversationID,
            content: message.content
        )
        
        return try await apiClient.post("chat", body: sendChatRequest)
    }
    
    func getConversation(id: String) async throws -> [Message] {
        
        let messages: [Message] = try await apiClient.get("chat/\(id)")
        
        return messages
    }
}
 
