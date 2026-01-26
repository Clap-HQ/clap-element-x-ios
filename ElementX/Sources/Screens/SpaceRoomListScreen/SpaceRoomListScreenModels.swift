//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import Foundation

enum SpaceRoomListScreenViewModelAction {
    case selectRoom(roomID: String)
    case showRoomDetails(roomID: String)
    case dismiss
    case displayMembers(roomProxy: JoinedRoomProxyProtocol)
    case inviteUsers(roomProxy: JoinedRoomProxyProtocol)
    case displaySpaceSettings(roomProxy: JoinedRoomProxyProtocol)
    case leftSpace
}

enum SpaceRoomListScreenViewAction {
    case selectRoom(SpaceRoomListItem)
    case joinRoom(SpaceRoomProxyProtocol)
    case showRoomDetails(roomID: String)
    case markAsRead(roomID: String)
    case markAsUnread(roomID: String)
    case markAsFavourite(roomID: String, isFavourite: Bool)
    case leaveRoom(roomID: String)
    // Space menu actions
    case displayMembers
    case inviteUsers
    case spaceSettings
    case leaveSpace
}

struct SpaceRoomListScreenViewState: BindableState {
    let spaceID: String
    var spaceName: String
    var spaceAvatarURL: URL?
    var spaceMemberCount: Int
    var spaceTopic: String?

    var joinedRooms: [SpaceRoomListItem] = []
    var unjoinedRooms: [SpaceRoomListItem] = []
    var joiningRoomIDs: Set<String> = []

    // Space menu properties
    var permalink: URL?
    var roomProxy: JoinedRoomProxyProtocol?
    var canEditBaseInfo = false
    var canEditRolesAndPermissions = false
    var canManageSpaceChildren = false
    var canInviteUsers = false

    var isSpaceManagementEnabled: Bool {
        canEditBaseInfo || canEditRolesAndPermissions
    }

    var bindings = SpaceRoomListScreenViewStateBindings()

    var spaceAvatar: RoomAvatar {
        .space(id: spaceID, name: spaceName, avatarURL: spaceAvatarURL)
    }

    var hasJoinedRooms: Bool {
        !joinedRooms.isEmpty
    }

    var hasUnjoinedRooms: Bool {
        !unjoinedRooms.isEmpty
    }
}

struct SpaceRoomListScreenViewStateBindings {
    var leaveSpaceViewModel: LeaveSpaceViewModel?
}

/// An item in the space room list
enum SpaceRoomListItem: Identifiable, Equatable {
    /// A joined room with chat-list style display (shows last message, timestamp, etc.)
    /// Uses HomeScreenRoom for consistency with the main room list
    case joined(HomeScreenRoom)
    /// An unjoined room with join button
    case unjoined(SpaceRoomProxyProtocol)

    var id: String {
        switch self {
        case .joined(let room): room.id
        case .unjoined(let proxy): proxy.id
        }
    }

    var name: String {
        switch self {
        case .joined(let room): room.name
        case .unjoined(let proxy): proxy.name
        }
    }

    var isJoined: Bool {
        switch self {
        case .joined: true
        case .unjoined: false
        }
    }

    static func == (lhs: SpaceRoomListItem, rhs: SpaceRoomListItem) -> Bool {
        lhs.id == rhs.id
    }
}
