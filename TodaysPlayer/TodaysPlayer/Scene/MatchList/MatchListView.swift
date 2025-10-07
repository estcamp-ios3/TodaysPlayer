//
//  MatchListView.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

struct MatchListView: View {
    @State var viewModel: MatchListViewModel = MatchListViewModel()

    var body: some View {
        NavigationStack{
            ZStack {
                Color.gray.opacity(0.1)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("나의 매치 관리")
                        .font(.title)
                        .bold()
                        .padding(.horizontal, 20)

                    ParticipantSegmentControlView(
                        categories: viewModel.myMatchSegmentTitles,
                        initialSelection: viewModel.myMatchSegmentTitles.first ?? "신청한 경기") {
                            viewModel.fetchMatchListDatas(selectedType: $0)
                        }
                    
                    MyMatchFilterButtonView(
                        filterTypes: viewModel.filteringButtonTypes,
                        selectedFilter: $viewModel.selectedFilterButton
                    )
                        .padding(.horizontal, 10)
                    
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.matchListDatas, id: \.self) { match in
                                VStack(spacing: 20) {
                                    MatchTagView(info: match, matchCase: viewModel.postedMatchCase)
                                    MatchInfoView(
                                        matchInfo: match,
                                        postedMatchCase: viewModel.postedMatchCase
                                    )
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.vertical)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}
