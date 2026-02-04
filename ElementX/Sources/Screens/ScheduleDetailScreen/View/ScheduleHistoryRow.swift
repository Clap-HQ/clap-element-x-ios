//
// Copyright 2025 Clap Communications Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct ScheduleHistoryRow: View {
    let entry: ScheduleHistoryEntry
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.compound.bodySM)
                    .foregroundColor(.compound.textSecondary)
                
                Spacer()
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.compound.bodySM)
                    .foregroundColor(.compound.iconTertiary)
            }
            
            if isExpanded {
                Text(entry.response)
                    .font(.compound.bodyMD)
                    .foregroundColor(.compound.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color.compound.bgSubtleSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(12)
        .background(Color.compound.bgCanvasDefault)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded.toggle()
            }
        }
    }
}

// MARK: - Previews

struct ScheduleHistoryRow_Previews: PreviewProvider, TestablePreview {
    static var previews: some View {
        VStack(spacing: 8) {
            ScheduleHistoryRow(entry: .mock)
            ScheduleHistoryRow(entry: .mockLongResponse)
        }
        .padding()
        .background(Color.compound.bgSubtleSecondary)
        .previewDisplayName("History Rows")
    }
}

// MARK: - Mock Data

extension ScheduleHistoryEntry {
    static let mock = ScheduleHistoryEntry(
        id: 1,
        scheduleID: 1,
        scheduleDescription: "매일 아침 뉴스 요약",
        response: "오늘의 주요 뉴스입니다.",
        createdAt: .now.addingTimeInterval(-3600)
    )
    
    static let mockLongResponse = ScheduleHistoryEntry(
        id: 2,
        scheduleID: 1,
        scheduleDescription: "매일 아침 뉴스 요약",
        response: "오늘의 주요 뉴스를 요약해드립니다.\n\n1. 경제: 코스피 상승세 지속\n2. 정치: 국회 본회의 개최\n3. 사회: 봄 날씨 계속",
        createdAt: .now.addingTimeInterval(-7200)
    )
}
