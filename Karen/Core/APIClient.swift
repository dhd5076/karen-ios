//
//  APIService.swift
//  Karen
//
//  Created by Dylan Dunn on 3/17/26.
//

import Foundation

final class APIClient {
    private let baseURL = URL(string: "http://192.168.1.183:8080")!

    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    //Make singleton
    static let shared = APIClient()
    private init() {
        
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }
    //TODO: Organize in order of CRUD, functions
    
    func put<Body: Encodable, Response: Decodable>(_ path: String, body: Body) async throws -> Response {
        let url = baseURL.appendingPathComponent(path)
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer SECRET", forHTTPHeaderField: "Authorization")
        request.httpBody = try encoder.encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        return try decoder.decode(Response.self, from: data)
    }
    
    func delete(_ path: String) async throws {
        let url = baseURL.appendingPathComponent(path)
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        //TODO: The following is repetitive, I should consider refactoring into helper function
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer SECRET", forHTTPHeaderField: "Authorization")
        
        let(data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
    }
    
    func post<Body: Encodable, Response: Decodable>(_ path: String, body: Body) async throws -> Response {
        let url = baseURL.appendingPathComponent(path)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer SECRET", forHTTPHeaderField: "Authorization")
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            //print("POST \(path) failed with status \(httpResponse.statusCode): \(String(data: data, encoding: .utf8) ?? "")") //TODO: Needs better error handling in this function
            throw URLError(.badServerResponse)
        }
        
        
        return try decoder.decode(Response.self, from: data)
    }
    
    func get<Response: Decodable>(_ path: String) async throws -> Response {
        let url = baseURL.appendingPathComponent(path)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer SECRET", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        //TODO: Move to shared decoder?
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        
        return try decoder.decode(Response.self, from: data)
    }
}
