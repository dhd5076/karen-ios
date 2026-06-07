//
//  SendChatRequest.swift
//  Karen
//
//  Created by Dylan Dunn on 3/25/26.
//
import Foundation

struct SendChatRequest : Codable {
    let conversationID: UUID
    let content: String
}
