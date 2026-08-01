//
//  KarenClientProvider.swift
//  Karen
//
//  Created by Codex on 7/28/26.
//

import Foundation
import KarenKit

enum KarenClientProvider {
    static let shared: KarenClient = {
        guard let baseURL = URL(string: "https://api.dylandunn.me") else {
            preconditionFailure("Karen backend URL is invalid")
        }

        return KarenClient(
            baseURL: baseURL,
            applicationToken: ""
        )
    }()
}
