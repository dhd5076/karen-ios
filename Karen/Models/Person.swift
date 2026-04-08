//
//  Person.swift
//  Karen
//
//  Created by Dylan Dunn on 3/25/26.
//

import Foundation

struct Person: Codable {
    let id: UUID?
    var firstname: String
    var middlename: String
    var lastname: String
    
    init (
        id: UUID? = nil,
        firstname: String,
        middlename: String,
        lastname: String
    ) {
        self.id = id
        self.firstname = firstname
        self.middlename = middlename
        self.lastname = lastname
    }
}
