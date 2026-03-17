//
//  Location.swift
//  Karen
//
//  Created by Dylan Dunn on 3/17/26.
//
import Foundation

struct Location: Codable {
    var id: UUID?
    var type: String
    var latitude: Double
    var longitude: Double
    var recordedAt: Date
    var metadata: [String: String]
    
    init(
        id: UUID? = nil,
        type: String,
        latitude: Double,
        longitude: Double,
        recordedAt: Date,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.type = type
        self.latitude = latitude
        self.longitude = longitude
        self.recordedAt = recordedAt
        self.metadata = metadata
    }
}
