//
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import Foundation
import SwiftUI

/// Room visibility options when creating a room in a space
/// Matches Element Web's options
enum SpaceRoomVisibility: String, CaseIterable, Identifiable {
    /// Visible to space members only (restricted join rule)
    /// Anyone in the space can find and join
    case spaceMembers
    /// Private room (invite only)
    case privateRoom
    /// Public room (anyone can join)
    case publicRoom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .spaceMembers:
            return L10n.screenSpaceCreateRoomVisibilitySpaceMembersTitle
        case .privateRoom:
            return L10n.screenSpaceCreateRoomVisibilityPrivateTitle
        case .publicRoom:
            return L10n.screenSpaceCreateRoomVisibilityPublicTitle
        }
    }

    var icon: KeyPath<CompoundIcons, Image> {
        switch self {
        case .spaceMembers:
            return \.userProfile
        case .privateRoom:
            return \.lock
        case .publicRoom:
            return \.public
        }
    }
}

enum CreateRoomInSpaceScreenErrorType: Error {
    case failedCreatingRoom
    case failedUploadingMedia
    case fileTooLarge
    case mediaFileError
    case unknown
}

enum CreateRoomInSpaceScreenViewModelAction {
    case createdRoom(roomID: String)
    case dismiss
    case displayMediaPicker
    case displayCameraPicker
}

struct CreateRoomInSpaceScreenViewState: BindableState {
    let spaceID: String
    let spaceName: String
    var bindings: CreateRoomInSpaceScreenViewStateBindings
    var avatarURL: URL?
    var isCreating = false

    var canCreateRoom: Bool {
        !bindings.roomName.isEmpty && !isCreating
    }

    /// Whether encryption toggle should be shown (only for non-public rooms)
    var showEncryptionToggle: Bool {
        bindings.visibility != .publicRoom
    }

    /// Description text for the selected visibility option
    var visibilityDescription: String {
        switch bindings.visibility {
        case .spaceMembers:
            return L10n.screenSpaceCreateRoomVisibilitySpaceMembersDescription(spaceName)
        case .privateRoom:
            return L10n.screenSpaceCreateRoomVisibilityPrivateDescription
        case .publicRoom:
            return L10n.screenSpaceCreateRoomVisibilityPublicDescription
        }
    }
}

struct CreateRoomInSpaceScreenViewStateBindings {
    var roomName: String
    var roomTopic: String
    var visibility: SpaceRoomVisibility
    var isEncrypted: Bool
    var showAttachmentConfirmationDialog = false
    var alertInfo: AlertInfo<CreateRoomInSpaceScreenErrorType>?
}

enum CreateRoomInSpaceScreenViewAction {
    case createRoom
    case displayCameraPicker
    case displayMediaPicker
    case removeImage
    case dismiss
}
