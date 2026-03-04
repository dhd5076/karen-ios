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
    
    var body: some View {
        HStack {
            if message.role == .assistant {
                Spacer()
                Text("User Message")
                    .padding()
                    .background(.green)
                    .cornerRadius(16)
            }
            if message.role == .user {
                Text("Assistant Message")
                    .padding()
                    .background(.gray)
                    .cornerRadius(16)
                Spacer()
            }
        }
    }
}
#Preview {
    MessageView(message: Message(id: UUID(), content: "Hello World", role: .assistant))
    MessageView(message: Message(id: UUID(), content: "Hello World", role: .user))
}
