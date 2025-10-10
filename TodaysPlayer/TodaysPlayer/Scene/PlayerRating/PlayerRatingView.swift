//
//  PlayerRatingView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/8/25.
//

import SwiftUI


/// 참여자 평가화면
struct PlayerRatingView: View {
    let viewModel: PlayerRatingViewModel
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea()
            
            // 종료된 매치 정보
            VStack(alignment: .leading) {
                FinishedMatchView(matchInfo: viewModel.matchInfo)
                
                // 매치에 참여한 참가자 목록
                Text("참여자 목록")
                    .font(.headline)
                    .padding(.leading, 12)
                
                List(viewModel.participatedUsers, id: \.id) { user in
                    VStack(alignment: .leading, spacing: 12) {
                        ParticipatedPlayerInfoView(userInfo: user, viewModel: viewModel)
                        
                        PlayerRatingListView(userInfo: user, viewModel: viewModel)
                            .visible(viewModel.expandedUserID == user.id)
                        
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
                
                Button("평가 완료") {
                    
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 8)
            }
        }
        .navigationTitle("참여자 평가하기")
    }
    
}



#Preview {
    PlayerRatingView(viewModel: PlayerRatingViewModel(matchInfo: mockMatchData.first!))
}
