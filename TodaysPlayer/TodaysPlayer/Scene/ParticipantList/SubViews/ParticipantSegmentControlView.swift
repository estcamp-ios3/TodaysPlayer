//
//  ParticipantSegmentConrolView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 9/30/25.
//

import SwiftUI

struct ParticipantSegmentControlView: View {
    let categories: [String]
    @State private var selectedStatus: String
    
    @Namespace private var underlineNamespace
    
    var onSelectionChanged: ((String) -> Void)? = nil
    
    init(categories: [String],
         initialSelection: String,
         onSelectionChanged: ((String) -> Void)? = nil
    ) {
        self.categories = categories
        _selectedStatus = State(initialValue: initialSelection)
        self.onSelectionChanged = onSelectionChanged
    }
    
    var body: some View {
        VStack {
            HStack {
                ForEach(categories, id: \.self) { status in
                    ZStack(alignment: .bottom) {
                        Text(status)
                            .foregroundColor(selectedStatus == status ? .green : .gray)
                            .font(.headline)
                            .overlay(
                                VStack {
                                    if selectedStatus == status {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.green.opacity(0.5))
                                            .frame(height: 3)
                                            .matchedGeometryEffect(id: "underline", in: underlineNamespace)
                                            .offset(y: 10)
                                    }
                                },
                                alignment: .bottom
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            selectedStatus = status
                            onSelectionChanged?(selectedStatus)
                        }
                    }
                }
            }
        }
    }
}
