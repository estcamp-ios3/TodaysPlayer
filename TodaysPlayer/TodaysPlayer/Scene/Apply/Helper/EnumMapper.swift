//
//  EnumMapper.swift
//  TodaysPlayer
//
//  Created by 권소정 on 10/25/25.
//

import Foundation

struct EnumMapper {
    // MARK: - enum 값 ↔ Firebase 필드값 매핑
    // 필터에서 스킬레벨 정의한거 매핑하려고 필요함
    /// SkillLevel enum → Firebase 필드값 변환
    static func skillLevel(_ skillLevel: SkillLevel) -> String {
        switch skillLevel {
        case .expert: return "expert"
        case .advanced: return "advanced"
        case .intermediate: return "intermediate"
        case .beginner: return "beginner"
        }
    }
    // 성별 매핑
    /// Gender enum → Firebase 필드값 변환
    static func gender(_ gender: Gender) -> String {
        switch gender {
        case .male: return "male"
        case .female: return "female"
        }
    }
    // 경기 종류 매핑
    /// MatchType enum → Firebase 필드값 변환
    static func matchType(_ matchType: MatchType) -> String {
        switch matchType {
        case .futsal: return "futsal"
        case .soccer: return "soccer"
        }
    }
    
    // MARK: - 주소에서 지역 추출
    // 주소에서 지역 추출하는 서울이라는 글자가 포함되면 seoul로 리턴하는것처럼
    /// 주소 문자열에서 Region enum 추출
    static func extractRegion(from address: String) -> Region? {
        if address.contains("서울") {
            return .seoul
        }
        if address.contains("경기") {
            return .gyeonggi
        }
        if address.contains("인천") {
            return .incheon
        }
        if address.contains("강원") {
            return .gangwon
        }
        if address.contains("대전") || address.contains("세종") {
            return .daejeonSejong
        }
        if address.contains("충북") || address.contains("충청북도") {
            return .chungbuk
        }
        if address.contains("충남") || address.contains("충청남도") {
            return .chungnam
        }
        if address.contains("대구") {
            return .daegu
        }
        if address.contains("부산") {
            return .busan
        }
        if address.contains("울산") {
            return .ulsan
        }
        if address.contains("경북") || address.contains("경상북도") {
            return .gyeongbuk
        }
        if address.contains("경남") || address.contains("경상남도") {
            return .gyeongnam
        }
        if address.contains("광주") {
            return .gwangju
        }
        if address.contains("전북") || address.contains("전라북도") {
            return .jeonbuk
        }
        if address.contains("전남") || address.contains("전라남도") {
            return .jeonnam
        }
        if address.contains("제주") {
            return .jeju
        }
        
        return nil
    }
}
