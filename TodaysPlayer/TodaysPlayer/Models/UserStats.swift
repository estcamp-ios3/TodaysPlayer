//
//  UserStats.swift
//  TodaysPlayer
//
//  Created by J on 10/1/25.
//

import Foundation

struct UserStats: Codable {
    let userId: String
    let totalGames: Int
    let averageRating: Double
    let reviewCount: Int
    let lastUpdated: Date
}
