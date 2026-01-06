//
// Copyright 2026 Element Creations Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct FullMessageSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.timelineContext) private var timelineContext

    let timelineItem: TextRoomTimelineItem

    var body: some View {
        NavigationStack {
            ScrollView {
                if let attributedString = timelineItem.content.formattedBody {
                    MessageText(attributedString: adjustedAttributedString(attributedString))
                        .tint(.compound.textLinkExternal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                } else {
                    Text(timelineItem.body)
                        .font(.compound.bodyLG)
                        .foregroundStyle(.compound.textPrimary)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                }
            }
            .background(.compound.bgCanvasDefault)
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

    /// Adjusts code block background color for better visibility in modal
    private func adjustedAttributedString(_ original: AttributedString) -> AttributedString {
        var adjusted = original

        // Apply default text attributes
        var container = AttributeContainer()
        container.font = UIFont.preferredFont(forTextStyle: .body)
        container.foregroundColor = UIColor.compound.textPrimary
        adjusted.mergeAttributes(container, mergePolicy: .keepCurrent)

        // Apply code block colors
        for run in adjusted.runs {
            if run.codeBlock == true {
                let range = run.range
                adjusted[range].backgroundColor = UIColor.compound._bgCodeBlock(isOutgoing: false)
                adjusted[range].foregroundColor = UIColor.compound._textCodeBlock(isOutgoing: false)
            }
        }

        return adjusted
    }
}
