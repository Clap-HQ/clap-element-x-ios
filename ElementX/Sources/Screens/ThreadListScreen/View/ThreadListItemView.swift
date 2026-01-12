//
// Copyright 2025 Element Creations Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Compound
import SwiftUI

struct ThreadListItemView: View {
    let thread: ThreadListItem
    let mediaProvider: MediaProviderProtocol?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                // Root sender avatar
                LoadableAvatarImage(url: thread.rootSenderAvatarURL,
                                   name: thread.rootSenderDisplayName,
                                   contentID: thread.rootSenderID,
                                   avatarSize: .user(on: .timeline),
                                   mediaProvider: mediaProvider)

                // Thread content
                VStack(alignment: .leading, spacing: 6) {
                    // Sender name and timestamp
                    HStack {
                        Text(thread.avatarDisplayName)
                            .font(.compound.bodyLGSemibold)
                            .foregroundColor(.compound.decorativeColor(for: thread.rootSenderID).text)
                            .lineLimit(1)

                        Spacer()

                        if let timestamp = thread.formattedTimestamp {
                            Text(timestamp)
                                .font(.compound.bodySM)
                                .foregroundColor(.compound.textSecondary)
                        }
                    }

                    // Root message content
                    Text(thread.rootContent)
                        .font(.compound.bodyMD)
                        .foregroundColor(.compound.textPrimary)
                        .lineLimit(2)

                    // Reply info row: reply count + last reply avatar + last reply text
                    HStack(spacing: 6) {
                        // Reply count with icon
                        HStack(spacing: 4) {
                            CompoundIcon(\.threads, size: .xSmall, relativeTo: .compound.bodySM)
                                .foregroundColor(.compound.iconSecondary)

                            Text("\(thread.replyCount)")
                                .font(.compound.bodySM)
                                .foregroundColor(.compound.textSecondary)
                        }

                        // Last reply info
                        if let lastReplyDisplayName = thread.lastReplyAvatarDisplayName,
                           let lastReplySenderID = thread.lastReplySenderID {
                            // Last replier avatar (smaller)
                            LoadableAvatarImage(url: thread.lastReplySenderAvatarURL,
                                               name: thread.lastReplySenderDisplayName,
                                               contentID: lastReplySenderID,
                                               avatarSize: .custom(16),
                                               mediaProvider: mediaProvider)

                            // Last reply content
                            if let lastReplyContent = thread.lastReplyContent {
                                Text(lastReplyContent)
                                    .font(.compound.bodySM)
                                    .foregroundColor(.compound.textSecondary)
                                    .lineLimit(1)
                            }
                        }

                        Spacer(minLength: 0)

                        // Unread indicator
                        if thread.hasUnread {
                            Circle()
                                .fill(Color.compound.iconAccentTertiary)
                                .frame(width: 8, height: 8)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

struct ThreadListItemView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            ThreadListItemView(
                thread: ThreadListItem(
                    id: "thread1",
                    rootEventID: "event1",
                    rootSenderID: "@alice:example.com",
                    rootSenderDisplayName: "Alice",
                    rootContent: "Has anyone tried the new feature? I'm curious to hear what you all think about the implementation.",
                    replyCount: 5,
                    lastReplyTimestamp: Date(),
                    hasUnread: true,
                    lastReplySenderID: "@bob:example.com",
                    lastReplySenderDisplayName: "Bob",
                    lastReplyContent: "Yes, it works great!"
                ),
                mediaProvider: MediaProviderMock(configuration: .init()),
                action: { }
            )

            Divider()
                .padding(.leading, 72)

            ThreadListItemView(
                thread: ThreadListItem(
                    id: "thread2",
                    rootEventID: "event2",
                    rootSenderID: "@bob:example.com",
                    rootSenderDisplayName: "Bob",
                    rootContent: "I found a bug in the login flow",
                    replyCount: 12,
                    lastReplyTimestamp: Date().addingTimeInterval(-3600),
                    hasUnread: false,
                    lastReplySenderID: "@charlie:example.com",
                    lastReplySenderDisplayName: "Charlie",
                    lastReplyContent: "Fixed in the latest commit"
                ),
                mediaProvider: MediaProviderMock(configuration: .init()),
                action: { }
            )

            Divider()
                .padding(.leading, 72)

            ThreadListItemView(
                thread: ThreadListItem(
                    id: "thread3",
                    rootEventID: "event3",
                    rootSenderID: "@charlie:example.com",
                    rootSenderDisplayName: nil,
                    rootContent: "Meeting notes",
                    replyCount: 3,
                    lastReplyTimestamp: Date().addingTimeInterval(-86400),
                    hasUnread: false,
                    lastReplySenderID: "@alice:example.com",
                    lastReplySenderDisplayName: "Alice",
                    lastReplyContent: "Thanks for sharing!"
                ),
                mediaProvider: MediaProviderMock(configuration: .init()),
                action: { }
            )
        }
        .previewDisplayName("Thread List Items")
    }
}
