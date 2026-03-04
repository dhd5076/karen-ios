//
//  ChatViewModel.swift
//  Karen
//
//  Created by Dylan Dunn on 3/3/26.
//

import SwiftUI
import Combine
import Foundation

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    
    
    init() {
        messages = [
            Message(id: UUID(), content: "Hello World", role: .user),
            Message(id: UUID(), content: "Hello World", role: .assistant)
        ]
    }
}
