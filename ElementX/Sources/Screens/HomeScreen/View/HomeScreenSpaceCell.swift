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
                            .frame(height: 1 / UIScreen.main.scale)
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

            // Chevron to indicate this is a drilldown
            CompoundIcon(\.chevronRight, size: .small, relativeTo: .compound.bodyLGSemibold)
                .foregroundColor(.compound.iconTertiary)
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

    private var subtitle: some View {
        HStack(spacing: 4) {
            CompoundIcon(\.public, size: .xSmall, relativeTo: .compound.bodyMD)
                .foregroundStyle(.compound.iconTertiary)

            Text(L10n.commonSpace)
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

struct HomeScreenSpaceCell_Previews: PreviewProvider, TestablePreview {
    static let mediaProvider = MediaProviderMock(configuration: .init())

    static var previews: some View {
        VStack(spacing: 0) {
            HomeScreenSpaceCell(
                space: HomeScreenSpace(id: "!space1:matrix.org",
                                       name: "Engineering Team",
                                       avatarURL: nil,
                                       memberCount: 25,
                                       childrenCount: 5),
                isSelected: false,
                mediaProvider: mediaProvider
            ) { _ in }

            HomeScreenSpaceCell(
                space: HomeScreenSpace(id: "!space2:matrix.org",
                                       name: "Design Community",
                                       avatarURL: nil,
                                       memberCount: 100,
                                       childrenCount: 12),
                isSelected: true,
                mediaProvider: mediaProvider
            ) { _ in }
        }
    }
}
