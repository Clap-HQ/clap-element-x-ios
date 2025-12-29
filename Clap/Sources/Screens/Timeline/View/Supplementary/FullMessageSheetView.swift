//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct FullMessageSheetView: View {
    @Environment(\.dismiss) private var dismiss

    let timelineItem: TextRoomTimelineItem

    var body: some View {
        NavigationStack {
            ScrollView {
                fullMessageBubble
                    .padding(.horizontal, 8)
                    .padding(.top, 16)
            }
            .background(.compound.bgRoomScreen)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.actionClose) {
                        dismiss()
                    }
                }
            }
        }
        .presentationDragIndicator(.hidden)
        .presentationDetents([.large])
    }

    @ViewBuilder
    private var fullMessageBubble: some View {
        TimelineStyler(timelineItem: timelineItem) {
            VStack(alignment: .leading, spacing: 8) {
                if let attributedString = timelineItem.content.formattedBody {
                    FormattedBodyText(attributedString: attributedString,
                                      boostFontSize: timelineItem.shouldBoost)
                } else {
                    FormattedBodyText(text: timelineItem.body,
                                      boostFontSize: timelineItem.shouldBoost)
                }
            }
        }
    }
}
