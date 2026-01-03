//
// Copyright 2025 Element Creations Ltd.
// Copyright 2022-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import Foundation
import UIKit

enum HomeScreenViewModelAction {
    case presentRoom(roomIdentifier: String)
    case presentRoomDetails(roomIdentifier: String)
    case presentReportRoom(roomIdentifier: String)
    case presentDeclineAndBlock(userID: String, roomID: String)
    case presentSpace(SpaceRoomListProxyProtocol)
    case presentSpaceRoomList(SpaceRoomListProxyProtocol)
    case roomLeft(roomIdentifier: String)
    case transferOwnership(roomIdentifier: String)
    case presentSecureBackupSettings
    case presentRecoveryKeyScreen
    case presentEncryptionResetScreen
    case presentSettingsScreen
    case presentFeedbackScreen
    case presentStartChatScreen
    case presentGlobalSearch
    case logout
}

enum HomeScreenViewAction {
    case selectRoom(roomIdentifier: String)
    case selectSpace(spaceID: String)
    case showRoomDetails(roomIdentifier: String)
    case leaveRoom(roomIdentifier: String)
    case confirmLeaveRoom(roomIdentifier: String)
    case reportRoom(roomIdentifier: String)
    case showSettings
    case startChat
    case setupRecovery
    case confirmRecoveryKey
    case resetEncryption
    case skipRecoveryKeyConfirmation
    case dismissNewSoundBanner
    case updateVisibleItemRange(Range<Int>)
    case globalSearch
    case markRoomAsUnread(roomIdentifier: String)
    case markRoomAsRead(roomIdentifier: String)
    case markRoomAsFavourite(roomIdentifier: String, isFavourite: Bool)

    case acceptInvite(roomIdentifier: String)
    case declineInvite(roomIdentifier: String)
}

enum HomeScreenRoomListMode: CustomStringConvertible {
    case skeletons
    case empty
    case rooms
    
    var description: String {
        switch self {
        case .skeletons:
            return "Showing placeholders"
        case .empty:
            return "Showing empty state"
        case .rooms:
            return "Showing rooms"
        }
    }
}

enum HomeScreenSecurityBannerMode: Equatable {
    case none
    case dismissed
    case show(HomeScreenRecoveryKeyConfirmationBanner.State)
    
    var isDismissed: Bool {
        switch self {
        case .dismissed: true
        default: false
        }
    }
    
    var isShown: Bool {
        switch self {
        case .show: true
        default: false
        }
    }
}

struct HomeScreenViewState: BindableState {
    let userID: String
    var userDisplayName: String?
    var userAvatarURL: URL?

    var securityBannerMode = HomeScreenSecurityBannerMode.none
    var shouldShowNewSoundBanner = false

    var requiresExtraAccountSetup = false

    var rooms: [HomeScreenRoom] = []
    var spaces: [HomeScreenSpace] = []
    var roomListMode: HomeScreenRoomListMode = .skeletons

    var hasPendingInvitations = false

    var selectedRoomID: String?

    var hideInviteAvatars = false

    var reportRoomEnabled = false

    /// Combined list of rooms and spaces for display, sorted by last message date
    var visibleItems: [HomeScreenListItem] {
        if roomListMode == .skeletons {
            return placeholderRooms.map { .room($0) }
        }

        // When searching, show only rooms (no spaces)
        if bindings.isSearchFieldFocused {
            return rooms.map { .room($0) }
        }

        // When Spaces filter is active, show only spaces sorted by last message date
        if bindings.filtersState.isSpacesFilterActive {
            return spaces
                .map { HomeScreenListItem.space($0) }
                .sorted { lhs, rhs in
                    let lhsDate = lhs.lastMessageDate ?? .distantPast
                    let rhsDate = rhs.lastMessageDate ?? .distantPast
                    return lhsDate > rhsDate
                }
        }

        // When secondary filters are active (unreads, people, rooms, etc.), show only filtered rooms
        if bindings.filtersState.isFiltering {
            return rooms.map { .room($0) }
        }

        // When All filter is active (default), combine spaces and rooms sorted by last message date
        let spaceItems = spaces.map { HomeScreenListItem.space($0) }
        let roomItems = rooms.map { HomeScreenListItem.room($0) }
        let allItems = spaceItems + roomItems

        return allItems.sorted { lhs, rhs in
            let lhsDate = lhs.lastMessageDate ?? .distantPast
            let rhsDate = rhs.lastMessageDate ?? .distantPast
            return lhsDate > rhsDate
        }
    }

    var visibleRooms: [HomeScreenRoom] {
        if roomListMode == .skeletons {
            return placeholderRooms
        }

        return rooms
    }

    var bindings: HomeScreenViewStateBindings

    var placeholderRooms: [HomeScreenRoom] {
        (1...10).map { _ in
            HomeScreenRoom.placeholder()
        }
    }

    // Used to hide all the rooms when the search field is focused and the query is empty
    var shouldHideRoomList: Bool {
        bindings.isSearchFieldFocused && bindings.searchQuery.isEmpty
    }

    var shouldShowEmptyFilterState: Bool {
        guard !bindings.isSearchFieldFocused else { return false }

        // Show empty state when Spaces filter is active and no spaces
        if bindings.filtersState.isSpacesFilterActive {
            return spaces.isEmpty
        }

        // Show empty state when secondary filters are active and no rooms match
        return bindings.filtersState.isFiltering && visibleRooms.isEmpty
    }

    var shouldShowFilters: Bool {
        !bindings.isSearchFieldFocused && roomListMode == .rooms
    }

    var shouldShowBanner: Bool {
        securityBannerMode.isShown || shouldShowNewSoundBanner
    }
}

struct HomeScreenViewStateBindings {
    var filtersState: RoomListFiltersState
    var searchQuery = ""
    var isSearchFieldFocused = false
    
    var alertInfo: AlertInfo<UUID>?
    var leaveRoomAlertItem: LeaveRoomAlertItem?
}

struct HomeScreenRoom: Identifiable, Equatable {
    enum RoomType: Equatable {
        case placeholder
        case room
        case invite(inviterDetails: RoomInviterDetails?)
        case knock
    }
    
    static let placeholderLastMessage = AttributedString("Hidden last message")
        
    /// The list item identifier is it's room identifier.
    let id: String
    
    /// The real room identifier this item points to
    let roomID: String?
    
    let type: RoomType
    
    var inviter: RoomInviterDetails? {
        if case .invite(let inviter) = type {
            return inviter
        }
        return nil
    }
    
    let badges: Badges
    struct Badges: Equatable {
        let isDotShown: Bool
        let isMentionShown: Bool
        let isMuteShown: Bool
        let isCallShown: Bool
    }
    
    let name: String

    let memberCount: Int

    let isDirect: Bool

    var isDirectOneToOneRoom: Bool {
        isDirect && memberCount <= 2
    }

    let isHighlighted: Bool
    
    let isFavourite: Bool
    
    let timestamp: String?

    let lastMessageDate: Date?

    let lastMessage: AttributedString?

    enum LastMessageState { case sending, failed }
    let lastMessageState: LastMessageState?
    
    let avatar: RoomAvatar
        
    let canonicalAlias: String?
    
    let isTombstoned: Bool
    
    var displayedLastMessage: AttributedString? {
        if isTombstoned {
            AttributedString(L10n.screenRoomlistTombstonedRoomDescription)
        } else if lastMessageState == .failed {
            AttributedString(L10n.commonMessageFailedToSend)
        } else {
            lastMessage
        }
    }
    
    static func placeholder() -> HomeScreenRoom {
        HomeScreenRoom(id: UUID().uuidString,
                       roomID: nil,
                       type: .placeholder,
                       badges: .init(isDotShown: false, isMentionShown: false, isMuteShown: false, isCallShown: false),
                       name: "Placeholder room name",
                       memberCount: 0,
                       isDirect: false,
                       isHighlighted: false,
                       isFavourite: false,
                       timestamp: "Now",
                       lastMessageDate: nil,
                       lastMessage: placeholderLastMessage,
                       lastMessageState: nil,
                       avatar: .room(id: "", name: "", avatarURL: nil),
                       canonicalAlias: nil,
                       isTombstoned: false)
    }
}

extension HomeScreenRoom {
    init(summary: RoomSummary, hideUnreadMessagesBadge: Bool, seenInvites: Set<String> = []) {
        let roomID = summary.id
        
        let hasUnreadMessages = hideUnreadMessagesBadge ? false : summary.hasUnreadMessages
        let isUnseenInvite = summary.joinRequestType?.isInvite == true && !seenInvites.contains(roomID)

        let isDotShown = hasUnreadMessages || summary.hasUnreadMentions || summary.hasUnreadNotifications || summary.isMarkedUnread || isUnseenInvite
        let isMentionShown = summary.hasUnreadMentions && !summary.isMuted
        let isMuteShown = summary.isMuted
        let isCallShown = summary.hasOngoingCall
        let isHighlighted = summary.isMarkedUnread || (!summary.isMuted && (summary.hasUnreadNotifications || summary.hasUnreadMentions)) || isUnseenInvite
        
        let type: HomeScreenRoom.RoomType = switch summary.joinRequestType {
        case .invite(let inviter): .invite(inviterDetails: inviter.map(RoomInviterDetails.init))
        case .knock: .knock
        case .none: .room
        }
        
        self.init(id: roomID,
                  roomID: summary.id,
                  type: type,
                  badges: .init(isDotShown: isDotShown,
                                isMentionShown: isMentionShown,
                                isMuteShown: isMuteShown,
                                isCallShown: isCallShown),
                  name: summary.name,
                  memberCount: Int(summary.activeMembersCount),
                  isDirect: summary.isDirect,
                  isHighlighted: isHighlighted,
                  isFavourite: summary.isFavourite,
                  timestamp: summary.lastMessageDate?.formattedMinimal(),
                  lastMessageDate: summary.lastMessageDate,
                  lastMessage: summary.lastMessage,
                  lastMessageState: summary.homeScreenLastMessageState,
                  avatar: summary.avatar,
                  canonicalAlias: summary.canonicalAlias,
                  isTombstoned: summary.isTombstoned)
    }
}

private extension RoomSummary {
    var homeScreenLastMessageState: HomeScreenRoom.LastMessageState? {
        if isTombstoned {
            nil
        } else {
            switch lastMessageState {
            case .sending: .sending
            case .failed: .failed
            case .none: .none
            }
        }
    }
}

// MARK: - HomeScreenSpace

struct HomeScreenSpace: Identifiable, Equatable {
    let id: String
    let name: String
    let avatarURL: URL?
    let memberCount: Int
    let childrenCount: Int

    /// The most recent message date among all joined child rooms (for sorting)
    let lastMessageDate: Date?

    /// The formatted timestamp of the most recent message (e.g., "Now", "2m", "Yesterday")
    let timestamp: String?

    /// The last message content from the most recent child room
    let lastMessage: AttributedString?

    /// The name of the room that has the most recent message
    let lastMessageRoomName: String?

    /// Badge information aggregated from child rooms
    let badges: Badges
    struct Badges: Equatable {
        let isDotShown: Bool
        let isMentionShown: Bool
        let isMuteShown: Bool
    }

    /// Whether this space has unread notifications (for highlighting)
    let isHighlighted: Bool

    var avatar: RoomAvatar {
        .space(id: id, name: name, avatarURL: avatarURL)
    }

    init(spaceProxy: SpaceRoomProxyProtocol,
         lastMessageDate: Date? = nil,
         timestamp: String? = nil,
         lastMessage: AttributedString? = nil,
         lastMessageRoomName: String? = nil,
         badges: Badges = .init(isDotShown: false, isMentionShown: false, isMuteShown: false),
         isHighlighted: Bool = false) {
        self.id = spaceProxy.id
        self.name = spaceProxy.name
        self.avatarURL = spaceProxy.avatarURL
        self.memberCount = spaceProxy.joinedMembersCount
        self.childrenCount = spaceProxy.childrenCount
        self.lastMessageDate = lastMessageDate
        self.timestamp = timestamp
        self.lastMessage = lastMessage
        self.lastMessageRoomName = lastMessageRoomName
        self.badges = badges
        self.isHighlighted = isHighlighted
    }

    init(id: String, name: String, avatarURL: URL?, memberCount: Int, childrenCount: Int,
         lastMessageDate: Date? = nil,
         timestamp: String? = nil,
         lastMessage: AttributedString? = nil,
         lastMessageRoomName: String? = nil,
         badges: Badges = .init(isDotShown: false, isMentionShown: false, isMuteShown: false),
         isHighlighted: Bool = false) {
        self.id = id
        self.name = name
        self.avatarURL = avatarURL
        self.memberCount = memberCount
        self.childrenCount = childrenCount
        self.lastMessageDate = lastMessageDate
        self.timestamp = timestamp
        self.lastMessage = lastMessage
        self.lastMessageRoomName = lastMessageRoomName
        self.badges = badges
        self.isHighlighted = isHighlighted
    }
}

// MARK: - HomeScreenListItem

enum HomeScreenListItem: Identifiable, Equatable {
    case room(HomeScreenRoom)
    case space(HomeScreenSpace)

    var id: String {
        switch self {
        case .room(let room): "room-\(room.id)"
        case .space(let space): "space-\(space.id)"
        }
    }

    /// The last message date for sorting (rooms and spaces together)
    var lastMessageDate: Date? {
        switch self {
        case .room(let room): room.lastMessageDate
        case .space(let space): space.lastMessageDate
        }
    }
}
