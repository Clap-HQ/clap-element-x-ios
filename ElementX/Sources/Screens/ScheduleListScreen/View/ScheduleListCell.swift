//
// Copyright 2025 Clap Communications Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct ScheduleListCell: View {
    let schedule: Schedule
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                headerRow
                Text(schedule.name)
                    .font(.compound.bodyMD)
                    .fontWeight(.medium)
                    .foregroundColor(.compound.textPrimary)
                    .lineLimit(3)
                Text(schedule.cronExpression)
                    .font(.compound.bodySM.monospaced())
                    .foregroundColor(.compound.textSecondary)
            }
            .padding(16)
            .background(Color.compound.bgSubtleSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .contentShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
    
    private var headerRow: some View {
        HStack(alignment: .center) {
            Text("#\(schedule.id)")
                .font(.compound.bodySMSemibold)
                .foregroundColor(.compound.textSecondary)
            
            ScheduleStatusBadge(status: schedule.status)
            
            if schedule.isDM {
                ScheduleDMBadge()
            }
            
            Spacer()
        }
    }
}

struct ScheduleStatusBadge: View {
    let status: ScheduleStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.compound.bodySM)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
    
    private var backgroundColor: Color {
        switch status {
        case .active: return Color.green.opacity(0.15)
        case .paused: return Color.gray.opacity(0.15)
        case .pending: return Color.orange.opacity(0.15)
        case .cancelled: return Color.red.opacity(0.15)
        }
    }
    
    private var foregroundColor: Color {
        switch status {
        case .active: return .green
        case .paused: return .gray
        case .pending: return .orange
        case .cancelled: return .red
        }
    }
}

struct ScheduleDMBadge: View {
    var body: some View {
        Text("DM")
            .font(.compound.bodySM)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.purple.opacity(0.15))
            .foregroundColor(.purple)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

// MARK: - Previews

struct ScheduleListCell_Previews: PreviewProvider, TestablePreview {
    static var previews: some View {
        VStack(spacing: 0) {
            ScheduleListCell(schedule: .mockActive, onTap: { })
            ScheduleListCell(schedule: .mockPaused, onTap: { })
            ScheduleListCell(schedule: .mockDM, onTap: { })
            ScheduleListCell(schedule: .mockLongName, onTap: { })
        }
        .background(Color.compound.bgCanvasDefault)
        .previewDisplayName("Schedule Cells")
    }
}

struct ScheduleStatusBadge_Previews: PreviewProvider, TestablePreview {
    static var previews: some View {
        HStack(spacing: 8) {
            ForEach(ScheduleStatus.allCases, id: \.self) { status in
                ScheduleStatusBadge(status: status)
            }
        }
        .padding()
        .previewDisplayName("Status Badges")
    }
}

// MARK: - Mock Data

extension Schedule {
    static let mockActive = Schedule(
        id: 1,
        name: "매일 아침 뉴스 요약",
        roomID: "!room1:clap.ac",
        cronExpression: "0 9 * * *",
        timezone: "Asia/Seoul",
        prompt: "오늘의 주요 뉴스를 요약해줘",
        userID: "@user:clap.ac",
        targetUser: "coby",
        targetRoom: nil,
        isDM: false,
        status: .active,
        runCount: 5,
        lastRunAt: .now.addingTimeInterval(-86400),
        lastError: nil,
        createdAt: .now.addingTimeInterval(-604800),
        updatedAt: .now
    )
    
    static let mockPaused = Schedule(
        id: 2,
        name: "주간 리포트",
        roomID: "!room2:clap.ac",
        cronExpression: "0 10 * * 1",
        timezone: "Asia/Seoul",
        prompt: "주간 업무 리포트 생성",
        userID: "@user:clap.ac",
        targetUser: nil,
        targetRoom: nil,
        isDM: false,
        status: .paused,
        runCount: 0,
        lastRunAt: nil,
        lastError: nil,
        createdAt: .now,
        updatedAt: .now
    )
    
    static let mockDM = Schedule(
        id: 3,
        name: "개인 일정 알림",
        roomID: "!dm:clap.ac",
        cronExpression: "0 8 * * 1-5",
        timezone: "Asia/Seoul",
        prompt: "오늘 일정 알려줘",
        userID: "@user:clap.ac",
        targetUser: "jace",
        targetRoom: nil,
        isDM: true,
        status: .active,
        runCount: 10,
        lastRunAt: .now.addingTimeInterval(-3600),
        lastError: nil,
        createdAt: .now,
        updatedAt: .now
    )
    
    static let mockLongName = Schedule(
        id: 4,
        name: "이것은 매우 긴 스케줄 이름입니다. 두 줄까지 표시되는지 확인하기 위한 테스트 데이터입니다.",
        roomID: "!room3:clap.ac",
        cronExpression: "30 14 * * *",
        timezone: "Asia/Seoul",
        prompt: "긴 이름 테스트",
        userID: "@user:clap.ac",
        targetUser: nil,
        targetRoom: nil,
        isDM: false,
        status: .pending,
        runCount: 0,
        lastRunAt: nil,
        lastError: nil,
        createdAt: .now,
        updatedAt: .now
    )
}
