//
//  AIIntroductionService.swift
//  TodaysPlayer
//
//  AI를 활용한 자기소개 생성 서비스
//

import Foundation
import AlanAI

/// AI를 활용하여 용병 신청 자기소개를 자동 생성하는 서비스
class AIIntroductionService {
    
    // MARK: - Properties
    
    private let alanAI: AlanAI
    
    // MARK: - Initialization
    
    init(clientID: String) {
        self.alanAI = AlanAI(clientID: clientID)
    }
    
    // MARK: - Public Methods
    
    /// 사용자 정보를 기반으로 자기소개를 생성합니다
    /// - Parameters:
    ///   - position: 포지션 (선택사항)
    ///   - skillLevel: 실력 수준 (선택사항)
    /// - Returns: AI가 생성한 자기소개 텍스트
    /// - Throws: AlanAIError
    func generateIntroduction(position: String?, skillLevel: String?) async throws -> String {
        // 프롬프트 생성
        let prompt = buildPrompt(position: position, skillLevel: skillLevel)
        
        print("🤖 AI 프롬프트 전송: \(prompt)")
        
        // AI 호출
        let response = try await alanAI.question(query: prompt)
        
        guard let content = response?.content, !content.isEmpty else {
            throw AIIntroductionError.emptyResponse
        }
        
        print("✅ AI 응답 수신: \(content)")
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Private Methods
    
    /// AI에게 전달할 프롬프트를 생성합니다
    private func buildPrompt(position: String?, skillLevel: String?) -> String {
        var prompt = """
        당신은 풋살/축구 매칭 앱의 용병 신청 자기소개를 작성하는 AI입니다.
        
        사용자 정보:
        """
        
        // 포지션 정보 추가
        if let position = position, !position.isEmpty {
            prompt += "\n- 포지션: \(position)"
        } else {
            prompt += "\n- 포지션: 미정 (자유 포지션)"
        }
        
        // 실력 수준 정보 추가
        if let skillLevel = skillLevel, !skillLevel.isEmpty {
            let koreanLevel = skillLevel.skillLevelToKorean()
            prompt += "\n- 실력 수준: \(koreanLevel)"
        } else {
            prompt += "\n- 실력 수준: 보통"
        }
        
        prompt += """
        
        
        다음 조건에 맞춰 자기소개를 작성해주세요:
        1. 3줄 이내로 간결하게
        2. 친근하고 열정적인 톤
        3. 플레이 스타일이나 강점 포함
        4. 경기 참여 각오 포함
        5. 인사말로 시작 (예: "안녕하세요!")
        
        예시:
        "안녕하세요! 축구 경력 3년차로 수비를 담당하고 있습니다. 패스워크를 중시하며 팀워크를 중요하게 생각합니다. 좋은 경기 만들어가요!"
        
        위 조건에 맞춰 자기소개만 작성해주세요. 다른 설명은 불필요합니다.
        """
        
        return prompt
    }
}

// MARK: - Error Types

/// AI 자기소개 생성 시 발생할 수 있는 에러
enum AIIntroductionError: LocalizedError {
    case emptyResponse
    case invalidRequest
    
    var errorDescription: String? {
        switch self {
        case .emptyResponse:
            return "AI로부터 응답을 받지 못했습니다."
        case .invalidRequest:
            return "잘못된 요청입니다."
        }
    }
}
