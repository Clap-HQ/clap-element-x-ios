//
// Copyright 2025 Element Creations Ltd.
// Copyright 2024-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

extension View {
    /// - Parameters:
    ///   - isOutgoing: indicates if this is an outgoing message, defaults to true
    ///   - insets: defaults to what we use for file timeline items, text uses custom values
    ///   - color: self explanatory, defaults to subtle secondary
    func bubbleBackground(isOutgoing: Bool = true,
                          insets: EdgeInsets = .init(top: 10, leading: 12, bottom: 10, trailing: 12),
                          color: Color? = .compound.bgSubtleSecondary) -> some View {
        modifier(TimelineItemBubbleBackgroundModifier(isOutgoing: isOutgoing,
                                                      insets: insets,
                                                      color: color))
    }
}

private struct TimelineItemBubbleBackgroundModifier: ViewModifier {
    @Environment(\.timelineGroupStyle) private var timelineGroupStyle
    
    let isOutgoing: Bool
    let insets: EdgeInsets
    var color: Color?

    func body(content: Content) -> some View {
        content
            .padding(insets)
            .background(color)
            .cornerRadius(20, corners: roundedCorners)
    }
    
    private var roundedCorners: UIRectCorner {
        switch timelineGroupStyle {
        case .single:
            return .allCorners
        case .first:
            return .allCorners
        case .middle:
            return .allCorners
        case .last:
            return .allCorners
        }
    }
}
