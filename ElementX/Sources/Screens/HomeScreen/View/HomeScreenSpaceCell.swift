//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct HomeScreenSpaceCell: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(\.displayScale) var displayScale

    let space: HomeScreenSpace
    let isSelected: Bool
    let mediaProvider: MediaProviderProtocol?
    let action: (HomeScreenViewAction) -> Void

    private let verticalInsets = 12.0
    private let horizontalInsets = 16.0

    var body: some View {
        Button {
            action(.selectSpace(spaceID: space.id))
        } label: {
            HStack(spacing: 16.0) {
                avatar

                content
                    .padding(.vertical, verticalInsets)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Color.compound.borderDisabled)
                            .frame(height: 1 / displayScale)
                            .padding(.trailing, -horizontalInsets)
                    }
            }
            .padding(.horizontal, horizontalInsets)
            .accessibilityElement(children: .combine)
        }
        .buttonStyle(HomeScreenRoomCellButtonStyle(isSelected: isSelected))
        .accessibilityIdentifier(A11yIdentifiers.homeScreen.roomName(space.name))
    }

    @ViewBuilder @MainActor
    private var avatar: some View {
        if dynamicTypeSize < .accessibility3 {
            RoomAvatarImage(avatar: space.avatar,
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
            Text(space.name)
                .font(.compound.bodyLGSemibold)
                .foregroundColor(.compound.textPrimary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let timestamp = space.timestamp {
                Text(timestamp)
                    .font(.compound.bodySM)
                    .foregroundColor(space.isHighlighted ? .compound.textActionAccent : .compound.textSecondary)
            } else {
                // Chevron to indicate this is a drilldown (only when no timestamp)
                CompoundIcon(\.chevronRight, size: .small, relativeTo: .compound.bodyLGSemibold)
                    .foregroundColor(.compound.iconTertiary)
            }
        }
    }

    private var footer: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            ZStack(alignment: .topLeading) {
                // Hidden text with 2 lines to maintain consistent height with room cells
                Text(" \n ")
                    .font(.compound.bodyMD)
                    .hidden()

                subtitle
            }

            Spacer()

            // Badges (same as room cells)
            HStack(spacing: 8) {
                if space.badges.isMuteShown {
                    CompoundIcon(\.notificationsOffSolid, size: .custom(15), relativeTo: .compound.bodyMD)
                        .accessibilityLabel(L10n.a11yNotificationsMuted)
                }

                if space.badges.isMentionShown {
                    CompoundIcon(\.mention, size: .custom(15), relativeTo: .compound.bodyMD)
                        .accessibilityLabel(L10n.a11yNotificationsNewMentions)
                }

                if space.badges.isDotShown {
                    Circle()
                        .frame(width: 12, height: 12)
                        .accessibilityLabel(L10n.a11yNotificationsNewMessages)
                }
            }
            .foregroundColor(space.isHighlighted ? .compound.iconAccentTertiary : .compound.iconQuaternary)
        }
    }

    private var visibilityTitle: String {
        switch space.visibility {
        case .public: L10n.commonPublicSpace
        case .private: L10n.commonPrivateSpace
        case .restricted: L10n.commonSharedSpace
        case .none: L10n.commonPrivateSpace
        }
    }

    private var visibilityIcon: KeyPath<CompoundIcons, Image> {
        switch space.visibility {
        case .public: \.public
        case .private: \.lockSolid
        case .restricted: \.space
        case .none: \.lockSolid
        }
    }

    private var subtitle: some View {
        VStack(alignment: .leading, spacing: 4) {
            // First line: last message with room name prefix
            if let lastMessage = space.lastMessage {
                HStack(spacing: 0) {
                    if let roomName = space.lastMessageRoomName {
                        Text("[\(roomName)] ")
                            .font(.compound.bodyMD)
                            .foregroundColor(.compound.textSecondary)
                            .lineLimit(1)
                    }
                    Text(lastMessage)
                        .font(.compound.bodyMD)
                        .foregroundColor(.compound.textSecondary)
                        .lineLimit(1)
                }
            }

            // Second line: Public/Private Space • X members
            HStack(spacing: 4) {
                CompoundIcon(visibilityIcon, size: .xSmall, relativeTo: .compound.bodyMD)
                    .foregroundStyle(.compound.iconTertiary)

                Text(visibilityTitle)
                    .font(.compound.bodyMD)
                    .foregroundColor(.compound.textSecondary)
                    .lineLimit(1)

                if space.memberCount > 0 {
                    Text("•")
                        .font(.compound.bodyMD)
                        .foregroundColor(.compound.textSecondary)

                    Text(L10n.commonMemberCount(space.memberCount))
                        .font(.compound.bodyMD)
                        .foregroundColor(.compound.textSecondary)
                        .lineLimit(1)
                }
            }
        }
    }
}

struct HomeScreenSpaceCell_Previews: PreviewProvider, TestablePreview {
    static let mediaProvider = MediaProviderMock(configuration: .init())

    static var previews: some View {
        VStack(spacing: 0) {
            // Public space
            HomeScreenSpaceCell(
                space: HomeScreenSpace(id: "!space1:matrix.org",
                                       name: "Engineering Team",
                                       avatarURL: nil,
                                       memberCount: 25,
                                       childrenCount: 5,
                                       lastMessageDate: Date(),
                                       timestamp: "Now",
                                       lastMessage: "Let's discuss the new feature",
                                       lastMessageRoomName: "General",
                                       visibility: .public),
                isSelected: false,
                mediaProvider: mediaProvider
            ) { _ in }

            // Private space
            HomeScreenSpaceCell(
                space: HomeScreenSpace(id: "!space2:matrix.org",
                                       name: "Design Community",
                                       avatarURL: nil,
                                       memberCount: 100,
                                       childrenCount: 12,
                                       lastMessageDate: Date().addingTimeInterval(-3600),
                                       timestamp: "1h",
                                       lastMessage: "Check out the new mockups!",
                                       lastMessageRoomName: "Design Reviews",
                                       badges: .init(isDotShown: true, isMentionShown: false, isMuteShown: false),
                                       isHighlighted: true,
                                       visibility: .private),
                isSelected: true,
                mediaProvider: mediaProvider
            ) { _ in }

            // Shared (restricted) space
            HomeScreenSpaceCell(
                space: HomeScreenSpace(id: "!space3:matrix.org",
                                       name: "Shared Space",
                                       avatarURL: nil,
                                       memberCount: 50,
                                       childrenCount: 8,
                                       lastMessageDate: Date().addingTimeInterval(-7200),
                                       timestamp: "2h",
                                       lastMessage: "Meeting at 3pm",
                                       lastMessageRoomName: "Announcements",
                                       visibility: .restricted),
                isSelected: false,
                mediaProvider: mediaProvider
            ) { _ in }

            // Space without messages (nil visibility defaults to private)
            HomeScreenSpaceCell(
                space: HomeScreenSpace(id: "!space4:matrix.org",
                                       name: "Empty Space",
                                       avatarURL: nil,
                                       memberCount: 5,
                                       childrenCount: 0),
                isSelected: false,
                mediaProvider: mediaProvider
            ) { _ in }
        }
    }
}
