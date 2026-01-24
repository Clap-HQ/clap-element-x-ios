//
// Copyright 2025 Element Creations Ltd.
// Copyright 2022-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import Foundation
import SwiftUI

import OrderedCollections

struct TextRoomTimelineView: View, TextBasedRoomTimelineViewProtocol {
    static let maxLinkPreviewsToRender = 2
    static let maxLineCount = 25
    static let maxCharacterCount = 450

    @Environment(\.timelineContext) private var context
    let timelineItem: TextRoomTimelineItem

    @State private var linkMetadata: OrderedDictionary<URL, LinkMetadataProviderItem>
    @State private var showFullMessageSheet = false

    /// Returns the visible text content (from formattedBody if available, otherwise body)
    private var visibleTextContent: String {
        if let formattedBody = timelineItem.content.formattedBody {
            return String(formattedBody.characters)
        }
        return timelineItem.body
    }

    private var lineCount: Int {
        visibleTextContent.components(separatedBy: "\n").count
    }

    private var exceedsLineLimit: Bool {
        lineCount > Self.maxLineCount
    }

    private var exceedsCharacterLimit: Bool {
        visibleTextContent.count > Self.maxCharacterCount
    }

    private var shouldTruncate: Bool {
        guard !timelineItem.shouldBoost else { return false }
        return exceedsLineLimit || exceedsCharacterLimit
    }

    private var truncatedAttributedString: AttributedString? {
        guard shouldTruncate, let attributedString = timelineItem.content.formattedBody else {
            return timelineItem.content.formattedBody
        }

        let string = String(attributedString.characters)
        var truncateIndex: Int

        if exceedsLineLimit {
            // Truncate by line count
            let lines = string.components(separatedBy: "\n")
            let truncatedLines = lines.prefix(Self.maxLineCount).joined(separator: "\n")
            truncateIndex = truncatedLines.count
        } else {
            // Truncate by character count
            truncateIndex = Self.maxCharacterCount
        }

        guard let endIndex = attributedString.characters.index(
            attributedString.startIndex,
            offsetBy: truncateIndex,
            limitedBy: attributedString.endIndex
        ) else {
            return attributedString
        }

        // Create a truncated AttributedString preserving formatting
        var truncated = AttributedString(attributedString[attributedString.startIndex..<endIndex])
        truncated.append(AttributedString("…"))

        return truncated
    }

    private var truncatedPlainText: String {
        guard shouldTruncate else {
            return timelineItem.body
        }

        if exceedsLineLimit {
            let lines = timelineItem.body.components(separatedBy: "\n")
            return lines.prefix(Self.maxLineCount).joined(separator: "\n") + "…"
        } else {
            return String(timelineItem.body.prefix(Self.maxCharacterCount)) + "…"
        }
    }

    init(timelineItem: TextRoomTimelineItem, linkMetadata: OrderedDictionary<URL, LinkMetadataProviderItem> = [:]) {
        self.timelineItem = timelineItem
        self.linkMetadata = linkMetadata
    }

    var body: some View {
        TimelineStyler(timelineItem: timelineItem) {
            VStack(alignment: .leading, spacing: 8) {
                if shouldTruncate {
                    truncatedContent
                } else {
                    fullContent
                }

                if context?.viewState.linkPreviewsEnabled ?? false, !linkMetadata.keys.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(linkMetadata.keys, id: \.absoluteString) { url in
                            let metadata = linkMetadata[url]?.metadata ?? context?.viewState.linkMetadataProvider?.metadataItems[url]?.metadata
                            LinkPreviewView(url: url, metadata: metadata)
                        }
                    }
                    .padding(.bottom, 16)
                }
            }
        }
        .task { await fetchLinkPreviews() }
        .sheet(isPresented: $showFullMessageSheet) {
            FullMessageSheetView(timelineItem: timelineItem)
        }
    }

    @ViewBuilder
    private var fullContent: some View {
        if let attributedString = timelineItem.content.formattedBody {
            FormattedBodyText(attributedString: attributedString,
                              boostFontSize: timelineItem.shouldBoost)
        } else {
            FormattedBodyText(text: timelineItem.body,
                              boostFontSize: timelineItem.shouldBoost)
        }
    }

    @ViewBuilder
    private var truncatedContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let attributedString = truncatedAttributedString {
                FormattedBodyText(attributedString: attributedString,
                                  boostFontSize: false)
            } else {
                FormattedBodyText(text: truncatedPlainText,
                                  boostFontSize: false)
            }

            Button {
                showFullMessageSheet = true
            } label: {
                Text(L10n.screenRoomTimelineReactionsShowMore)
                    .font(.compound.bodySMSemibold)
                    .foregroundColor(.compound.textBubble(isOutgoing: timelineItem.isOutgoing))
                    .padding(.top, 4)
                    .padding(.trailing, 40)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
    
    /// Concurrently fetches metadata for up to `maxLinkPreviewsToRender` links from the timeline item and stores successful results in `linkMetadata`.
    /// - Note: If link previews are disabled in the current view state the method returns immediately. Successful metadata updates are applied on the main actor.
    private func fetchLinkPreviews() async {
        guard context?.viewState.linkPreviewsEnabled ?? false else {
            return
        }
        
        await withTaskGroup { taskGroup in
            for url in timelineItem.links.prefix(Self.maxLinkPreviewsToRender) {
                taskGroup.addTask {
                    if case let .success(metadata) = await context?.viewState.linkMetadataProvider?.fetchMetadataFor(url: url) {
                        await MainActor.run {
                            linkMetadata[url] = metadata
                        }
                    }
                }
            }
        }
    }
}

struct TextRoomTimelineView_Previews: PreviewProvider, TestablePreview {
    static let viewModel = TimelineViewModel.mock
    
    static var previews: some View {
        body.environmentObject(viewModel.context)
            .previewDisplayName("Bubble")
            .previewLayout(.sizeThatFits)
        body
            .environmentObject(viewModel.context)
            .environment(\.layoutDirection, .rightToLeft)
            .previewDisplayName("Bubble RTL")
            .previewLayout(.sizeThatFits)
    }
    
    static var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20.0) {
                TextRoomTimelineView(timelineItem: itemWith(text: "Short loin ground round tongue hamburger, fatback salami shoulder. Beef turkey sausage kielbasa strip steak. Alcatra capicola pig tail pancetta chislic.",
                                                            timestamp: .mock,
                                                            isOutgoing: false,
                                                            senderId: "Bob"))
                
                TextRoomTimelineView(timelineItem: itemWith(text: "Check out this cool website: https://www.apple.com and also https://github.com for some great projects!",
                                                            timestamp: .mock,
                                                            isOutgoing: true,
                                                            senderId: "Anne"))
                
                TextRoomTimelineView(timelineItem: itemWith(text: "Short loin ground round tongue hamburger, fatback salami shoulder. Beef turkey sausage kielbasa strip steak. Alcatra capicola pig tail pancetta chislic.",
                                                            timestamp: .mock,
                                                            isOutgoing: false,
                                                            senderId: "Bob"))
                
                TextRoomTimelineView(timelineItem: itemWith(text: "Some other text",
                                                            timestamp: .mock,
                                                            isOutgoing: true,
                                                            senderId: "Anne"))
                
                TextRoomTimelineView(timelineItem: itemWith(text: "טקסט אחר",
                                                            timestamp: .mock,
                                                            isOutgoing: true,
                                                            senderId: "Anne"))
                
                TextRoomTimelineView(timelineItem: itemWith(html: "<ol><li>First item</li><li>Second item</li><li>Third item</li></ol>",
                                                            timestamp: .mock,
                                                            isOutgoing: true,
                                                            senderId: "Anne"))
                
                TextRoomTimelineView(timelineItem: itemWith(html: "<ol><li>פריט ראשון</li><li>הפריט השני</li><li>פריט שלישי</li></ol>",
                                                            timestamp: .mock,
                                                            isOutgoing: true,
                                                            senderId: "Anne"))
                
                // HTML with links for testing
                TextRoomTimelineView(timelineItem: itemWith(html: "Check out <a href=\"https://www.apple.com\">Apple's website</a> and <a href=\"https://github.com\">GitHub</a>!",
                                                            timestamp: .mock,
                                                            isOutgoing: false,
                                                            senderId: "Bob"))
            }
        }
    }
    
    private static func itemWith(text: String, timestamp: Date, isOutgoing: Bool, senderId: String) -> TextRoomTimelineItem {
        TextRoomTimelineItem(id: .randomEvent,
                             timestamp: timestamp,
                             isOutgoing: isOutgoing,
                             isEditable: isOutgoing,
                             canBeRepliedTo: true,
                             sender: .init(id: senderId),
                             content: .init(body: text))
    }
    
    private static func itemWith(html: String, timestamp: Date, isOutgoing: Bool, senderId: String) -> TextRoomTimelineItem {
        let builder = AttributedStringBuilder(cacheKey: "preview", mentionBuilder: MentionBuilder())
        let attributedString = builder.fromHTML(html)
        
        return TextRoomTimelineItem(id: .randomEvent,
                                    timestamp: timestamp,
                                    isOutgoing: isOutgoing,
                                    isEditable: isOutgoing,
                                    canBeRepliedTo: true,
                                    sender: .init(id: senderId),
                                    content: .init(body: "", formattedBody: attributedString))
    }
}