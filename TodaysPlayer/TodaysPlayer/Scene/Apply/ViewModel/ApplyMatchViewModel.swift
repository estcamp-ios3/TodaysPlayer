//
//  ApplyMatchViewModel.swift
//  TodaysPlayer
//
//  매칭 신청 화면의 비즈니스 로직을 담당하는 ViewModel
//

import Foundation
import Combine
import AlanAI

/// 매칭 신청 화면의 상태 관리 및 비즈니스 로직
@MainActor
class ApplyMatchViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// 자기소개 메시지
    @Published var message: String = ""
    
    /// 선택한 포지션
    @Published var position: String = ""
    
    /// 참가 인원
    @Published var participantCount: Int = 1
    
    /// AI 생성 중 로딩 상태
    @Published var isGeneratingAI: Bool = false
    
    /// 신청 제출 중 로딩 상태
    @Published var isSubmitting: Bool = false
    
    /// 성공 알림 표시 여부
    @Published var showSuccessAlert: Bool = false
    
    /// 에러 알림 표시 여부
    @Published var showErrorAlert: Bool = false
    
    /// 에러 메시지
    @Published var errorMessage: String = ""
    
    // MARK: - Private Properties
    
    private let aiService: AIIntroductionService
    private let match: Match
    
    // MARK: - Computed Properties
    
    /// 신청하기 버튼 활성화 조건
    var isFormValid: Bool {
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Initialization
    
    init(match: Match, aiClientID: String) {
        self.match = match
        self.aiService = AIIntroductionService(clientID: aiClientID)
    }
    
    // MARK: - Public Methods
    
    /// AI로 자기소개 생성
    func generateAIIntroduction() {
        isGeneratingAI = true
        errorMessage = ""
        
        Task {
            do {
                // 1. 현재 사용자 정보 가져오기
                let userId = AuthHelper.currentUserId
                let user = try await FirestoreManager.shared.getDocument(
                    collection: "users",
                    documentId: userId,
                    as: User.self
                )
                
                guard let user = user else {
                    throw AIIntroductionError.invalidRequest
                }
                
                // 2. 포지션 우선순위: View 선택 → User 프로필 → nil
                let selectedPosition = position.isEmpty ? user.position : position
                
                // 3. AI 호출
                let generatedText = try await aiService.generateIntroduction(
                    position: selectedPosition,
                    skillLevel: user.skillLevel
                )
                
                // 4. 결과를 메시지에 반영
                message = generatedText
                
                print("✅ AI 자기소개 생성 완료")
                
            } catch let error as AlanAIError {
                // AlanAI 에러 처리
                errorMessage = "AI 생성 실패: \(error.localizedDescription)"
                showErrorAlert = true
                print("❌ AlanAI 에러: \(error)")
                
            } catch let error as AIIntroductionError {
                // 커스텀 에러 처리
                errorMessage = error.localizedDescription
                showErrorAlert = true
                print("❌ AI 생성 에러: \(error)")
                
            } catch {
                // 기타 에러
                errorMessage = "예상치 못한 오류가 발생했습니다."
                showErrorAlert = true
                print("❌ 알 수 없는 에러: \(error)")
            }
            
            isGeneratingAI = false
        }
    }
    
    /// 매칭 신청 제출
    func submitApplication() {
        isSubmitting = true
        
        Task {
            do {
                let userId = AuthHelper.currentUserId
                
                // User 정보 가져오기 (닉네임, 실력 등)
                let user = try await FirestoreManager.shared.getDocument(
                    collection: "users",
                    documentId: userId,
                    as: User.self
                )
                
                guard let user = user else {
                    throw NSError(domain: "ApplyMatchViewModel", code: 404, userInfo: [NSLocalizedDescriptionKey: "사용자 정보를 찾을 수 없습니다."])
                }
                
                // Apply 객체 생성
                let apply = Apply(
                    id: UUID().uuidString,
                    matchId: match.id,
                    userId: userId,
                    userNickname: user.displayName,
                    userSkillLevel: user.skillLevel,
                    position: position.isEmpty ? nil : position,
                    participantCount: participantCount,
                    message: message,
                    status: "pending",
                    rejectionReason: nil,
                    appliedAt: Date(),
                    processedAt: nil
                )
                
                // Firebase에 저장
                _ = try await FirestoreManager.shared.createDocument(
                    collection: "apply",
                    data: apply
                )
                
                // Match 문서의 participants 업데이트
                try await FirestoreManager.shared.updateDocument(
                    collection: "matches",
                    documentId: match.id,
                    data: [
                        "participants.\(userId)": "pending"
                    ]
                )
                
                print("✅ 매칭 신청 완료: \(apply.id)")
                
                showSuccessAlert = true
                
            } catch {
                print("❌ 매칭 신청 실패: \(error)")
                errorMessage = "신청 중 오류가 발생했습니다.\n다시 시도해주세요."
                showErrorAlert = true
            }
            
            isSubmitting = false
        }
    }
}
