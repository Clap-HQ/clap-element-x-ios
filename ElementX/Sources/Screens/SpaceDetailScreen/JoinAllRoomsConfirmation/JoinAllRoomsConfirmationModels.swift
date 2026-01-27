//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

enum JoinAllRoomsConfirmationViewAction {
    case confirm
    case cancel
}

struct JoinAllRoomsConfirmationViewState: BindableState {
    let spaceID: String
    let spaceName: String
}

enum JoinAllRoomsConfirmationViewModelAction {
    case confirm
    case cancel
}
