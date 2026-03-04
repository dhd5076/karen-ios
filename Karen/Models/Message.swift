//
//  Model.swift
//  Karen
//
//  Created by Dylan Dunn on 3/3/26.
//

import Foundation

struct Message : Identifiable {
    let id: UUID
    let content: String
    let role: Role
}

enum Role {
    case user
    case assistant
}
