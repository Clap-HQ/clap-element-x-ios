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
                    MessageText(attributedString: adjustedAttributedString(attributedString),
                                allowsTextSelection: true)
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

    private func adjustedAttributedString(_ original: AttributedString) -> AttributedString {
        var adjusted = original

        // Apply default text attributes
        var container = AttributeContainer()
        container.font = UIFont.preferredFont(forTextStyle: .body)
        container.foregroundColor = UIColor.compound.textPrimary
        adjusted.mergeAttributes(container, mergePolicy: .keepCurrent)

        for run in adjusted.runs {
            let range = run.range

            // Apply blockquote styles with indentation
            if run.blockquote == true {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.firstLineHeadIndent = 12
                paragraphStyle.headIndent = 12

                adjusted[range].paragraphStyle = paragraphStyle
                adjusted[range].foregroundColor = UIColor.compound.textSecondary
                adjusted[range].font = UIFont.preferredFont(forTextStyle: .subheadline)
            }

            // Apply code block colors
            if run.codeBlock == true {
                adjusted[range].backgroundColor = UIColor.compound._bgCodeBlock(isOutgoing: false)
                adjusted[range].foregroundColor = UIColor.compound._textCodeBlock(isOutgoing: false)
            }
        }

        return adjusted
    }
}
