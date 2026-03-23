//
//  Model.swift
//  Karen
//
//  Created by Dylan Dunn on 3/3/26.
//

import Foundation

struct Message : Identifiable, Codable {
    let id: UUID?
    let conversationID: UUID
    let content: String
    let role: Role
    let timestamp: Date
    
    init(
        id: UUID? = nil,
        conversationID: UUID,
        content: String,
        role: Role,
        timestamp: Date
    ) {
        self.id = id
        self.conversationID = conversationID
        self.content = content
        self.role = role
        self.timestamp = timestamp
    }
}

enum Role: Codable {
    case user
    case assistant
}
