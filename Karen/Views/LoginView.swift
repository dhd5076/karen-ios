//
//  LoginView.swift
//  Karen
//
//  Created by Dylan Dunn on 3/16/26.
//

import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    
    var onLogin: (String, String) -> Void = { _, _ in}
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(colors: [
                        .black, .gray.opacity(0.25)
                    ],
                       startPoint: .top,
                       endPoint: .bottom
                    )
                )
                .ignoresSafeArea()
            VStack() {
                Image(systemName: "lock")
                    .font(.system(size: 48, weight: .semibold))
                    .padding()
                    .background(
                        Circle()
                            .glassEffect(.regular)
                    )
                Text("Welcome Back")
                    .font(.largeTitle)
                Text("Login To Continue")
                    .foregroundStyle(.secondary)
                Spacer()
                VStack(spacing: 24) {
                    TextField("Email", text: $username)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .padding()
                        .glassEffect(.regular)
                    SecureField("Password", text: $password)
                        .padding()
                        .glassEffect(.regular)
                    HStack {
                        Text("Karen v0.1.1")
                            .font(.footnote)
                            .foregroundStyle(.tertiary)
                            .padding()
                        Spacer()
                        Button("Login") {
                            onLogin(username, password)
                        }
                        .controlSize(.large)
                        .buttonStyle(.glassProminent)
                        .tint(.gray)
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    LoginView()
}
