//
//  Favorite.swift
//  TodaysPlayer
//
//  Created by J on 10/1/25.
//

import Foundation

struct Favorite: Codable, Identifiable {
    let id: String
    let userId: String
    let matchId: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "favoriteId"
        case userId
        case matchId
        case createdAt
    }
}
