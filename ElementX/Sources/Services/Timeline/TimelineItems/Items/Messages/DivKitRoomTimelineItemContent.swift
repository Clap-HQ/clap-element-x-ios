//
// Copyright 2025 Clap Inc.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

struct DivKitRoomTimelineItemContent: Hashable {
    let cardData: Data
    let fallbackText: String
    let messageType: DivKitMessageType
    let requestID: String?
    let version: String
    let cardLogID: String?
}

enum DivKitMessageType: String, Hashable {
    case thinking = "thinking"
    case planApproval = "plan_approval"
    case toolApproval = "tool_approval"
    case toolResult = "tool_result"
    case selection = "selection"
    case finalResult = "final_result"
    case error = "error"
    case cancelled = "cancelled"
    case unknown

    var requiresUserResponse: Bool {
        switch self {
        case .planApproval, .toolApproval, .selection:
            return true
        default:
            return false
        }
    }
}
