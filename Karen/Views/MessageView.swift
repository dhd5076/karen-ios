//
//  MessageView.swift
//  Karen
//
//  Created by Dylan Dunn on 3/3/26.
//

import SwiftUI

struct MessageView: View(contet: String) {
    var body: some View {
        Text("Test Message")
            .foregroundStyle(.secondary)
            .padding(.top, 12)
    }
}
#Preview {
    MessageView()
}
