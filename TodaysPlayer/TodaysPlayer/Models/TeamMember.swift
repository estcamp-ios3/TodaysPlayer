//
//  TeamMember.swift
//  TodaysPlayer
//
//  Created by J on 10/1/25.
//

import Foundation

struct TeamMember: Codable {
    let teamId: String
    let userId: String
    let role: String // "leader", "member", "substitute"
    let joinedAt: Date
    let isActive: Bool
}
