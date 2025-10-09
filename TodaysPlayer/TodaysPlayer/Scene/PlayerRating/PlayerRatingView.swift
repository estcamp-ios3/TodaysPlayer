//
//  PlayerRatingView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/8/25.
//

import SwiftUI

struct PlayerRatingView: View {
    let matchInfo: MatchInfo
    let participatedUsers: [User] = [
        User(
            id: "bJYjlQZuaqvw2FDB5uNa",
            email: "player1@example.com",
            displayName: "축구왕김철수",
            profileImageUrl: nil,
            phoneNumber: "010-1234-5678",
            position: "공격수",
            skillLevel: "중급",
            preferredRegions: ["서울특별시", "경기도"],
            isTeamLeader: true,
            teamId: nil,
            createdAt: Date(),
            updatedAt: Date(),
            isActive: true
        ),
        User(
            id: "player2",
            email: "player2@example.com",
            displayName: "미드필더박영희",
            profileImageUrl: nil,
            phoneNumber: "010-2345-6789",
            position: "미드필더",
            skillLevel: "상급",
            preferredRegions: ["경기도", "인천광역시"],
            isTeamLeader: false,
            teamId: nil,
            createdAt: Date(),
            updatedAt: Date(),
            isActive: true
        )
    ]
    
    @State private var expandedUserID: String? = nil
    @State private var ratings: [String: [String: Int]] = [:] // userID별로 항목별 점수 저장
    @State private var comments: [String: String] = [:]
    @State private var completedRatings: Set<String> = [] // 평가 완료된 유저 ID
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea()
            
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(matchInfo.matchType.rawValue)
                        .matchTagStyle(tagType: matchInfo.matchType)
                    Text(matchInfo.matchTitle)
                        .font(.headline)
                        .padding(.bottom, 10)
                    
                    HStack {
                        Image(systemName: "clock")
                        Text(matchInfo.matchTime)
                    }
                    HStack {
                        Image(systemName: "location")
                        Text(matchInfo.matchLocation)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12)
                
                Text("참여자 평가")
                    .font(.headline)
                    .padding(.leading, 10)
                
                List(participatedUsers, id: \.id) { user in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gray)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.displayName)
                                    .font(.headline)
                                Text("\(user.position ?? "") / \(user.skillLevel ?? "")")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            // 평가가 안된 경우 - 평가하기
                            // 된 경우 - 수정하기
                            // 평가 중 - 닫기
                            let isCompleted = completedRatings.contains(user.id)
                            let isExpanded = expandedUserID == user.id

                            Button {
                                expandedUserID = isExpanded ? nil : user.id
                            } label: {
                                HStack {
                                    Text(buttonTitle(isCompleted: isCompleted, isExpanded: isExpanded))
                                        .font(.subheadline)
                                }
                                .foregroundColor(isCompleted ? .green : .blue)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background((isCompleted ? Color.green : Color.blue).opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                        }
                        
                        if expandedUserID == user.id {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach([
                                    ("trophy", "실력"),
                                    ("heart", "매너"),
                                    ("person.2", "팀워크"),
                                    ("timer", "시간약속")
                                ], id: \.1) { (icon, title) in
                                    StarRatingView(
                                        rating: Binding(
                                            get: { ratings[user.id]?[title] ?? 0 },
                                            set: {
                                                if ratings[user.id] == nil { ratings[user.id] = [:] }
                                                ratings[user.id]?[title] = $0
                                            }
                                        ),
                                        imageName: icon,
                                        title: title
                                    )
                                }
                                
                                Text("코멘트")
                                    .font(.subheadline)
                                
                                TextEditor(
                                    text: Binding(get: { comments[user.id] ?? ""},
                                                  set: { comments[user.id] = $0})
                                )
                                .frame(minHeight: 80)
                                .padding(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3))
                                )
                                
                                Button("평가 완료") {
                                    completedRatings.insert(user.id)
                                    expandedUserID = nil
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.green)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 8)
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
                .listRowSpacing(10)
                .listStyle(.plain)
                .padding()
                .scrollContentBackground(.hidden)
            }
        }
    }
    
    private func buttonTitle(isCompleted: Bool, isExpanded: Bool) -> String {
        if isCompleted {
            return "수정하기"
        } else {
            return isExpanded ? "닫기" : "평가하기"
        }
    }
}



#Preview {
    PlayerRatingView(matchInfo: mockMatchData.first!)
}
