//
//  PersonView.swift
//  Karen
//
//  Created by Dylan Dunn on 4/8/26.
//
import SwiftUI

struct PersonView: View {
    @State var person: Person
    
    init(person: Person) {
        self.person = person
    }
    
    var body: some View {
        Form {
            Section("Name") {
                Text(person.firstname)
                Text(person.middlename)
                Text(person.lastname)
            }
        }
        .navigationTitle(person.firstname + " " + person.lastname) //TODO: Should probably make a fullname help function
        .navigationBarTitleDisplayMode(.inline)
    }
}


#Preview {
    PersonView(person: Person(
        firstname: "John",
        middlename: "Doe",
        lastname: "Smith"
    ))
}
