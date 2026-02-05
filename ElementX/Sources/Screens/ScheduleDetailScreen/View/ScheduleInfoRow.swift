//
// Copyright 2025 Clap Communications Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct ScheduleInfoRow: View {
    let label: String
    let value: String
    var isMonospaced = false
    
    var body: some View {
        HStack {
            Text(label)
                .font(.compound.bodyMD)
                .foregroundColor(.compound.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(isMonospaced ? .compound.bodySM.monospaced() : .compound.bodyMD)
                .foregroundColor(.compound.textPrimary)
                .lineLimit(1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Previews

struct ScheduleInfoRow_Previews: PreviewProvider, TestablePreview {
    static var previews: some View {
        VStack(spacing: 0) {
            ScheduleInfoRow(label: "Cron 표현식", value: "0 9 * * *", isMonospaced: true)
            ScheduleInfoRow(label: "시간대", value: "Asia/Seoul")
            ScheduleInfoRow(label: "실행 횟수", value: "5회")
            ScheduleInfoRow(label: "생성일", value: Date.now.formatted())
        }
        .background(Color.compound.bgSubtleSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding()
        .previewDisplayName("Info Rows")
    }
}
