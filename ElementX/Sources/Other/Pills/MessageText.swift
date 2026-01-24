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

    /// Ensures any UIDragInteraction instances are removed when the view is added to a window to prevent text from being draggable.
    /// 
    /// This is invoked as part of the view lifecycle when the view moves to a window and removes drag interactions that would otherwise allow text movement.
    override func didMoveToWindow() {
        super.didMoveToWindow()
        // Remove all drag interactions to prevent text movement
        interactions.compactMap { $0 as? UIDragInteraction }.forEach { removeInteraction($0) }
    }

    /// Adds a gesture recognizer to the view. When running on iOS (not an iOS app on Mac), assigns `self` as the recognizer's delegate before adding it.
    /// - Parameter gestureRecognizer: The gesture recognizer to add to the view.
    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        // We don't need to change the behaviour on MacOS
        if !ProcessInfo.processInfo.isiOSAppOnMac {
            gestureRecognizer.delegate = self
        }
        super.addGestureRecognizer(gestureRecognizer)
    }

    /// Controls whether two gesture recognizers may be recognized simultaneously.
    /// 
    /// When `allowsTextSelection` is `true`, simultaneous recognition is permitted to enable long-press text selection. If `allowsTextSelection` is `false` and `otherGestureRecognizer` is a `UILongPressGestureRecognizer`, simultaneous recognition is disallowed to avoid conflicts; otherwise simultaneous recognition is permitted.
    /// - Parameters:
    ///   - gestureRecognizer: The primary gesture recognizer requesting simultaneous recognition.
    ///   - otherGestureRecognizer: The other gesture recognizer to evaluate for simultaneous recognition.
    /// - Returns: `true` if both gestures can be recognized at the same time, `false` otherwise.
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

    /// Removes all registered pill attachment views from the view hierarchy and clears the internal registry.
    /// 
    /// Each tracked pill view has its alpha set to 0.0 before being removed from its superview to ensure it is visually hidden.
    func flushPills() {
        for view in pillViews.allObjects {
            view.alpha = 0.0
            view.removeFromSuperview()
        }
        pillViews.removeAllObjects()
    }

    /// Copies the currently selected content to the system pasteboard as plain text when text selection is allowed; otherwise defers to the superclass copy behavior.
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

    /// Convert an attributed string containing pill attachments and links into a plain-text representation suitable for copying.
    /// 
    /// - For pill attachments, replaces the attachment with the result of `pillDisplayText(for:)`.
    /// - For links, if the visible display text does not match the URL, replaces the range with `"[display](url)"`; otherwise leaves the display text as-is.
    /// - Preserves other text untouched.
    /// - Parameter attributedString: The source attributed string to convert.
    /// - Returns: A plain `String` with attachments and link ranges replaced as described above.
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

    /// Checks whether the provided display text corresponds to the given URL after normalizing common URL schemes and trimming leading/trailing slashes.
    /// - Parameters:
    ///   - displayText: The visible text shown for a link (may be a shortened or formatted form of the URL).
    ///   - urlString: The URL string to compare against.
    /// - Returns: `true` if `displayText` is exactly equal to `urlString` or equal to `urlString` after removing an `http://`/`https://` scheme and any surrounding `/` characters, `false` otherwise.
    private func isDisplayTextMatchingURL(_ displayText: String, urlString: String) -> Bool {
        let normalizedDisplay = displayText.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let normalizedURL = urlString
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        return displayText == urlString || normalizedDisplay == normalizedURL
    }

    /// Maps a pill attachment's data to the string that should be shown or copied for that pill.
    /// 
    /// For a user pill, returns the room member's display name when available via `timelineContext.viewState.members`, otherwise the user's ID. For an @allUsers pill returns `"room"`. For room alias or room ID pills returns the alias or ID respectively. For an event-targeted pill returns the contained room alias or room ID.
    /// - Parameter pillData: The pill attachment data to derive display text from.
    /// - Returns: The text to display for the given pill.
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

    /// Creates and configures a `MessageTextView` for use in SwiftUI.
    /// - Parameter context: The `UIViewRepresentable` context provided when creating the view.
    /// - Returns: A configured `MessageTextView` prepared to render attributed message content, handle links and pill attachments, and respect the view's selection policy.
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

    /// Compute the fitting size for `uiView` given a proposed size and cache the result keyed by width.
    /// - Parameters:
    ///   - proposal: The proposed size used to determine the target width; if `nil` for width, an expanded width is used.
    ///   - uiView: The `MessageTextView` whose size is being measured.
    ///   - context: The view context (unused for calculation).
    /// - Returns: The computed `CGSize` that best fits the view for the given proposal; width and height are rounded up to avoid clipping.
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

    /// Creates the coordinator used as the UITextView delegate and action handler for this representable.
    /// - Returns: A `Coordinator` initialized with the view's `openURLAction` and current `allowsTextSelection` setting.
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

        /// Clears the current selection in the provided text view when text selection is disabled on iOS devices.
        /// If text selection is enabled or the app is running as an iOS app on Mac, the selection is left unchanged.
        /// - Parameter textView: The `UITextView` whose selection will be cleared.
        func textViewDidChangeSelection(_ textView: UITextView) {
            guard !allowsTextSelection, !ProcessInfo.processInfo.isiOSAppOnMac else {
                return
            }
            textView.selectedTextRange = nil
        }

        /// Provide the primary action to perform for a given text item, substituting link taps with an action that opens the URL using the view's `openURLAction`.
        /// - Parameters:
        ///   - textView: The text view containing the item.
        ///   - textItem: The text item for which the primary action is requested; may contain a `.link` content with a URL.
        ///   - defaultAction: The default action to use when no custom action is required.
        /// - Returns: The `UIAction` to execute for the text item. For `.link` content, an action that calls `openURLAction` with the URL; otherwise the provided `defaultAction`.
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