//
// Copyright 2025 Clap.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

// MARK: - Environment Key

private struct TimelineBubbleIsOutgoingKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    /// Indicates whether the current bubble is an outgoing message.
    var timelineBubbleIsOutgoing: Bool {
        get { self[TimelineBubbleIsOutgoingKey.self] }
        set { self[TimelineBubbleIsOutgoingKey.self] = newValue }
    }
}

// MARK: - View Modifier

extension View {
    /// Sets the bubble style context for the view hierarchy.
    /// Call this once at the bubble's root to propagate the outgoing state to all children.
    func timelineBubbleStyle(isOutgoing: Bool) -> some View {
        environment(\.timelineBubbleIsOutgoing, isOutgoing)
    }
}

// MARK: - Color Helpers

extension CompoundColors {
    /// Returns the appropriate text color for bubble content based on outgoing state.
    public func textBubble(isOutgoing: Bool) -> Color {
        isOutgoing ? _textBubbleOutgoing : _textBubbleIncoming
    }
    
    /// Returns the appropriate secondary text color for bubble content based on outgoing state.
    public func textBubbleSecondary(isOutgoing: Bool) -> Color {
        isOutgoing ? _textBubbleSecondaryOutgoing : _textBubbleSecondaryIncoming
    }
    
    /// Returns the appropriate icon color for bubble content based on outgoing state.
    public func iconBubble(isOutgoing: Bool) -> Color {
        isOutgoing ? _iconBubbleOutgoing : _iconBubbleIncoming
    }
}

extension CompoundUIColors {
    /// Returns the appropriate text color for bubble content based on outgoing state.
    public func textBubble(isOutgoing: Bool) -> UIColor {
        isOutgoing ? _textBubbleOutgoing : _textBubbleIncoming
    }
    
    /// Returns the appropriate secondary text color for bubble content based on outgoing state.
    public func textBubbleSecondary(isOutgoing: Bool) -> UIColor {
        isOutgoing ? _textBubbleSecondaryOutgoing : _textBubbleSecondaryIncoming
    }
    
    /// Returns the appropriate icon color for bubble content based on outgoing state.
    public func iconBubble(isOutgoing: Bool) -> UIColor {
        isOutgoing ? _iconBubbleOutgoing : _iconBubbleIncoming
    }
}
