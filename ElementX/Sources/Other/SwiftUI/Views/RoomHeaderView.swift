//
// Copyright 2025 Element Creations Ltd.
// Copyright 2022-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import Combine
import Compound
import SwiftUI

struct RoomHeaderView: View {
    let roomName: String
    var roomSubtitle: String?
    let roomAvatar: RoomAvatar
    var memberCount: Int = 0
    var isDirectOneToOneRoom: Bool = false
    var dmRecipientVerificationState: UserIdentityVerificationState?

    let mediaProvider: MediaProviderProtocol?

    var body: some View {
        if #available(iOS 26.0, *) {
            // On iOS 26+ we use the toolbarRole(.editor) to leading align.
            content
        } else {
            // On iOS 18 and lower, the editor role causes an animation glitch with the back button whenever
            // you push a screen whilst the large title is visible on the room screen.
            content
                // So take up as much space as possible, with a leading alignment for use in the default principal toolbar position
                .frame(idealWidth: .greatestFiniteMagnitude, maxWidth: .infinity, alignment: .leading)
        }
    }

    private var content: some View {
        HStack(spacing: 4) {
            VStack(alignment: .leading, spacing: 0) {
                Text(roomName)
                    .lineLimit(1)
                    .font(.compound.bodyLGSemibold)
                    .foregroundStyle(.compound.textPrimary)
                    .accessibilityIdentifier(A11yIdentifiers.roomScreen.name)

                if let roomSubtitle {
                    Text(roomSubtitle)
                        .lineLimit(1)
                        .font(.compound.bodyXS)
                        .foregroundStyle(.compound.textSecondary)
                }
            }

            if !isDirectOneToOneRoom, memberCount > 0 {
                Text("\(memberCount)")
                    .lineLimit(1)
                    .font(.compound.bodyMD)
                    .foregroundStyle(.compound.textSecondary)
            }

            if let dmRecipientVerificationState {
                VerificationBadge(verificationState: dmRecipientVerificationState)
            }
        }
    }
}

extension RoomHeaderView {
    static var toolbarRole: ToolbarRole {
        if #available(iOS 26.0, *) {
            .editor
        } else {
            .automatic
        }
    }
}

struct RoomHeaderView_Previews: PreviewProvider, TestablePreview {
    static var previews: some View {
        VStack(alignment: .center, spacing: 8) {
            makeHeader(memberCount: 5, verificationState: .notVerified)
            makeHeader(memberCount: 100, verificationState: .notVerified)
            makeHeader(memberCount: 50, verificationState: .verified)
            makeHeader(memberCount: 25, verificationState: .verificationViolation)
        }
        .previewLayout(.sizeThatFits)
    }

    static func makeHeader(memberCount: Int,
                           verificationState: UserIdentityVerificationState) -> some View {
        RoomHeaderView(roomName: "Some Room name",
                       roomAvatar: .room(id: "1",
                                         name: "Some Room Name",
                                         avatarURL: nil),
                       memberCount: memberCount,
                       dmRecipientVerificationState: verificationState,
                       mediaProvider: MediaProviderMock(configuration: .init()))
            .padding()
    }
}
