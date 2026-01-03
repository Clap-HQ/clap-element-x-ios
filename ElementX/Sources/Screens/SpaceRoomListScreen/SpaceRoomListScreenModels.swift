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
    case joined(JoinedRoomInfo)
    /// An unjoined room with join button
    case unjoined(SpaceRoomProxyProtocol)

    var id: String {
        switch self {
        case .joined(let info): info.id
        case .unjoined(let proxy): proxy.id
        }
    }

    var name: String {
        switch self {
        case .joined(let info): info.name
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

/// Info for a joined room, similar to HomeScreenRoom but simplified
struct JoinedRoomInfo: Identifiable, Equatable {
    let id: String
    let name: String
    let avatar: RoomAvatar
    let memberCount: Int
    let lastMessage: AttributedString?
    let timestamp: String?
    let lastMessageDate: Date?
    let isDirect: Bool

    let badges: Badges
    struct Badges: Equatable {
        let isDotShown: Bool
        let isMentionShown: Bool
        let isMuteShown: Bool
        let isCallShown: Bool
    }

    let isHighlighted: Bool
    let isFavourite: Bool

    init(summary: RoomSummary, hideUnreadMessagesBadge: Bool = false) {
        self.id = summary.id
        self.name = summary.name
        self.avatar = summary.avatar
        self.memberCount = Int(summary.activeMembersCount)
        self.lastMessage = summary.lastMessage
        self.timestamp = summary.lastMessageDate?.formattedMinimal()
        self.lastMessageDate = summary.lastMessageDate
        self.isDirect = summary.isDirect
        self.isFavourite = summary.isFavourite

        let hasUnreadMessages = hideUnreadMessagesBadge ? false : summary.hasUnreadMessages
        let isDotShown = hasUnreadMessages || summary.hasUnreadMentions || summary.hasUnreadNotifications || summary.isMarkedUnread
        let isMentionShown = summary.hasUnreadMentions && !summary.isMuted
        let isMuteShown = summary.isMuted
        let isCallShown = summary.hasOngoingCall
        let isHighlighted = summary.isMarkedUnread || (!summary.isMuted && (summary.hasUnreadNotifications || summary.hasUnreadMentions))

        self.badges = Badges(isDotShown: isDotShown, isMentionShown: isMentionShown, isMuteShown: isMuteShown, isCallShown: isCallShown)
        self.isHighlighted = isHighlighted
    }

    init(id: String, name: String, avatar: RoomAvatar, memberCount: Int, lastMessage: AttributedString?, timestamp: String?, lastMessageDate: Date?, isDirect: Bool, badges: Badges, isHighlighted: Bool, isFavourite: Bool) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.memberCount = memberCount
        self.lastMessage = lastMessage
        self.timestamp = timestamp
        self.lastMessageDate = lastMessageDate
        self.isDirect = isDirect
        self.badges = badges
        self.isHighlighted = isHighlighted
        self.isFavourite = isFavourite
    }
}
