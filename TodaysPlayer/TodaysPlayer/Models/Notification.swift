//
//  Notification.swift
//  TodaysPlayer
//
//  Created by J on 10/1/25.
//

import Foundation

struct Notification: Codable, Identifiable {
    let id: String
    let type: String // "application_received", "application_accepted", "application_rejected", "match_reminder", "match_cancelled"
    let title: String
    let message: String
    let data: [String: String]? // Any 대신 String으로 변경
    let isRead: Bool
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "notificationId"
        case type
        case title
        case message
        case data
        case isRead
        case createdAt
    }
}
