//
//  String+Extensions.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import Foundation
import SwiftUI

extension String {
    /// String 특정 부분 색상변경
    /// - Parameters:
    ///   - part: 변경할 부분
    ///   - color: 변경할 색상
    func highlighted(part: String, color: Color) -> AttributedString {
        var attr = AttributedString(self)
        if let range = attr.range(of: part) {
            attr[range].foregroundColor = color
            attr[range].font = .headline
        }
        return attr
    }
    
    /// 실력 레벨을 한국어로 변환
    /// - Returns: "beginner" → "초급", "intermediate" → "중급" 등
    func skillLevelToKorean() -> String {
        switch self.lowercased() {
        case "beginner":
            return "입문자"
        case "intermediate":
            return "초급"
        case "advanced":
            return "중급"
        case "expert":
            return "상급"
        default:
            return self
        }
    }
    
    /// 가격을 한국어 형식으로 변환
    /// - Parameter price: 가격 (Int)
    /// - Returns: "무료" 또는 "15,000원" 형식
    static func formatPrice(_ price: Int) -> String {
        if price == 0 {
            return "무료"
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return "\(formatter.string(from: NSNumber(value: price)) ?? "\(price)")원"
        }
    }
    
    /// 우편번호(5자리 숫자)를 문자열에서 제거
    /// - Returns: 우편번호가 제거된 주소 문자열
    func removingPostalCode() -> String {
        var result = self
        
        // 맨 앞의 5자리 숫자 제거
        result = result.replacingOccurrences(of: "^\\d{5}\\s*", with: "", options: .regularExpression)
        
        // 맨 끝의 5자리 숫자 제거
        result = result.replacingOccurrences(of: "\\s*\\d{5}$", with: "", options: .regularExpression)
        
        // 연속된 공백 정리
        result = result.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
        
        return result
    }
}
