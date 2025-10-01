//
//  Review.swift
//  TodaysPlayer
//
//  Created by J on 10/1/25.
//

import Foundation

struct Review: Codable, Identifiable {
    let id: String
    let matchId: String
    let reviewerId: String
    let revieweeId: String
    let rating: Int // 1-5
    let comment: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "reviewId"
        case matchId
        case reviewerId
        case revieweeId
        case rating
        case comment
        case createdAt
    }
}
