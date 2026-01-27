//
// Copyright 2025 Element Creations Ltd.
// Copyright 2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

/// A cell for displaying an unjoined room in the space room list.
/// This shows the room info with a Join button, similar to SpaceRoomCell.
struct SpaceRoomUnjoinedCell: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(\.displayScale) var displayScale

    let spaceRoomProxy: SpaceServiceRoomProtocol
    var isJoining = false
    let mediaProvider: MediaProviderProtocol?
    let onJoin: () -> Void

    private let verticalInsets = 12.0
    private let horizontalInsets = 16.0

    private var subtitle: String {
        L10n.commonMemberCount(spaceRoomProxy.joinedMembersCount)
    }

    private var details: String {
        spaceRoomProxy.topic ?? " "
    }

    var body: some View {
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
        .background(Color.compound.bgCanvasDefault)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(A11yIdentifiers.spaceListScreen.spaceRoomName(spaceRoomProxy.name))
    }

    @ViewBuilder @MainActor
    private var avatar: some View {
        if dynamicTypeSize < .accessibility3 {
            RoomAvatarImage(avatar: spaceRoomProxy.avatar,
                            avatarSize: .room(on: .spaces),
                            mediaProvider: mediaProvider)
                .dynamicTypeSize(dynamicTypeSize < .accessibility1 ? dynamicTypeSize : .accessibility1)
                .accessibilityHidden(true)
        }
    }

    private var content: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text(spaceRoomProxy.name)
                    .font(.compound.bodyLGSemibold)
                    .foregroundColor(.compound.textPrimary)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.compound.bodyMD)
                    .foregroundStyle(.compound.textSecondary)
                    .lineLimit(1)

                Text(details)
                    .font(.compound.bodyMD)
                    .foregroundColor(.compound.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            joinButton
        }
    }

    @ViewBuilder
    private var joinButton: some View {
        Button(L10n.actionJoin) { onJoin() }
            .font(.compound.bodyLG)
            .foregroundStyle(.compound.textActionAccent)
            .disabled(isJoining)
            .opacity(isJoining ? 0 : 1)
            .overlay {
                if isJoining {
                    ProgressView()
                }
            }
    }
}

// MARK: - Previews

struct SpaceRoomUnjoinedCell_Previews: PreviewProvider, TestablePreview {
    static let mediaProvider = MediaProviderMock(configuration: .init())

    static var previews: some View {
        VStack(spacing: 0) {
            SpaceRoomUnjoinedCell(
                spaceRoomProxy: SpaceServiceRoomMock(.init(id: "!room1:matrix.org",
                                                         name: "Design Room",
                                                         isSpace: false,
                                                         joinedMembersCount: 30,
                                                         topic: "Design discussions")),
                mediaProvider: mediaProvider
            ) { }

            SpaceRoomUnjoinedCell(
                spaceRoomProxy: SpaceServiceRoomMock(.init(id: "!room2:matrix.org",
                                                         name: "Marketing",
                                                         isSpace: false,
                                                         joinedMembersCount: 15,
                                                         topic: "Marketing team room")),
                isJoining: true,
                mediaProvider: mediaProvider
            ) { }
        }
    }
}
