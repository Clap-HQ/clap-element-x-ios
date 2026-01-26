//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

/// A cell for displaying a joined room in the space room list.
/// This mimics the HomeScreenRoomCell style, showing last message, timestamp, badges, etc.
struct SpaceRoomJoinedCell: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    let room: HomeScreenRoom
    let isSelected: Bool
    let mediaProvider: MediaProviderProtocol?
    let action: () -> Void

    private let verticalInsets = 12.0
    private let horizontalInsets = 16.0

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16.0) {
                avatar

                content
                    .padding(.vertical, verticalInsets)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Color.compound.borderDisabled)
                            .frame(height: 1 / UIScreen.main.scale)
                            .padding(.trailing, -horizontalInsets)
                    }
            }
            .padding(.horizontal, horizontalInsets)
            .accessibilityElement(children: .combine)
        }
        .buttonStyle(HomeScreenRoomCellButtonStyle(isSelected: isSelected))
        .accessibilityIdentifier(A11yIdentifiers.homeScreen.roomName(room.name))
    }

    @ViewBuilder @MainActor
    private var avatar: some View {
        if dynamicTypeSize < .accessibility3 {
            RoomAvatarImage(avatar: room.avatar,
                            avatarSize: .room(on: .chats),
                            mediaProvider: mediaProvider)
                .dynamicTypeSize(dynamicTypeSize < .accessibility1 ? dynamicTypeSize : .accessibility1)
                .accessibilityHidden(true)
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 2) {
            header
            footer
        }
    }

    @ViewBuilder
    private var header: some View {
        HStack(alignment: .top, spacing: 16) {
            HStack(spacing: 4) {
                Text(room.name)
                    .font(.compound.bodyLGSemibold)
                    .foregroundColor(.compound.textPrimary)
                    .lineLimit(1)

                if !room.isDirect, room.memberCount > 0 {
                    Text("\(room.memberCount)")
                        .font(.compound.bodyMD)
                        .foregroundColor(.compound.textSecondary)
                        .lineLimit(1)
                }

                if room.isFavourite {
                    CompoundIcon(\.favouriteSolid, size: .xSmall, relativeTo: .compound.bodyLGSemibold)
                        .foregroundColor(.compound.iconSecondary)
                        .accessibilityLabel(L10n.commonFavourited)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let timestamp = room.timestamp {
                Text(timestamp)
                    .font(room.isHighlighted ? .compound.bodySMSemibold : .compound.bodySM)
                    .foregroundColor(room.isHighlighted ? .compound.textActionAccent : .compound.textSecondary)
            }
        }
    }

    @ViewBuilder
    private var footer: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            ZStack(alignment: .topLeading) {
                // Hidden text with 2 lines to maintain consistent height
                Text(" \n ")
                    .font(.compound.bodyMD)
                    .foregroundColor(.compound.textSecondary)
                    .hidden()

                if let lastMessage = room.lastMessage {
                    Text(lastMessage)
                        .font(.compound.bodyMD)
                        .foregroundColor(.compound.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }

            Spacer()

            HStack(spacing: 8) {
                if room.badges.isCallShown {
                    CompoundIcon(\.videoCallSolid, size: .xSmall, relativeTo: .compound.bodySM)
                        .accessibilityLabel(L10n.a11yNotificationsOngoingCall)
                }

                if room.badges.isMuteShown {
                    CompoundIcon(\.notificationsOffSolid, size: .custom(15), relativeTo: .compound.bodyMD)
                        .accessibilityLabel(L10n.a11yNotificationsMuted)
                }

                if room.badges.isMentionShown {
                    CompoundIcon(\.mention, size: .custom(15), relativeTo: .compound.bodyMD)
                        .accessibilityLabel(L10n.a11yNotificationsNewMentions)
                }

                if room.badges.isDotShown {
                    Circle()
                        .frame(width: 12, height: 12)
                        .accessibilityLabel(L10n.a11yNotificationsNewMessages)
                }
            }
            .foregroundColor(room.isHighlighted ? .compound.iconAccentTertiary : .compound.iconQuaternary)
        }
    }
}

// MARK: - Previews

struct SpaceRoomJoinedCell_Previews: PreviewProvider, TestablePreview {
    static let mediaProvider = MediaProviderMock(configuration: .init())

    static var previews: some View {
        VStack(spacing: 0) {
            SpaceRoomJoinedCell(
                room: HomeScreenRoom(
                    id: "!room1:matrix.org",
                    roomID: "!room1:matrix.org",
                    type: .room,
                    badges: .init(isDotShown: true, isMentionShown: false, isMuteShown: false, isCallShown: false),
                    name: "General",
                    memberCount: 25,
                    isDirect: false,
                    isHighlighted: true,
                    isFavourite: false,
                    timestamp: "2:30 PM",
                    lastMessageDate: nil,
                    lastMessage: AttributedString("Hello everyone! How are you doing today?"),
                    lastMessageState: nil,
                    avatar: .room(id: "!room1:matrix.org", name: "General", avatarURL: nil),
                    canonicalAlias: nil,
                    isTombstoned: false,
                    isSpaceChild: true
                ),
                isSelected: false,
                mediaProvider: mediaProvider
            ) { }

            SpaceRoomJoinedCell(
                room: HomeScreenRoom(
                    id: "!room2:matrix.org",
                    roomID: "!room2:matrix.org",
                    type: .room,
                    badges: .init(isDotShown: false, isMentionShown: false, isMuteShown: true, isCallShown: false),
                    name: "Random",
                    memberCount: 15,
                    isDirect: false,
                    isHighlighted: false,
                    isFavourite: true,
                    timestamp: "Yesterday",
                    lastMessageDate: nil,
                    lastMessage: AttributedString("Just sharing some random thoughts here."),
                    lastMessageState: nil,
                    avatar: .room(id: "!room2:matrix.org", name: "Random", avatarURL: nil),
                    canonicalAlias: nil,
                    isTombstoned: false,
                    isSpaceChild: true
                ),
                isSelected: false,
                mediaProvider: mediaProvider
            ) { }
        }
    }
}
