//
// Copyright 2025 Clap Communications Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

enum AgentScreenViewModelAction {
    case dismiss
}

struct AgentScreenViewState: BindableState {
    var roomTitle: String
    var roomAvatar: RoomAvatar
    var canSendMessage = true
    
    var bindings = AgentScreenViewStateBindings()
}

struct AgentScreenViewStateBindings {
    /// The view model used to present a QuickLook media preview.
    var mediaPreviewViewModel: TimelineMediaPreviewViewModel?
}

enum AgentScreenViewAction {
    case dismiss
}
