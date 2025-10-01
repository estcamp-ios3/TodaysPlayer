//
//  RegionData.swift
//  TodaysPlayer
//
//  Created by J on 10/1/25.
//

import Foundation

struct RegionData: Codable, Identifiable {
    let id: String
    let name: String
    let parentRegion: String?
    let coordinates: Coordinates
    
    enum CodingKeys: String, CodingKey {
        case id = "regionId"
        case name
        case parentRegion
        case coordinates
    }
}
