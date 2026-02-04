//
// Copyright 2025 Clap Communications Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct ScheduleFilterButton: View {
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Text(title)
            .font(.compound.bodyMD)
            .foregroundColor(isActive ? .compound.textOnSolidPrimary : .compound.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isActive ? .compound.bgActionPrimaryRest : .compound.bgSubtleSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .onTapGesture {
                action()
            }
    }
}

// MARK: - Previews

struct ScheduleFilterButton_Previews: PreviewProvider, TestablePreview {
    static var previews: some View {
        HStack(spacing: 8) {
            ScheduleFilterButton(title: "전체", isActive: true, action: { })
            ScheduleFilterButton(title: "활성", isActive: false, action: { })
            ScheduleFilterButton(title: "취소됨", isActive: false, action: { })
        }
        .padding()
        .background(Color.compound.bgCanvasDefault)
        .previewDisplayName("Filter Buttons")
    }
}
