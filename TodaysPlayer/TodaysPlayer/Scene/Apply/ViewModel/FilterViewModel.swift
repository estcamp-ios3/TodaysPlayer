//
//  FilterViewModel.swift
//  TodaysPlayer
//
//  Created by 권소정 on 10/14/25.
//

import Foundation
import FirebaseFirestore
import Combine

class FilterViewModel: ObservableObject {
    @Published var currentFilter = GameFilter()
    @Published var matches: [Match] = []
    @Published var isLoading = false
    
    // 선택된 날짜 (ApplyView에서 전달받음)
    var selectedDate: Date = Date()
    
    // MARK: - enum 값 ↔ Firebase 필드값 매핑
    
    /// SkillLevel enum → Firebase 필드값 변환
    private func skillLevelToFirebase(_ skillLevel: SkillLevel) -> String {
        switch skillLevel {
        case .professional: return "professional"
        case .elite: return "elite"
        case .amateur: return "amateur"
        case .beginner: return "beginner"
        }
    }
    
    /// Gender enum → Firebase 필드값 변환
    private func genderToFirebase(_ gender: Gender) -> String {
        switch gender {
        case .male: return "male"
        case .female: return "female"
        }
    }
    
    /// MatchType enum → Firebase 필드값 변환
    private func matchTypeToFirebase(_ matchType: MatchType) -> String {
        return matchType.rawValue.lowercased() // "풋살" → "futsal", "축구" → "soccer"
    }
    
    // MARK: - 필터 적용 및 데이터 가져오기
    
    /// 필터를 적용하여 매치 데이터 가져오기
    func applyFilter() {
        Task {
            await fetchFilteredMatches()
        }
    }
    
    /// Firestore에서 필터링된 매치 가져오기
    /// Firestore에서 필터링된 매치 가져오기
    private func fetchFilteredMatches() async {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            // ✅ 1️⃣ 전체 데이터 가져오기 (정렬만)
            let query: Query = Firestore.firestore()
                .collection("matches")
                .order(by: "createdAt", descending: true)
            
            let snapshot = try await query.getDocuments()
            let documents = snapshot.documents
            
            let fetchedMatches = documents.compactMap { doc -> Match? in
                let decoder = Firestore.Decoder()
                decoder.userInfo[Match.documentIdKey] = doc.documentID
                
                do {
                    return try doc.data(as: Match.self, decoder: decoder)
                } catch {
                    print("Match 디코딩 실패: \(error)")
                    return nil
                }
            }
            
            // ✅ 2️⃣ 클라이언트에서 모든 필터 적용
            var filteredMatches = fetchedMatches
            
            // 경기 종류 필터
            if let matchType = currentFilter.matchType {
                let firebaseValue = matchTypeToFirebase(matchType)
                filteredMatches = filteredMatches.filter { $0.matchType == firebaseValue }
            }
            
            // 성별 필터
            if let gender = currentFilter.gender {
                let firebaseValue = genderToFirebase(gender)
                filteredMatches = filteredMatches.filter { $0.gender == firebaseValue }
            }
            
            // 참가비 필터
            if let feeType = currentFilter.feeType {
                switch feeType {
                case .free:
                    filteredMatches = filteredMatches.filter { $0.price == 0 }
                case .paid:
                    filteredMatches = filteredMatches.filter { $0.price > 0 }
                }
            }
            
            // 실력 필터
            if !currentFilter.skillLevels.isEmpty {
                let firebaseSkillLevels = currentFilter.skillLevels.map { skillLevelToFirebase($0) }
                filteredMatches = filteredMatches.filter { match in
                    firebaseSkillLevels.contains(match.skillLevel)
                }
            }
            
            // 날짜 필터
            filteredMatches = filteredMatches.filter { match in
                Calendar.current.isDate(match.dateTime, inSameDayAs: selectedDate)
            }
            
            await MainActor.run {
                self.matches = filteredMatches
                self.isLoading = false
                print("✅ 필터링된 매치 개수: \(self.matches.count)")
            }
            
        } catch {
            print("❌ Firestore 에러: \(error.localizedDescription)")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    /// 필터 초기화
    func resetFilter() {
        currentFilter = GameFilter()
        applyFilter()
    }
    
    /// 초기 데이터 로드 (필터 없이 전체 매치)
    func fetchInitialMatches() {
        Task {
            await fetchFilteredMatches()
        }
    }
}
