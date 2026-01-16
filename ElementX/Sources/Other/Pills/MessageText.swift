//
// Copyright 2025 Element Creations Ltd.
// Copyright 2023-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import MatrixRustSDK
import SwiftUI

final class MessageTextView: UITextView, PillAttachmentViewProviderDelegate, UIGestureRecognizerDelegate {
    var timelineContext: TimelineViewModel.Context?
    var updateClosure: (() -> Void)?
    var allowsTextSelection = false
    private var pillViews = NSHashTable<UIView>.weakObjects()

    override func didMoveToWindow() {
        super.didMoveToWindow()
        // Remove all drag interactions to prevent text movement
        interactions.compactMap { $0 as? UIDragInteraction }.forEach { removeInteraction($0) }
    }

    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        // We don't need to change the behaviour on MacOS
        if !ProcessInfo.processInfo.isiOSAppOnMac {
            gestureRecognizer.delegate = self
        }
        super.addGestureRecognizer(gestureRecognizer)
    }

    // This prevents the magnifying glass from showing up (unless text selection is allowed)
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Allow long press for text selection when enabled
        if allowsTextSelection {
            return true
        }
        if otherGestureRecognizer is UILongPressGestureRecognizer {
            return false
        }
        return true
    }
    
    func invalidateTextAttachmentsDisplay() {
        attributedText.enumerateAttribute(.attachment,
                                          in: NSRange(location: 0, length: attributedText.length),
                                          options: []) { value, range, _ in
            guard value != nil else {
                return
            }
            self.layoutManager.invalidateDisplay(forCharacterRange: range)
            updateClosure?()
        }
    }

    func registerPillView(_ pillView: UIView) {
        pillViews.add(pillView)
    }

    func flushPills() {
        for view in pillViews.allObjects {
            view.alpha = 0.0
            view.removeFromSuperview()
        }
        pillViews.removeAllObjects()
    }

    override func copy(_ sender: Any?) {
        guard allowsTextSelection,
              let selectedRange = selectedTextRange,
              !selectedRange.isEmpty else {
            super.copy(sender)
            return
        }

        let nsRange = NSRange(location: offset(from: beginningOfDocument, to: selectedRange.start),
                              length: offset(from: selectedRange.start, to: selectedRange.end))

        let selectedAttributedText = attributedText.attributedSubstring(from: nsRange)
        UIPasteboard.general.string = convertToPlainText(selectedAttributedText)
    }

    /// Converts attributed string with pill attachments and links to plain text
    private func convertToPlainText(_ attributedString: NSAttributedString) -> String {
        var replacements: [(range: NSRange, text: String)] = []
        let fullRange = NSRange(location: 0, length: attributedString.length)

        attributedString.enumerateAttributes(in: fullRange, options: []) { attributes, range, _ in
            if let pillAttachment = attributes[.attachment] as? PillTextAttachment {
                replacements.append((range, pillDisplayText(for: pillAttachment.pillData)))
            } else if let link = attributes[.link] as? URL {
                let displayText = attributedString.attributedSubstring(from: range).string
                let urlString = link.absoluteString

                if !isDisplayTextMatchingURL(displayText, urlString: urlString) {
                    replacements.append((range, "[\(displayText)](\(urlString))"))
                }
            }
        }

        guard !replacements.isEmpty else { return attributedString.string }

        let result = NSMutableAttributedString(attributedString: attributedString)
        for (range, text) in replacements.sorted(by: { $0.range.location > $1.range.location }) {
            result.replaceCharacters(in: range, with: text)
        }
        return result.string
    }

    /// Checks if display text is essentially the same as the URL (ignoring scheme and trailing slashes)
    private func isDisplayTextMatchingURL(_ displayText: String, urlString: String) -> Bool {
        let normalizedDisplay = displayText.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let normalizedURL = urlString
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        return displayText == urlString || normalizedDisplay == normalizedURL
    }

    /// Gets display text for a pill based on its data
    private func pillDisplayText(for pillData: PillTextAttachmentData) -> String {
        switch pillData.type {
        case .user(let userID):
            // Try to get display name from room members
            if let displayName = timelineContext?.viewState.members[userID]?.displayName {
                return displayName
            }
            return userID
        case .allUsers:
            return "room"
        case .roomAlias(let alias):
            return alias
        case .roomID(let roomID):
            return roomID
        case .event(let room):
            switch room {
            case .roomAlias(let alias):
                return alias
            case .roomID(let roomID):
                return roomID
            }
        }
    }
}

struct MessageText: UIViewRepresentable {
    @Environment(\.openURL) private var openURLAction
    @Environment(\.timelineContext) private var viewModel
    @State private var computedSizes = [Double: CGSize]()

    @State var attributedString: AttributedString {
        didSet {
            computedSizes.removeAll()
        }
    }

    var allowsTextSelection = false

    func makeUIView(context: Context) -> MessageTextView {
        // Need to use TextKit 1 for mentions
        let textView = MessageTextView(usingTextLayoutManager: false)
        textView.timelineContext = viewModel
        textView.allowsTextSelection = allowsTextSelection
        textView.updateClosure = { [weak textView] in
            guard let textView else { return }
            do {
                attributedString = try AttributedString(textView.attributedText, including: \.elementX)
            } catch {
                MXLog.error("Failed to update attributedString: \(error)]")
                return
            }
        }
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.adjustsFontForContentSizeCategory = true

        // Required to allow tapping links
        // We disable selection at delegate level
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true

        // Otherwise links can be dragged and dropped when long pressed
        textView.textDragInteraction?.isEnabled = false

        textView.contentInset = .zero
        textView.contentInsetAdjustmentBehavior = .never
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.layoutManager.usesFontLeading = false
        textView.backgroundColor = .clear
        if let attributedText = try? NSAttributedString(attributedString, including: \.elementX) {
            textView.attributedText = attributedText
        }
        textView.delegate = context.coordinator
        return textView
    }

    func updateUIView(_ uiView: MessageTextView, context: Context) {
        if let newAttributedText = try? NSAttributedString(attributedString, including: \.elementX),
           uiView.attributedText != newAttributedText {
            uiView.flushPills()
            uiView.attributedText = newAttributedText
        }
        context.coordinator.openURLAction = openURLAction
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: MessageTextView, context: Context) -> CGSize? {
        let proposalWidth = proposal.width ?? UIView.layoutFittingExpandedSize.width

        if let size = computedSizes[proposalWidth] {
            return size
        }

        // Only update text container if width changed (height should already be infinite)
        let textContainer = uiView.textContainer
        if textContainer.size.width != proposalWidth || textContainer.size.height != .greatestFiniteMagnitude {
            textContainer.size = CGSize(width: proposalWidth, height: .greatestFiniteMagnitude)
        }

        var size = uiView.sizeThatFits(CGSize(width: proposalWidth, height: UIView.layoutFittingCompressedSize.height))

        // Apply ceil to prevent clipping from rounding
        size.height = ceil(size.height)
        size.width = ceil(size.width)

        DispatchQueue.main.async {
            computedSizes[proposalWidth] = size
        }
        return size
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(openURLAction: openURLAction, allowsTextSelection: allowsTextSelection)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var openURLAction: OpenURLAction
        let allowsTextSelection: Bool

        init(openURLAction: OpenURLAction, allowsTextSelection: Bool) {
            self.openURLAction = openURLAction
            self.allowsTextSelection = allowsTextSelection
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            guard !allowsTextSelection, !ProcessInfo.processInfo.isiOSAppOnMac else {
                return
            }
            textView.selectedTextRange = nil
        }

        func textView(_ textView: UITextView, primaryActionFor textItem: UITextItem, defaultAction: UIAction) -> UIAction? {
            if case .link(let url) = textItem.content {
                return .init(title: defaultAction.title,
                             image: defaultAction.image,
                             discoverabilityTitle: defaultAction.discoverabilityTitle,
                             attributes: defaultAction.attributes,
                             state: defaultAction.state) { [weak self] _ in
                    self?.openURLAction.callAsFunction(url)
                }
            }
            return defaultAction
        }
                        
        func textView(_ textView: UITextView, menuConfigurationFor textItem: UITextItem, defaultMenu: UIMenu) -> UITextItem.MenuConfiguration? {
            switch textItem.content {
            case let .link(url):
                guard !url.requiresConfirmation else {
                    return nil
                }
                // We don't want to show a URL preview for permalinks
                let isPermalink = parseMatrixEntityFrom(uri: url.absoluteString) != nil
                return .init(preview: isPermalink ? nil : .default, menu: defaultMenu)
            default:
                return nil
            }
        }
    }
}

// MARK: - Previews

struct MessageText_Previews: PreviewProvider, TestablePreview {
    private static let defaultFontContainer: AttributeContainer = {
        var container = AttributeContainer()
        container.font = UIFont.preferredFont(forTextStyle: .body)
        return container
    }()
    
    private static let attributedString = AttributedString("Hello World! Hello world! Hello world! Hello world! Hello World! Hellooooooooooooooooooooooo Woooooooooooooooooooooorld", attributes: defaultFontContainer)
    
    private static let attributedStringWithAttachment: AttributedString = {
        let testData = PillTextAttachmentData(type: .user(userID: "@alice:example.com"), font: .preferredFont(forTextStyle: .body))
        guard let attachment = PillTextAttachment(attachmentData: testData) else {
            return AttributedString()
        }
        
        var attributedString = "Hello test test test " + AttributedString(NSAttributedString(attachment: attachment)) + " World!"
        attributedString
            .mergeAttributes(defaultFontContainer)
        return attributedString
    }()

    private static let htmlStringWithQuote =
        """
        <blockquote>A blockquote that is long and goes onto multiple lines as the first item in the message</blockquote>
        <p>Then another line of text here to reply to the blockquote, which is also a multiline component.</p>
        """
    
    private static let htmlStringWithList = "<p>This is a list</p>\n<ul>\n<li>One</li>\n<li>Two</li>\n<li>And number 3</li>\n</ul>\n"

    private static let attributedStringBuilder = AttributedStringBuilder(mentionBuilder: MentionBuilder())
    
    static var attachmentPreview: some View {
        MessageText(attributedString: attributedStringWithAttachment)
            .border(Color.purple)
            .environmentObject(TimelineViewModel.mock.context)
    }

    static var previews: some View {
        MessageText(attributedString: attributedString)
            .border(Color.purple)
            .previewDisplayName("Custom Text")
        // For comparison
        Text(attributedString)
            .border(Color.purple)
            .previewDisplayName("SwiftUI Default Text")
        attachmentPreview
            .previewDisplayName("Custom Attachment")
        if let attributedString = attributedStringBuilder.fromHTML(htmlStringWithQuote) {
            MessageText(attributedString: attributedString)
                .border(Color.purple)
                .previewDisplayName("With block quote")
        }
        if let attributedString = attributedStringBuilder.fromHTML(htmlStringWithList) {
            MessageText(attributedString: attributedString)
                .border(Color.purple)
                .previewDisplayName("With list")
        }
    }
}
