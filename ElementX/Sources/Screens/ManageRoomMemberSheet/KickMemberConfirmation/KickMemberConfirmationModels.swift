//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Foundation

enum KickMemberConfirmationViewAction {
    case confirm
    case cancel
    case toggleRemoveFromAllRooms
}

struct KickMemberConfirmationViewState: BindableState {
    let memberID: String
    let memberName: String?
    var removeFromAllRooms: Bool = true

    var title: String {
        L10n.screenBottomSheetManageRoomMemberKickMemberConfirmationTitle
    }

    var subtitle: String {
        L10n.screenBottomSheetManageRoomMemberKickMemberFromSpaceConfirmationDescription
    }

    var confirmButtonTitle: String {
        L10n.screenBottomSheetManageRoomMemberKickMemberConfirmationAction
    }
}

enum KickMemberConfirmationViewModelAction {
    case confirm(removeFromAllRooms: Bool)
    case cancel
}
