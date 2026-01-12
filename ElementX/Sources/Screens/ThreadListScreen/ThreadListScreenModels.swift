//
// Copyright 2025 Element Creations Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE files in the repository root for full details.
//

import Foundation

// MARK: - Coordinator Actions

enum ThreadListScreenCoordinatorAction {
    case dismiss
    case selectThread(rootEventID: String)
}

// MARK: - View Model Actions

enum ThreadListScreenViewModelAction {
    case dismiss
    case selectThread(rootEventID: String)
}

// MARK: - View Actions

enum ThreadListScreenViewAction {
    case close
    case selectThread(ThreadListItem)
    case loadMore
}

// MARK: - View State

struct ThreadListScreenViewState: BindableState {
    var roomName: String
    var threads: [ThreadListItem] = []
    var isLoading: Bool = true
    var isLoadingMore: Bool = false
    var canLoadMore: Bool = false
}

// MARK: - Thread List Item

/// Represents a single thread in the thread list
struct ThreadListItem: Identifiable, Equatable {
    let id: String
    let rootEventID: String
    let rootSenderID: String
    let rootSenderDisplayName: String?
    let rootSenderAvatarURL: URL?
    let rootContent: String
    let replyCount: Int
    let lastReplyTimestamp: Date?
    let formattedTimestamp: String?
    let hasUnread: Bool

    // Last reply info
    let lastReplySenderID: String?
    let lastReplySenderDisplayName: String?
    let lastReplySenderAvatarURL: URL?
    let lastReplyContent: String?

    var avatarDisplayName: String {
        rootSenderDisplayName ?? rootSenderID
    }

    var lastReplyAvatarDisplayName: String? {
        lastReplySenderDisplayName ?? lastReplySenderID
    }

    init(id: String,
         rootEventID: String,
         rootSenderID: String,
         rootSenderDisplayName: String?,
         rootSenderAvatarURL: URL? = nil,
         rootContent: String,
         replyCount: Int,
         lastReplyTimestamp: Date? = nil,
         hasUnread: Bool = false,
         lastReplySenderID: String? = nil,
         lastReplySenderDisplayName: String? = nil,
         lastReplySenderAvatarURL: URL? = nil,
         lastReplyContent: String? = nil) {
        self.id = id
        self.rootEventID = rootEventID
        self.rootSenderID = rootSenderID
        self.rootSenderDisplayName = rootSenderDisplayName
        self.rootSenderAvatarURL = rootSenderAvatarURL
        self.rootContent = rootContent
        self.replyCount = replyCount
        self.lastReplyTimestamp = lastReplyTimestamp
        self.formattedTimestamp = lastReplyTimestamp?.formattedMinimal()
        self.hasUnread = hasUnread
        self.lastReplySenderID = lastReplySenderID
        self.lastReplySenderDisplayName = lastReplySenderDisplayName
        self.lastReplySenderAvatarURL = lastReplySenderAvatarURL
        self.lastReplyContent = lastReplyContent
    }
}
