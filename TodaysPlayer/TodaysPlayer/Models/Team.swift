//
//  Team.swift
//  TodaysPlayer
//
//  Created by J on 10/1/25.
//

import Foundation

struct Team: Codable, Identifiable {
    let id: String
    let teamName: String
    let description: String
    let teamImageUrl: String?
    let leaderId: String
    let region: String
    let skillLevel: String
    let createdAt: Date
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "teamId"
        case teamName
        case description
        case teamImageUrl
        case leaderId
        case region
        case skillLevel
        case createdAt
        case isActive
    }
}
