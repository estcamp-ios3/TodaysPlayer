//
//  Apply.swift
//  TodaysPlayer
//
//  Created by J on 10/1/25.
//

import Foundation

struct Apply: Codable, Identifiable {
    let id: String
    let matchId: String
    let applicantId: String
    let applicantDisplayName: String
    let applicantSkillLevel: String?
    let position: String?
    let participantCount: Int
    let message: String?
    let status: String // "pending", "accepted", "rejected", "cancelled"
    let rejectionReason: String?
    let appliedAt: Date
    let processedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "applyId"
        case matchId
        case applicantId
        case applicantDisplayName
        case applicantSkillLevel
        case position
        case participantCount
        case message
        case status
        case rejectionReason
        case appliedAt
        case processedAt
    }
}
