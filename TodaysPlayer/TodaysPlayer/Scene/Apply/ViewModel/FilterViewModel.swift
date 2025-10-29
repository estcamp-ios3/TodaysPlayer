//
//  FilterViewModel.swift
//  TodaysPlayer
//
//  Created by 권소정 on 10/14/25.
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
class FilterViewModel: ObservableObject {
    @Published var currentFilter = GameFilter()
    @Published var matches: [Match] = []
    @Published var isLoading = false
    @Published var selectedDate: Date = Date()
    private let db = Firestore.firestore()
    
    
    // MARK: - 필터 적용 및 데이터 가져오기
    /// 필터를 적용하여 매치 데이터 가져오기
    func applyFilter() {
        Task {
            await fetchFilteredMatches()
        }
    }
    
    /// Firestore에서 필터링된 매치 가져오기
    private func fetchFilteredMatches() async {
        isLoading = true
        
        do {
            // 1. Firestore에서 전체 데이터 가져오기 (정렬만)
            let query: Query = db.collection("matches")
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
            
            // 2. 클라이언트에서 모든 필터 적용
            let filterdMatches = applyFilters(to: fetchedMatches)
            
            self.matches = filterdMatches
            self.isLoading = false
            
            print("필터링 완료")
            print("   - 지역: \(currentFilter.region.rawValue)")
            print("   - 날짜: \(selectedDate)")
            print("   - 결과: \(self.matches.count)개")
            
        } catch {
            print("Firestore 에러: \(error.localizedDescription)")
            self.isLoading = false
        }
    }
    
    // MARK: - 필터링 로직 분리
    
    private func applyFilters(to matches: [Match]) -> [Match] {
        var filtered = matches
        
        // 지역 필터 (가장 먼저 적용)
        if currentFilter.region != .all {
            filtered = filtered.filter { match in
                let extractedRegion = EnumMapper.extractRegion(from: match.location.address)
                return extractedRegion == currentFilter.region
            }
        }
        
        // 날짜 필터
        filtered = filtered.filter { match in
            Calendar.current.isDate(match.dateTime, inSameDayAs: selectedDate)
        }
        
        // 시간 필터 추가: 현재 시간보다 미래 경기만 표시
        filtered = filtered.filter { match in
            match.dateTime > Date()
        }
        
        // 경기 종류 필터
        if let matchType = currentFilter.matchType {
            let firebaseValue = EnumMapper.matchType(matchType)
            filtered = filtered.filter { $0.matchType == firebaseValue }
        }
        
        // 성별 필터
        if let gender = currentFilter.gender {
            let firebaseValue = EnumMapper.gender(gender)
            filtered = filtered.filter { $0.gender == firebaseValue }
        }
        
        // 참가비 필터
        if let feeType = currentFilter.feeType {
            switch feeType {
            case .free:
                filtered = filtered.filter { $0.price == 0 }
            case .paid:
                filtered = filtered.filter { $0.price > 0 }
            }
        }
        
        // 실력 필터
        if !currentFilter.skillLevels.isEmpty {
            let firebaseSkillLevels = currentFilter.skillLevels.map { EnumMapper.skillLevel($0) }
            filtered = filtered.filter { match in
                firebaseSkillLevels.contains(match.skillLevel)
            }
        }
        return filtered
    }
    
    // MARK: - 필터 관리
    
    func resetFilter() {
        currentFilter = GameFilter()
        applyFilter()
    }
    
    /// 초기 데이터 로드
    func fetchInitialMatches() {
        Task {
            await fetchFilteredMatches()
        }
    }
    
    /// 지역 변경 (외부에서 호출)
    func updateRegion(_ region: Region) {
        currentFilter.region = region
        applyFilter()
    }
    
    func addNewMatch(_ match: Match) {
        matches.insert(match, at: 0)
        
        print("새 매치 추가됨: \(match.title)")
        print(" - 현재 매치 개수: \(matches.count)")
    }
}
